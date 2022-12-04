# EKS Cluster Deployment with new VPC

This repository a Basic EKS Cluster with VPC

- Creates a new sample VPC, 2 Private Subnets and 2 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with two managed node groups
- Creates a basic kubernetes deployment behind an nginx ingress controller

&nbsp;

## How to Deploy
---

### Prerequisites
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Minimum IAM Policy
> **Note**: The policy resource is set as `*` to allow all resources, this is *not* a recommended practice.

You can find the policy [here](min-iam-policy.json)

&nbsp;

### Deployment Steps
---
#### STEP 1: Clone the repo using the command below

```sh
git clone https://github.com/sttuartt/eks-demo.git
```

#### STEP 2: Configure local variables for remote state required resources

```sh
cd <repository_root>/remote_state
```

Edit the details in the `main.tf` file to set the following values as appropriate:
- aws_region
- random_string (ensures bucket name is unique)
- prefix (bucket name)
- ssm_prefix (used to store the bucket name and locks table arn)
- common_tags

#### STEP 3: Initialise, Plan, and Apply the Terraform code for remote state required resources
Run the following:
```
terraform init
terraform plan
terraform apply -auto-approve
```

#### STEP 4: Configure variables and s3 backend for VPC and EKS

```sh
cd <repository_root>/eks
```

Edit the details in the `variables.tf` file to set the cluster_name default value.  

Edit the details in the `versions.tf` file to set the values for the s3 backend:
- bucket (ensure random string in name matches that used in the remote_state deployment)
- key (state file name)
- region
- encrypt (boolean)
- dynamodb_table (ensure random string in name matches that used in the remote_state deployment)
> **Note**: These values should be taken from the output of the remote state backend configured in steps 1 and 2 above.

#### STEP 5: Initialise, Plan, and Apply the Terraform code for the VPC and EKS resources
Run the following (ensure you are still in the <repository_root>/eks directory):
```
terraform init
terraform plan
terraform apply -auto-approve
```
> **Note**: This will take approx. 15 minutes to provision

&nbsp;

### Configure `kubectl` and test cluster
---
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### STEP 1: Run the `update-kubeconfig` command

The `~/.kube/config` file is updated with cluster details and certificate by running the following command:

    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

    e.g.
    aws eks --region ap-southeast-2 update-kubeconfig --name demo-eks-cluster

#### STEP 2: List all the worker nodes by running the command below

    kubectl get nodes

#### STEP 3: List all the pods running in `kube-system` namespace

    kubectl get pods -n kube-system

&nbsp;

### Configure demo deployment, service, and ingress
---

#### STEP 1: Run the `kubectl apply` command to deploy 

```sh
cd <repository_root>/apps
kubectl apply -f http-echo.yaml
```

#### STEP 2: Check deployments

    kubectl get deployment http-echo

#### STEP 3: Check service

    kubectl get service http-echo-service

#### STEP 4: Check ingress

    kubectl get ingress http-echo

### STEP 5: Test service

Obtain the Address value from the last command, and perform a `curl` statement against it:
> **Note**: It might take a minute or so for the address to become available when running the previous command

    curl <Address>

    e.g.
    curl adc377573478043edbc909bac2cae94e-314602352.ap-southeast-2.elb.amazonaws.com

This should produce the following output:

    hello world

Navigating to this address in your browser should produce the same result

&nbsp;

## Cleanup
---

To clean up your environment, destroy deployments and resources in the reverse order

1. 
    ```sh
    cd <repository_root>/apps
    kubectl delete -f http-echo.yaml
    ```
1. 
    ```sh
    cd <repository_root>/eks
    terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
    terraform destroy -target="module.eks_blueprints" -auto-approve
    terraform destroy -auto-approve
    ```
    > **Note**: The destroy task is split up to avoid `Error: context deadline exceeded` errors
1. 
    ```sh
    cd <repository_root>/remote_state
    terraform destroy -auto-approve
    ```