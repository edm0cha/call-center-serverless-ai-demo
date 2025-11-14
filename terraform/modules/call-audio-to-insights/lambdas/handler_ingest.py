import os, json, urllib.parse, boto3, uuid

s3 = boto3.client("s3")
transcribe = boto3.client("transcribe")

REGION = os.environ.get("REGION", "us-east-1")
RECORDINGS_BUCKET = os.environ["RECORDINGS_BUCKET"]
OUTPUTS_BUCKET = os.environ["OUTPUTS_BUCKET"]

def lambda_handler(event, context):
    # Evento S3 ObjectCreated
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key    = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        if not key.lower().endswith((".wav",".mp3",".mp4",".m4a",".flac",".ogg",".webm")):
            continue

        job_name = f"job-{uuid.uuid4()}"
        media_uri = f"s3://{bucket}/{key}"

        transcribe.start_transcription_job(
            TranscriptionJobName=job_name,
            LanguageCode="es-MX",  # ajusta si tu audio es es-ES, en-US, etc.
            Media={"MediaFileUri": media_uri},
            OutputBucketName=OUTPUTS_BUCKET,
            Settings={"ShowSpeakerLabels": True, "MaxSpeakerLabels": 2}
        )

    return {"ok": True}
