# AWS Multi-Cloud module

This module will create a set of F5 Distributed Cloud (XC) Nodes and AWS resources.

## Requirements

- AWS CLI
- Terraform
- AWS access and secret key
- F5 Distributed Cloud account and credentials

## Login to AWS Environment

- Open a terminal
- Set AWS environment variables - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
```bash
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

## Create F5 XC Cloud Credentials for AWS

- Set F5 XC Cloud credentials - https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials
1. Go to the "System" namespace > "Manage" -> "Site Management" -> "Cloud Credentials"
2. Click on "Add Cloud Credential"
3. For the name enter "[unique-name]-aws".
4. For the Cloud Credential Type: "AWS Programmatic Access Credentials" and enter the values from your AWS access key and secret access key
- Access Key ID: This is your IAM user access key (reference AWS_ACCESS_KEY_ID)
- Secret Access Key: This is your IAM user secret access key (reference AWS_SECRET_ACCESS_KEY)
5. Under Secret Access Key click on "Configure"
6. Enter the value from environment variable AWS_SECRET_ACCESS_KEY and then click on "Blindfold"

## Usage Example

See parent [README Usage Example](../README.md#usage-example), then come back here to test.

## Test Your Setup

TBD...
Browse to the NGINX application server public IP (see Terraform output). The splash page will resolve with a customized NGINX page displaying cloud provider name, region, and zone.

![NGINX app](../images/nginx-app.png)

## Cleanup

See parent [README Cleanup scripts](../README.md#cleanup).
