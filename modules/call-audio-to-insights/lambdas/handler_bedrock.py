import os, json, boto3

# Added Metrics
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

s3 = boto3.client("s3")
bedrock = boto3.client("bedrock-runtime")

dynamodb = boto3.resource("dynamodb")
DYNAMO_DB_TABLE = os.environ.get("DYNAMO_DB_TABLE", "call-insights")
table = dynamodb.Table(DYNAMO_DB_TABLE)

OUTPUTS_BUCKET = os.environ["OUTPUTS_BUCKET"]
BEDROCK_MODELID = os.environ["BEDROCK_MODELID"]
RESPONSE_LANGUAGE = os.environ.get("RESPONSE_LANGUAGE", "Spanish")

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
    print(f"Analyzing transcription job result s3://{OUTPUTS_BUCKET}/{key}")

    obj = s3.get_object(Bucket=OUTPUTS_BUCKET, Key=key)
    transcript_json = json.loads(obj["Body"].read())
    text = _extract_text_from_transcript(transcript_json)
    if not text:
        return {"error": "Empty transcript"}

    # 1) Bedrock analysis
    prompt = f"""
    You are a customer service analyst at a major parcel delivery company.
    Based on the following phone call transcript, please:
    1) Summarize the call in a maximum of 3 bullet points.
    2) Propose ONE concrete action for the business.
    3) Classify whether the call is PERSONAL or BUSINESS in nature. A personal call involves mentions of friends, family, or topics unrelated to the business.

    Respond **EXCLUSIVELY** with a valid JSON object using this structure, all values must be **strings only**:

    {{
    "summary": "<call summary>",
    "suggested_action": "<recommended action>",
    "call_type": "<personal|business>"
    }}

    Do not use markdown formatting, JSON wrappers, or extra line breaks in your response.
    Respond in {RESPONSE_LANGUAGE}.

    Call transcript:
    \"\"\"{text}\"\"\"
    """

    response = bedrock.invoke_model(
        modelId=BEDROCK_MODELID,
        body=json.dumps(
            {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 512,
                "temperature": 0.3,
                "messages": [{"role": "user", "content": prompt}],
            }
        ),
        contentType="application/json",
        accept="application/json",
    )

    model_response = json.loads(response["body"].read())
    output = json.loads(model_response["content"][0]["text"].strip())
    print(f"Bedrock model output: {output}")

    # Normalize call_type to a known value
    if output["call_type"] not in ["personal", "business"]:
        output["call_type"] = "unknown"

    is_personal_call = output["call_type"] == "personal"
    print(f"Finished analysis for {job_name}, storing results")

    # 2) Save Bedrock result to DynamoDB
    table.update_item(
        Key={"transcription_job": job_name},
        UpdateExpression="SET summary = :summary, suggested_action = :suggested_action, call_type = :call_type, is_personal_call = :is_personal_call",
        ExpressionAttributeValues={
            ":summary": output["summary"],
            ":suggested_action": output["suggested_action"],
            ":call_type": output["call_type"],
            ":is_personal_call": is_personal_call,
        },
        ReturnValues="UPDATED_NEW",
    )

    # 3) Send metrics
    if output["call_type"] == "personal":
        metrics.add_metric(name="personalCall", unit=MetricUnit.Count, value=1)
    elif output["call_type"] == "business":
        metrics.add_metric(name="businessCall", unit=MetricUnit.Count, value=1)
    else:
        metrics.add_metric(name="unknownCall", unit=MetricUnit.Count, value=1)

    return {"ok": True, "TranscriptionJobName": job_name}
