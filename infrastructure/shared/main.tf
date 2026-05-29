# ─────────────────────────────────────────────────────────────────────────────
# GitHub Actions OIDC Provider
#
# Bootstrap this ONCE manually:
#   cd infrastructure/shared
#   terraform init
#   terraform apply
#
# After this runs, all subsequent deploys authenticate through the IAM role
# below — no static credentials needed.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_caller_identity" "current" {}

# GitHub's OIDC provider — managed externally, looked up by URL
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# ─────────────────────────────────────────────────────────────────────────────
# IAM Role — assumed by GitHub Actions via OIDC
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "github_actions" {
  name = "${var.prefix}-${var.repository_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubActionsOIDC"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Scoped to this specific repository
            "token.actions.githubusercontent.com:sub" = "repo:${var.repository_organization}/${var.repository_name}:*"
          }
        }
      }
    ]
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# IAM Policy — minimum permissions for this demo (S3 static site + state)
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_policy" "github_actions" {
  name        = "${var.prefix}-${var.repository_name}-github-actions"
  description = "Scoped permissions for GitHub Actions: S3 website + Terraform state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3WebsiteManagement"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketWebsite",
          "s3:PutBucketWebsite",
          "s3:DeleteBucketWebsite",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:ListAllMyBuckets",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketCors",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:ListBucketVersions",
          "s3:DeleteObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::${var.prefix}-${var.repository_name}-*",
          "arn:aws:s3:::${var.prefix}-${var.repository_name}-*/*",
        ]
      },
      {
        Sid    = "DynamoDBTodolist"
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive"
        ]
        Resource = [
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.prefix}-${var.repository_name}-*"
        ]
      },
      {
        Sid    = "LambdaManagement"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:ListTags",
          "lambda:GetPolicy",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:CreateFunctionUrlConfig",
          "lambda:GetFunctionUrlConfig",
          "lambda:UpdateFunctionUrlConfig",
          "lambda:DeleteFunctionUrlConfig",
          "lambda:PublishLayerVersion",
          "lambda:GetLayerVersion",
          "lambda:DeleteLayerVersion",
          "lambda:ListLayerVersions",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig"
        ]
        Resource = [
          "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:${var.prefix}-${var.repository_name}-*"
        ]
      },
      {
        Sid    = "LambdaPowerToolsLayer"
        Effect = "Allow"
        Action = [
          "lambda:GetLayerVersion"
        ]
        Resource = [
          "arn:aws:lambda:*:*:layer:AWSLambdaPowertoolsPythonV2:*"
        ]
      },
      {
        # DescribeLogGroups is a list-type action — IAM evaluates it against an
        # empty resource ARN, so it cannot be scoped to a specific log group.
        Sid    = "CloudWatchLogsDescribe"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
      },
      {
        Sid    = "CloudWatchLogsManagement"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:ListTagsLogGroup",
          "logs:TagResource",
          "logs:UntagResource",
          "logs:ListTagsForResource",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy"
        ]
        Resource = [
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.prefix}-${var.repository_name}-*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.prefix}-${var.repository_name}-*:*"
        ]
      },
      {
        # Write IAM actions — scoped to resources with the project prefix so
        # this role can only manage its own role and policy, not arbitrary IAM.
        Sid    = "IAMWrite"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:CreateRole",
          "iam:UpdateRole",
          "iam:DeleteRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:GetPolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListPolicyVersions",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}-${var.repository_name}-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.prefix}-${var.repository_name}-*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Actual Environment Terraform State
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.prefix}-${var.repository_name}-tfstate"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
