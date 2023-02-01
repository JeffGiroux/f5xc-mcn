#!/bin/bash
terraform -chdir=azure-site2 init
terraform -chdir=azure-site2 apply -var-file=../admin.auto.tfvars \
    -var buildSuffix=`terraform output -json | jq -r .buildSuffix.value` \
    -var volterraVirtualSite=`terraform output -json | jq -r .volterraVirtualSite.value` \
