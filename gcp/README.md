# Google Multi-Cloud module

This module will create a set of F5 Distributed Cloud (XC) Nodes in Google resources.

## Requirements

- Google gcloud CLI
- Terraform
- Google IAM Service Account
- F5 Distributed Cloud account and credentials

## Login to Google Environment

- Open a terminal
- Run the gcloud commands
```bash
# Login
gcloud init

# Show config
gcloud config list
```

## Create Google Service Account

F5 XC will create resources and need access to your Google project. If you already have a service account, you can use it. Otherwise you can follow these steps to create one. Reference [Creating IAM Service Accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts#iam-service-accounts-create-console).

> Note: You must have an "Editor" role within your Google project to create a service account.

1. From the Google Console, navigate to IAM > Service Accounts.

2. Create an account with the following roles:
- Compute Admin
- DNS Administrator
- Service Account Admin
- Service Account User
- Project IAM Admin
- Secret Manager Admin
- Storage Admin

3. Upon save, you will be directed back to Service Account page. Find and select your new service account to edit it.
4. Click the 'Key' tab to create a new key.
5. Choose JSON format. The file will be saved as JSON to your computer.
6. Copy the JSON output (starting with "{" ending with "}") of this command and keep it safe. This credential enables read/write access to your Google Project.
7. Add service account credentials to your Terraform environment. See the [Terraform Google Provider "Adding Credentials"](https://www.terraform.io/docs/providers/google/guides/getting_started.html#adding-credentials).

> Note: At a high level, you are creating an environment variable that points to the newly downloaded JSON file.

## Create F5 XC Cloud Credentials for Google

- Set F5 XC Cloud credentials - https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials
1. Go to the "System" namespace > "Manage" -> "Site Management" -> "Cloud Credentials"
2. Click on "Add Cloud Credential"
3. For the name enter "[unique-name]-gcp"
4. For the Cloud Credential Type: "GCP Credentials" and enter the contents of the IAM service account JSON key file. Example...
```
{
  "type": "service_account",
  "project_id": "f5-project123",
  "private_key_id": "abcxyz",
  "private_key": "-----REDACTED=\n",
  "client_email": "",
  "client_id": "123456",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": ""
}
```
5. Click on "Blindfold" and save changes

## Usage Example

See parent [README Usage Example](../README.md#usage-example), then come back here to test.

## Test Your Setup

TBD...
Browse to the NGINX application server public IP (see Terraform output). The splash page will resolve with a customized NGINX page displaying cloud provider name, region, and zone.

![NGINX app](../images/nginx-app.png)

## Cleanup

See parent [README Cleanup scripts](../README.md#cleanup).
