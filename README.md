# Terraform IaC simple infrastructure with GitHub Actions

By  `B-O-W` with help `Graypit`

![Untitled](Terraform%20IaC%20simple%20infrastructure%20with%20GitHub%20Ac%2058bb1b8160194bad875a5685604d5bb1/Untitled.png)

![Untitled](Terraform%20IaC%20simple%20infrastructure%20with%20GitHub%20Ac%2058bb1b8160194bad875a5685604d5bb1/Untitled%201.png)

Prerequisites

The tutorial assumes some basic familiarity with Kubernetes and `kubectl` but does not assume any pre-existing deployment.

It also assumes that you are familiar with the usual Terraform plan/apply workflow. If you're new to Terraform itself, refer first to the Getting Started [tutorial](https://learn.hashicorp.com/collections/terraform/aws-get-started).

For this tutorial, you will need:

- an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
- the AWS CLI, [installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- the [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/), also known as `kubectl`

****1. Create Kubernetes Cluster with Terraform****

The configuration is organized across multiple files:

1. `[versions.tf](https://learn.hashicorp.com/tutorials/terraform/eks#versions-tf)` sets the Terraform version to at least 1.2. It also sets versions for the providers used by the configuration.
2. `[variables.tf](https://learn.hashicorp.com/tutorials/terraform/eks#variables-tf)` contains a `region` and `clustername`variable that controls where to create the EKS cluster
3. `[vpc.tf](https://learn.hashicorp.com/tutorials/terraform/eks#vpc-tf)` provisions a VPC, subnets, and availability zones using the [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.32.0). The module creates a new VPC for this tutorial so it doesn't impact your existing cloud environment and resources.
4. `[security-groups.tf](https://learn.hashicorp.com/tutorials/terraform/eks#security-groups-tf)` provisions the security groups the EKS cluster will use it’s dynamic SG
5. `[eks-cluster.tf](https://learn.hashicorp.com/tutorials/terraform/eks#eks-cluster-tf)` uses the [AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/11.0.0) to provision an EKS Cluster and other required resources, including Auto Scaling Groups, Security Groups, IAM Roles, and IAM Policies.

Open the `eks-cluster.tf`
 file to review the configuration. The `worker-groups`
 parameter will create three nodes across one node group.

```jsx
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.medium"
      additional_userdata           = "test-eks-aws"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
```

## 2.Configure kubectl

Now that you've provisioned your EKS cluster, you need to configure `kubectl`.

First, open the `outputs.tf` file to review the output values. You will use the `region` and `cluster_name` outputs to configure `kubectl`.

outputs.tf

```json
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}
```

Run the following command to retrieve the access credentials for your cluster and configure `kubectl`.

***P.S THIS COMMAND WORK ONLY AFTER TERRAFORM APPLY***

```bash
$ aws eks --region $(terraform output -raw region) update-kubeconfig \    --name $(terraform output -raw cluster_name)
```

You can now use `kubectl` to manage your cluster and deploy Kubernetes configurations to it.

## ****Useful Documentation:****

[Provision an EKS Cluster (AWS) | Terraform - HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/eks)
