import os, boto3

# Added Metrics
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

s3 = boto3.client("s3")
polly = boto3.client("polly")

dynamodb = boto3.resource("dynamodb")
DYNAMO_DB_TABLE = os.environ.get("DYNAMO_DB_TABLE", "call-insights")
table = dynamodb.Table(DYNAMO_DB_TABLE)

OUTPUTS_BUCKET = os.environ["OUTPUTS_BUCKET"]

# Initialize Metrics
metrics = Metrics(service="call-insights", namespace=os.environ["PROJECT_NAME"])


@metrics.log_metrics
def lambda_handler(event, context):
    job_name = event["TranscriptionJobName"]
    print(f"Creating audio of Bedrock analysis for job {job_name}")
    summary = table.get_item(Key={"transcription_job": job_name})["Item"]["summary"]

    # 1) Polly audio creation
    speech = polly.synthesize_speech(
        Text=summary[:3000], OutputFormat="mp3", VoiceId=os.environ["POLLY_VOICE_ID"]
    )
    audio_key = f"outputs/audio/{job_name}.mp3"
    s3.put_object(
        Body=speech["AudioStream"].read(), Bucket=OUTPUTS_BUCKET, Key=audio_key
    )
    print(f"Audio of summary created for {job_name}, storing results")

    # 2) Save audio path in DynamoDB
    table.update_item(
        Key={"transcription_job": job_name},
        UpdateExpression="SET audio_s3 = :audio_s3",
        ExpressionAttributeValues={":audio_s3": f"s3://{OUTPUTS_BUCKET}/{audio_key}"},
        ReturnValues="UPDATED_NEW",
    )

    return {"ok": True, "TranscriptionJobName": job_name}
