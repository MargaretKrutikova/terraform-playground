# Commands

```
terraform --version
az version
```

# Vs Code

Extensions: HashiCorp Terraform, Azure terraform

# VM sizes

```
az account list-locations
az vm list-sizes --location norwayeast
```

Run:
```bash
terraform init # install azure provider
terraform plan -out=main.tfplan
terraform apply main.tfplan
```

# ssh

```
ssh -i ~\.ssh\azure_id_rsa adminuser@51.13.101.27
```

# OpenStack Nordlo

https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs