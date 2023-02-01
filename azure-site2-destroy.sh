#!/bin/bash
terraform -chdir=azure-site2 destroy -var-file=../admin.auto.tfvars \
    -var buildSuffix=`terraform output -json | jq -r .buildSuffix.value` \
    -var volterraVirtualSite=`terraform output -json | jq -r .volterraVirtualSite.value`
