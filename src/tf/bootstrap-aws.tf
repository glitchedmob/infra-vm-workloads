resource "aws_iam_user" "bootstrap_reader" {
  name                 = "lz-k3s-bootstrap-reader"
  path                 = "/vm-workloads/lz/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/vm-workloads/lz/VMWorkloadsParameterReaderBoundary"

  tags = {
    ManagedBy  = "OpenTofu"
    Repository = "glitchedmob/infra-vm-workloads"
  }
}

resource "aws_iam_user_policy" "bootstrap_reader" {
  name = "ReadBootstrapIngressParameters"
  user = aws_iam_user.bootstrap_reader.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "ssm:GetParameter"
      Resource = [
        "arn:aws:ssm:us-east-2:${data.aws_caller_identity.current.account_id}:parameter/vm-workloads/lz/infra-vm-workloads/cloudflare-tunnel-token",
        "arn:aws:ssm:us-east-2:${data.aws_caller_identity.current.account_id}:parameter/vm-workloads/lz/infra-vm-workloads/crowdsec-traefik-bouncer-key",
      ]
    }]
  })
}

resource "aws_iam_access_key" "bootstrap_reader" {
  user = aws_iam_user.bootstrap_reader.name
}

resource "aws_ssm_parameter" "bootstrap_aws_access_key_id" {
  name  = "/vm-workloads/lz/infra-vm-workloads/bootstrap-aws/access-key-id"
  type  = "SecureString"
  value = aws_iam_access_key.bootstrap_reader.id
}

resource "aws_ssm_parameter" "bootstrap_aws_secret_access_key" {
  name = "/vm-workloads/lz/infra-vm-workloads/bootstrap-aws/secret-access-key"
  type = "SecureString"
  # IAM already stores the secret in encrypted state. Ordinary value follows key replacements.
  value = aws_iam_access_key.bootstrap_reader.secret
}
