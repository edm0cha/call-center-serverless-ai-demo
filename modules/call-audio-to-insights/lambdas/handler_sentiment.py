import os, json, boto3

# Added Metrics
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

s3 = boto3.client("s3")
comprehend = boto3.client("comprehend")

dynamodb = boto3.resource("dynamodb")
DYNAMO_DB_TABLE = os.environ.get("DYNAMO_DB_TABLE", "call-insights")
table = dynamodb.Table(DYNAMO_DB_TABLE)

OUTPUTS_BUCKET = os.environ["OUTPUTS_BUCKET"]

# Initialize Metrics
metrics = Metrics(service="call-insights", namespace=os.environ["PROJECT_NAME"])


def _extract_text_from_transcript(transcript_json):
    try:
        return transcript_json["results"]["transcripts"][0]["transcript"]
    except Exception:
        return ""


@metrics.log_metrics
def lambda_handler(event, context):
    job_name = event["TranscriptionJobName"]
    key = job_name + ".json"
    print(
        f"Getting sentiment from transcription job result s3://{OUTPUTS_BUCKET}/{key}"
    )

    obj = s3.get_object(Bucket=OUTPUTS_BUCKET, Key=key)
    transcript_json = json.loads(obj["Body"].read())
    text = _extract_text_from_transcript(transcript_json)
    if not text:
        return {"error": "Empty transcript"}

    # 1) Get Sentiment
    senti = comprehend.detect_sentiment(Text=text[:4500], LanguageCode="es")
    print(f"Sentiment detected for {job_name}, storing result")

    # 2) Save Sentiment to DynamoDB
    table.update_item(
        Key={"transcription_job": job_name},
        UpdateExpression="SET sentiment = :sentiment",
        ExpressionAttributeValues={":sentiment": senti["Sentiment"]},
        ReturnValues="UPDATED_NEW",
    )

    # 3) Send metrics
    if senti["Sentiment"] == "POSITIVE":
        metrics.add_metric(name="positiveSentiment", unit=MetricUnit.Count, value=1)
    elif senti["Sentiment"] == "NEGATIVE":
        metrics.add_metric(name="negativeSentiment", unit=MetricUnit.Count, value=1)
    else:
        metrics.add_metric(name="mixedSentiment", unit=MetricUnit.Count, value=1)

    return {"ok": True, "TranscriptionJobName": job_name}
