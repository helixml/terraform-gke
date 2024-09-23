# terraform-gke-helix

Terraform GKE Helix Cluster

## Prerequisites

* Install `terraform`

```
brew install terraform
```

* Install `google-cloud-sdk` to get the `gcloud` CLI

```
brew install --cask google-cloud-sdk
```

* Ensure you have sufficient quota for an `L4` GPU. See the [GCP docs for more details](https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#gpu_quota).

## Setup

1. Clone this repository and cd into the directory:

```
git clone https://github.com/helixml/terraform-gke-helix.git
cd terraform-gke-helix
```

2. Log into GCP:

```
gcloud init
gcloud auth application-default login
```

3. Edit the configuration in the `terraform.tfvars` file to match your account.
4. Initialize the Terraform workspace:

```
terraform init
```

## Provision

Now deploy the infra.

```
terraform apply
```

## Configure Kubectl

```
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region) --project $(terraform output -raw project_id)
```

You may need to install [gke-gcloud-auth-plugin](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin) to gain access to the cluster.

## Install Helix

Now you can install Helix by following the [Helix Kubernetes installation documentation](https://docs.helix.ml/helix/private-deployment/manual-install/kubernetes/).

Here is some useful information when you configure the runner:

* the default GPU type in the `terraform.tfvars` is an L4 with 24GB GPU ram. So `--set runner.memory=24GB`.
* by default there's a single node with a GPU. So install everything on the same node (no selector) and `--set replicaCount=1`

For example:

```bash
export LATEST_RELEASE=$(curl -s https://get.helix.ml/latest.txt)
helm upgrade --install my-helix-runner helix/helix-runner \
  --set runner.host="my-helix-controlplane" \
  --set runner.token="oh-hallo-insecure-token" \
  --set runner.memory=24GB \
  --set replicaCount=1 \
  --set runner.axolotl="false" # Set to true if you have an Ampere class GPU \
  --set image.tag="${LATEST_RELEASE}"
```

## Access Helix

The default kubernetes installation is locked down. You can access Helix via port-forwarding from your machine.

```
kubectl port-forward svc/my-helix-controlplane 8080:80
```

And visit: [http://localhost:8080/](http://localhost:8080/)

Take a look at the [user documentation](https://docs.helix.ml/helix/getting-started/getting-started/) to learn how to use Helix.

## Delete the Cluster

```
terraform destroy
```
