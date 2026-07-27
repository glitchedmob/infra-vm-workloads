data "aws_caller_identity" "current" {}

locals {
  authentik_ses_from_address = "id@levizitting.com"
  authentik_ses_policy_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/applications/authentik/AuthentikSESSender"
  authentik_ssm_prefix       = "/vm-workloads/lz/infra-vm-workloads/authentik"
}

import {
  to = aws_iam_user.authentik_ses
  id = "authentik-ses-smtp"
}

ephemeral "random_password" "authentik_secret_key" {
  length  = 60
  special = false
}

ephemeral "random_password" "authentik_bootstrap_token" {
  length  = 60
  special = false
}

resource "aws_iam_user" "authentik_ses" {
  name = "authentik-ses-smtp"
  path = "/applications/authentik/"

  tags = {
    Application    = "authentik"
    Environment    = "production"
    ManagedBy      = "OpenTofu"
    SESFromAddress = local.authentik_ses_from_address
  }
}

resource "aws_iam_user_policy_attachment" "authentik_ses" {
  user       = aws_iam_user.authentik_ses.name
  policy_arn = local.authentik_ses_policy_arn
}

resource "aws_iam_access_key" "authentik_ses" {
  user = aws_iam_user.authentik_ses.name

  depends_on = [aws_iam_user_policy_attachment.authentik_ses]
}

resource "aws_ssm_parameter" "authentik_ses_username" {
  name             = "${local.authentik_ssm_prefix}/ses/username"
  type             = "SecureString"
  value_wo         = aws_iam_access_key.authentik_ses.id
  value_wo_version = 1
}

resource "aws_ssm_parameter" "authentik_ses_password" {
  name             = "${local.authentik_ssm_prefix}/ses/password"
  type             = "SecureString"
  value_wo         = aws_iam_access_key.authentik_ses.ses_smtp_password_v4
  value_wo_version = 1
}

resource "aws_ssm_parameter" "authentik_secret_key" {
  name             = "${local.authentik_ssm_prefix}/secret-key"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.authentik_secret_key.result
  value_wo_version = 1
}

resource "aws_ssm_parameter" "authentik_bootstrap_token" {
  name             = "${local.authentik_ssm_prefix}/bootstrap-token"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.authentik_bootstrap_token.result
  value_wo_version = 1
}
