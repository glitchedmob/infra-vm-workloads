data "aws_caller_identity" "current" {}

locals {
  lz_k3s_oidc_issuer           = "k8s-oidc-lz.levizitting.com"
  lz_k3s_external_secrets_role = "lz-k3s-external-secrets"
  lz_k3s_openbao_role          = "lz-k3s-openbao"

  lz_k3s_oidc_provider_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.lz_k3s_oidc_issuer}"
  lz_k3s_workload_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/lz-k3s/LZK3sKubernetesWorkloadBoundary"
  lz_k3s_ssm_parameter_arn     = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/vm-workloads/lz/infra-vm-workloads/*"
  external_secrets_subject     = "system:serviceaccount:external-secrets:external-secrets"
  openbao_subject              = "system:serviceaccount:openbao:openbao"
}

resource "aws_iam_role" "external_secrets" {
  name                 = local.lz_k3s_external_secrets_role
  path                 = "/lz-k3s/"
  permissions_boundary = local.lz_k3s_workload_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.lz_k3s_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.lz_k3s_oidc_issuer}:aud" = "sts.amazonaws.com"
            "${local.lz_k3s_oidc_issuer}:sub" = local.external_secrets_subject
          }
        }
      }
    ]
  })

  tags = {
    KubernetesNamespace      = "external-secrets"
    KubernetesServiceAccount = "external-secrets"
    ManagedBy                = "OpenTofu"
    Repository               = "glitchedmob/infra-vm-workloads"
  }
}

resource "aws_iam_role_policy" "external_secrets" {
  name = "ReadVMWorkloadParameters"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
        Resource = local.lz_k3s_ssm_parameter_arn
      },
    ]
  })
}

resource "aws_iam_role" "openbao" {
  name                 = local.lz_k3s_openbao_role
  path                 = "/lz-k3s/"
  permissions_boundary = local.lz_k3s_workload_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.lz_k3s_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.lz_k3s_oidc_issuer}:aud" = "sts.amazonaws.com"
            "${local.lz_k3s_oidc_issuer}:sub" = local.openbao_subject
          }
        }
      }
    ]
  })

  tags = {
    KubernetesNamespace      = "openbao"
    KubernetesServiceAccount = "openbao"
    ManagedBy                = "OpenTofu"
    Repository               = "glitchedmob/infra-vm-workloads"
  }
}

resource "aws_iam_role_policy" "openbao" {
  name = "ReadVMWorkloadParameters"
  role = aws_iam_role.openbao.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
        Resource = local.lz_k3s_ssm_parameter_arn
      },
    ]
  })
}
