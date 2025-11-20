import os, json, boto3, re
from urllib.parse import urlparse

s3 = boto3.client("s3")
comprehend = boto3.client("comprehend")
polly = boto3.client("polly")
bedrock = boto3.client("bedrock-runtime")  # requiere permisos/region habilitada

OUTPUTS_BUCKET  = os.environ["OUTPUTS_BUCKET"]
BEDROCK_MODELID = os.environ["BEDROCK_MODELID"]

def _extract_text_from_transcript(transcript_json):
    # Transcribe JSON estándar: results->transcripts[0].transcript
    try:
        return transcript_json["results"]["transcripts"][0]["transcript"]
    except Exception:
        return ""

def lambda_handler(event, context):
    # EventBridge detail => incluye TranscriptionJobName y OutputLocation (S3)
    detail = event.get("detail", {})
    uri = detail.get("OutputLocation")
    if not uri:
        # Si no viene en evento, podríamos llamar GetTranscriptionJob y leer 'TranscriptFileUri'
        return {"error": "No OutputLocation in event"}

    parsed = urlparse(uri)
    bucket = parsed.netloc
    key    = parsed.path.lstrip("/")

    obj = s3.get_object(Bucket=bucket, Key=key)
    transcript_json = json.loads(obj["Body"].read())
    text = _extract_text_from_transcript(transcript_json)
    if not text:
        return {"error": "Empty transcript"}

    # 1) Sentimiento
    senti = comprehend.detect_sentiment(Text=text[:4500], LanguageCode="es")

    # 2) Resumen con Bedrock (Claude Haiku)
    prompt = (
        "Eres un analista de atención al cliente. "
        "Resume la conversación en 3 viñetas, tono empático y profesional; "
        "al final propone una acción concreta.\n\nTexto:\n" + text
    )
    native_request = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 512,
        "temperature": 0.3,
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt
                    }
                ]
            }
        ]
    }
    response = bedrock.invoke_model(
        modelId=BEDROCK_MODELID,
        body=json.dumps(native_request),
        contentType="application/json",
        accept="application/json"
    )

    model_payload = json.loads(response["body"].read())
    summary = model_payload.get("outputText", "").strip()

    # 3) Audio con Polly (voz Lucia)
    speech = polly.synthesize_speech(Text=summary[:3000], OutputFormat="mp3", VoiceId="Lucia")
    audio_key = f"outputs/audio/{detail['TranscriptionJobName']}.mp3"
    s3.put_object(Body=speech["AudioStream"].read(), Bucket=OUTPUTS_BUCKET, Key=audio_key)

    # 4) Guardar resultado JSON final (sentimiento + resumen + paths)
    result = {
        "transcription_job": detail.get("TranscriptionJobName"),
        "sentiment": senti,
        "summary": summary,
        "transcript_s3": uri,
        "audio_s3": f"s3://{OUTPUTS_BUCKET}/{audio_key}"
    }
    result_key = f"outputs/json/{detail['TranscriptionJobName']}.json"
    s3.put_object(
        Bucket=OUTPUTS_BUCKET,
        Key=result_key,
        Body=json.dumps(result, ensure_ascii=False).encode("utf-8"),
        ContentType="application/json"
    )

    return {"ok": True, "result_key": result_key}
