# Lab Overview

## Terraform Deploy Guide

Set AWS Profile env variable to account you wish to deploy resources using command:

```
export AWS_PROFILE=<-- your sso config name -->
```

On first-time deployment into a new account, run the terraform module in the bootstrap directory to create your state bucket and dynamodb locking table (which you can then reference in your backend config)

Layers should be deployed in the order: Base -> App.

### Base Layer

```
cd terraform/layers/base
terraform init --reconfigure --backend-config="../../environment/dev/base/base.s3.tfbackend"
terraform apply --var-file="../../environment/dev/base/terraform.tfvars"
```

### App Layer

```
cd terraform/layers/app
terraform init --reconfigure --backend-config="../../environment/dev/app/app.s3.tfbackend"
terraform apply --var-file="../../environment/dev/app/terraform.tfvars"
```
