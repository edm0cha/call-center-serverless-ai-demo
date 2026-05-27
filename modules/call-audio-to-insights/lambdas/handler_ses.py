import os, boto3

# Added Metrics
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

ses = boto3.client("ses")

dynamodb = boto3.resource("dynamodb")
DYNAMO_DB_TABLE = os.environ.get("DYNAMO_DB_TABLE", "call-insights")
table = dynamodb.Table(DYNAMO_DB_TABLE)

SOURCE_EMAIL = os.environ.get("SOURCE_EMAIL", "")

# Initialize Metrics
metrics = Metrics(service="call-insights", namespace=os.environ["PROJECT_NAME"])


def _sentiment_emoji(sentiment: str) -> str:
    return {
        "POSITIVE": "😊 Positive",
        "NEGATIVE": "😞 Negative",
        "MIXED":    "😐 Mixed",
        "NEUTRAL":  "😶 Neutral",
    }.get(sentiment.upper(), sentiment)


def _call_type_label(call_type: str, is_personal: bool) -> str:
    if is_personal:
        return "Personal"
    return "Business" if call_type == "business" else call_type.capitalize()


def _build_email_body(item: dict, job_name: str) -> str:
    sentiment      = item.get("sentiment", "N/A")
    summary        = item.get("summary", "N/A")
    suggested      = item.get("suggested_action", "N/A")
    call_type      = item.get("call_type", "N/A")
    is_personal    = item.get("is_personal_call", False)
    transcript_s3  = item.get("transcript_s3", "N/A")
    audio_s3       = item.get("audio_s3", "N/A")

    return (
        f"Call Insights Report\n"
        f"{'=' * 50}\n\n"
        f"Job ID       : {job_name}\n"
        f"Sentiment    : {_sentiment_emoji(sentiment)}\n"
        f"Call Type    : {_call_type_label(call_type, is_personal)}\n\n"
        f"Summary\n"
        f"{'-' * 50}\n"
        f"{summary}\n\n"
        f"Suggested Action\n"
        f"{'-' * 50}\n"
        f"{suggested}\n\n"
        f"Artifacts\n"
        f"{'-' * 50}\n"
        f"Transcript : {transcript_s3}\n"
        f"Audio      : {audio_s3}\n\n"
        f"{'=' * 50}\n"
        f"This message was generated automatically by the Call Insights pipeline.\n"
    )


@metrics.log_metrics
def lambda_handler(event, context):
    job_name = event["TranscriptionJobName"]
    print(f"Sending SES email for job {job_name}")

    if not SOURCE_EMAIL:
        print("SOURCE_EMAIL env var is not set — skipping email notification")
        return {"ok": True, "email_sent": False, "TranscriptionJobName": job_name}

    item = table.get_item(Key={"transcription_job": job_name})["Item"]

    body = _build_email_body(item, job_name)
    sentiment = item.get("sentiment", "")

    ses.send_email(
        Source=SOURCE_EMAIL,
        Destination={"ToAddresses": [SOURCE_EMAIL]},
        Message={
            "Subject": {
                "Data": f"[Call Insights] {sentiment.capitalize()} call analyzed — {job_name}",
                "Charset": "UTF-8",
            },
            "Body": {
                "Text": {
                    "Data": body,
                    "Charset": "UTF-8",
                }
            },
        },
    )

    print(f"Email sent successfully for job {job_name}")
    metrics.add_metric(name="emailSent", unit=MetricUnit.Count, value=1)

    return {"ok": True, "email_sent": True, "TranscriptionJobName": job_name}
