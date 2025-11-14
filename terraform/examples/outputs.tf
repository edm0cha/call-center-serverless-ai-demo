output "recordings_bucket" { value = module.call_audio_to_insights.recordings_bucket }
output "outputs_bucket"    { value = module.call_audio_to_insights.outputs_bucket }
output "ingest_lambda_arn" { value = module.call_audio_to_insights.ingest_lambda_arn }
output "post_lambda_arn"   { value = module.call_audio_to_insights.post_lambda_arn }
output "event_rule_name"   { value = module.call_audio_to_insights.event_rule_name }
output "aws_connect_instance" { value = module.call_audio_to_insights.aws_connect_instance }