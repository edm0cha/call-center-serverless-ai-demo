aws polly synthesize-speech \
  --voice-id Miguel \
  --output-format mp3 \
  --text "Hola, este es un mensaje de prueba para Amazon Connect. Esta llamada debe ser transcrita y procesada por nuestra lambda." \
  prueba-miguel.mp3

aws polly synthesize-speech \
  --voice-id Enrique \
  --output-format mp3 \
  --text "Este es un mensaje de prueba. Estoy llamando a la línea de soporte. Por favor grabe este mensaje." \
  prueba-enrique.mp3


{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventTime": "2025-11-11T23:50:00.000Z",
      "eventName": "ObjectCreated:Put",
      "userIdentity": {
        "principalId": "AWS:EXAMPLE"
      },
      "requestParameters": {
        "sourceIPAddress": "10.0.0.1"
      },
      "responseElements": {
        "x-amz-request-id": "ABCDEFG123456",
        "x-amz-id-2": "XYZexample123/abcdefghijklmn"
      },
      "s3": {
        "s3SchemaVersion": "1.0",
        "configurationId": "lambda-trigger",
        "bucket": {
          "name": "ia-demo-connect-recordings-d1a2db35",
          "ownerIdentity": {
            "principalId": "EXAMPLE"
          },
          "arn": "arn:aws:s3:::ia-demo-connect-recordings-d1a2db35"
        },
        "object": {
          "key": "record_a.m4a",
          "size": 24960,
          "eTag": "7eeb2f5769a447f8a475b8c881ca32f7",
          "sequencer": "00123456789ABCDEFFEDCBA987654321"
        }
      }
    }
  ]
}
