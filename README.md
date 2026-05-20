# infra-vm-workloads

Provisions LZ workload VMs on Proxmox and bootstraps the k3s cluster and Argo CD baseline used to deploy Kubernetes manifests.

## Scope
- Owns: OpenTofu resources for workload VMs, SSH/Git deploy key material, and SSM parameters used by cluster automation.
- Owns: Ansible bootstrap and apply flow for k3s installation and Argo CD baseline manifests.

## Structure
- `src/tf/`: Provisions Proxmox VMs and emits Terraform-backed Ansible inventory data.
- `src/ansible/`: Installs k3s (`bootstrap.yml`) and applies Argo CD/bootstrap manifests (`apply.yml`).
- `.github/workflows/`: Terraform plan/apply and Ansible lint/manual execution workflows.

## Run
```bash
make help
make tf-init
make tf-plan
make tf-apply
make ansible-install
make ansible PLAYBOOK=bootstrap.yml
make ansible PLAYBOOK=apply.yml
```

## Operational order
- Apply Terraform first to create VMs and write required SSM parameter paths.
- Run `bootstrap.yml` before `apply.yml` so k3s is present before Argo CD manifests are applied.
- Add `git_deploy_public_key` output as a read-only deploy key in [`glitchedmob/infra-k8s-apps`](https://github.com/glitchedmob/infra-k8s-apps).
- Update the SSM parameters at `argocd_github_oauth_client_id_ssm_path` and `argocd_github_oauth_client_secret_ssm_path` with valid GitHub OAuth App credentials for Argo CD SSO.

## Operating constraints
- This repo mixes infrastructure provisioning and cluster bootstrap; run Terraform and Ansible steps intentionally and in order.
- Argo CD must be running before the root Application can sync manifests from `infra-k8s-apps`.
- Initial admin password can be retrieved with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`.