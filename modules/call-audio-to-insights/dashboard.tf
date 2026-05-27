
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.project}-call--${random_id.suffix.hex}"
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "type" : "metric",
        "height" : 4,
        "width" : 6,
        "y" : 0,
        "x" : 0,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.transcribe.function_name, { "id" : "invokes", "label" : "Total Requests" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.transcribe.function_name, { "id" : "duration", "label" : "Average Response Time", "stat" : "Average" }],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.transcribe.function_name, { "id" : "invoke_errors", "visible" : false }],
            ["AWS/Lambda", "Url4xxCount", "FunctionName", aws_lambda_function.transcribe.function_name, { "id" : "errors_400", "visible" : false }],
            ["AWS/Lambda", "Url5xxCount", "FunctionName", aws_lambda_function.transcribe.function_name, { "id" : "errors_500", "visible" : false }],
            [{ "label" : "Total Errors", "color" : "#d62728", "expression" : "invoke_errors + errors_400 + errors_500", "id" : "total_errors" }],
            [{ "label" : "Sucess Rate (%)", "color" : "#2ca02c", "expression" : "100 - ((total_errors/invokes) * 100)", "id" : "sucess_rate" }]
          ],
          "title" : "Transcribe Lambda",
          "region" : var.region,
          "stat" : "Sum",
          "view" : "singleValue",
          "setPeriodToTimeRange" : true
        }
      },
      {
        "type" : "metric",
        "height" : 4,
        "width" : 6,
        "y" : 0,
        "x" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.sentiment.function_name, { "id" : "invokes", "label" : "Total Requests" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.sentiment.function_name, { "id" : "duration", "label" : "Average Response Time", "stat" : "Average" }],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.sentiment.function_name, { "id" : "invoke_errors", "visible" : false }],
            ["AWS/Lambda", "Url4xxCount", "FunctionName", aws_lambda_function.sentiment.function_name, { "id" : "errors_400", "visible" : false }],
            ["AWS/Lambda", "Url5xxCount", "FunctionName", aws_lambda_function.sentiment.function_name, { "id" : "errors_500", "visible" : false }],
            [{ "label" : "Total Errors", "color" : "#d62728", "expression" : "invoke_errors + errors_400 + errors_500", "id" : "total_errors" }],
            [{ "label" : "Sucess Rate (%)", "color" : "#2ca02c", "expression" : "100 - ((total_errors/invokes) * 100)", "id" : "sucess_rate" }]
          ],
          "title" : "Sentiment Lambda",
          "region" : var.region,
          "stat" : "Sum",
          "view" : "singleValue",
          "setPeriodToTimeRange" : true
        }
      },
      {
        "type" : "metric",
        "height" : 4,
        "width" : 6,
        "y" : 0,
        "x" : 12,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.bedrock.function_name, { "id" : "invokes", "label" : "Total Requests" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.bedrock.function_name, { "id" : "duration", "label" : "Average Response Time", "stat" : "Average" }],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.bedrock.function_name, { "id" : "invoke_errors", "visible" : false }],
            ["AWS/Lambda", "Url4xxCount", "FunctionName", aws_lambda_function.bedrock.function_name, { "id" : "errors_400", "visible" : false }],
            ["AWS/Lambda", "Url5xxCount", "FunctionName", aws_lambda_function.bedrock.function_name, { "id" : "errors_500", "visible" : false }],
            [{ "label" : "Total Errors", "color" : "#d62728", "expression" : "invoke_errors + errors_400 + errors_500", "id" : "total_errors" }],
            [{ "label" : "Sucess Rate (%)", "color" : "#2ca02c", "expression" : "100 - ((total_errors/invokes) * 100)", "id" : "sucess_rate" }]
          ],
          "title" : "Bedrock Lambda",
          "region" : var.region,
          "stat" : "Sum",
          "view" : "singleValue",
          "setPeriodToTimeRange" : true
        }
      },
      {
        "type" : "metric",
        "height" : 4,
        "width" : 6,
        "y" : 0,
        "x" : 18,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.polly.function_name, { "id" : "invokes", "label" : "Total Requests" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.polly.function_name, { "id" : "duration", "label" : "Average Response Time", "stat" : "Average" }],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.polly.function_name, { "id" : "invoke_errors", "visible" : false }],
            ["AWS/Lambda", "Url4xxCount", "FunctionName", aws_lambda_function.polly.function_name, { "id" : "errors_400", "visible" : false }],
            ["AWS/Lambda", "Url5xxCount", "FunctionName", aws_lambda_function.polly.function_name, { "id" : "errors_500", "visible" : false }],
            [{ "label" : "Total Errors", "color" : "#d62728", "expression" : "invoke_errors + errors_400 + errors_500", "id" : "total_errors" }],
            [{ "label" : "Sucess Rate (%)", "color" : "#2ca02c", "expression" : "100 - ((total_errors/invokes) * 100)", "id" : "sucess_rate" }]
          ],
          "title" : "Polly Lambda",
          "region" : var.region,
          "stat" : "Sum",
          "view" : "singleValue",
          "setPeriodToTimeRange" : true
        }
      },
      {
        "height" : 5,
        "width" : 7,
        "y" : 4,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "view" : "timeSeries",
          "stacked" : true,
          "metrics" : [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.this.name, { "label" : "Written Objects", "color" : "#ff7f0e" }],
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.this.name, { "label" : "Read Objects", "color" : "#2ca02c" }]
          ],
          "title" : "DynamoDB Read / Write Capacity",
          "region" : var.region,
          "setPeriodToTimeRange" : true
        }
      },
      {
        "height" : 5,
        "width" : 6,
        "y" : 9,
        "x" : 7,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.this.name, { "color" : "#ff7f0e", "label" : "Written Objects" }],
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.this.name, { "color" : "#2ca02c", "label" : "Read Objects" }]
          ],
          "view" : "pie",
          "region" : var.region,
          "stat" : "SampleCount",
          "setPeriodToTimeRange" : true,
          "title" : "DynamoDB Read/Write Comparison (%)"
        }
      },
      {
        "x" : 0,
        "y" : 14,
        "width" : 23,
        "height" : 6,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["${var.project}-${random_id.suffix.hex}", "positiveSentiment", "service", "call-insights"],
            ["${var.project}-${random_id.suffix.hex}", "negativeSentiment", "service", "call-insights"],
            ["${var.project}-${random_id.suffix.hex}", "mixedSentiment", "service", "call-insights"]
          ],
          "region" : var.region,
          "view" : "bar",
          "stat" : "Sum",
          "setPeriodToTimeRange" : true,
          "sparkline" : false,
          "trend" : false,
          "stacked" : true,
          "title" : "Sentiment Call Insights",
          "yAxis" : {
            "left" : {
              "min" : 1,
              "max" : 200
            }
          }
        }
      },
      {
        "x" : 0,
        "y" : 20,
        "width" : 23,
        "height" : 6,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["${var.project}-${random_id.suffix.hex}", "personalCall", "service", "call-insights"],
            ["${var.project}-${random_id.suffix.hex}", "businessCall", "service", "call-insights"],
            ["${var.project}-${random_id.suffix.hex}", "unknownCall", "service", "call-insights"]
          ],
          "region" : var.region,
          "view" : "bar",
          "stat" : "Sum",
          "setPeriodToTimeRange" : true,
          "sparkline" : false,
          "trend" : false,
          "stacked" : true,
          "title" : "Type Call Insights",
          "yAxis" : {
            "left" : {
              "min" : 1,
              "max" : 200
            }
          }
        }
      }
    ]
  })
}
