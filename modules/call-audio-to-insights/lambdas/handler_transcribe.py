import os, boto3, uuid, time

# Added Metrics
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

s3 = boto3.client("s3")
transcribe = boto3.client("transcribe")

dynamodb = boto3.resource("dynamodb")
DYNAMO_DB_TABLE = os.environ.get("DYNAMO_DB_TABLE", "call-insights")
table = dynamodb.Table(DYNAMO_DB_TABLE)

OUTPUTS_BUCKET = os.environ["OUTPUTS_BUCKET"]

# Initialize Metrics
metrics = Metrics(service="call-insights", namespace=os.environ["PROJECT_NAME"])

@metrics.log_metrics
def lambda_handler(event, context):
    # S3 ObjectCreated event
    bucket = event["detail"]["bucket"]["name"]
    key = event["detail"]["object"]["key"]
    if not key.lower().endswith(
        (".wav", ".mp3", ".mp4", ".m4a", ".flac", ".ogg", ".webm")
    ):
        print(f"File {key} is not a supported audio format, raising exception")
        raise ValueError(f"File {key} is not a supported audio format")

    job_name = f"job-{uuid.uuid4()}"
    media_uri = f"s3://{bucket}/{key}"

    # Start transcription job
    print(f"Starting transcription job {job_name} for {media_uri}")
    transcribe.start_transcription_job(
        TranscriptionJobName=job_name,
        IdentifyLanguage=True,
        LanguageOptions=["es-US", "es-ES", "en-US", "en-GB"],
        Media={"MediaFileUri": media_uri},
        OutputBucketName=OUTPUTS_BUCKET,
        Settings={"ShowSpeakerLabels": True, "MaxSpeakerLabels": 2},
    )
    # Wait for transcription job to complete
    max_attempts = 120
    delay = 5
    attempt = 0

    while attempt < max_attempts:
        response = transcribe.get_transcription_job(TranscriptionJobName=job_name)
        status = response['TranscriptionJob']['TranscriptionJobStatus']

        if status == 'COMPLETED':
            break
        elif status == 'FAILED':
            raise Exception(f"Transcription job {job_name} failed")

        # Exponential backoff
        wait_time = delay * (2 ** min(attempt, 6))  # Cap at 2^6 to avoid too long waits
        time.sleep(wait_time)
        attempt += 1

    if attempt >= max_attempts:
        raise Exception(f"Transcription job {job_name} timed out after {max_attempts} attempts")
    print(f"Transcription job finished {job_name} for {media_uri}, storing result")

    # Save transcript job and placeholder
    result = {
        "transcription_job": job_name,
        "sentiment": None,
        "summary": None,
        "suggested_action": None,
        "call_type": None,
        "is_personal_call": None,
        "transcript_s3": f"s3://{OUTPUTS_BUCKET}/{job_name}.json",
        "audio_s3": None,
    }

    table.put_item(Item=result)

    return {"ok": True, "TranscriptionJobName": job_name}
