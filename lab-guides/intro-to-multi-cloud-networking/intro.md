Introduction to the Lab
=======================

During the lab, you will be emulating a customer that needs to expose an application running in AWS and Azure. The goal is to securely connect the application services between cloud environments. The frontend demo application runs on an AWS EC2 instance and is exposed to the internet. The backend demo application runs on an Azure VM instance, and it is internal only.

Narrative
---------

In this example we are starting with an application running in AWS.

![intro1.png](./images/intro1.png)

The "frontend" application has a requirement that it must be able to communicate with the "backend". The "backend" could be a database legacy system, etc.

The goal is to extend the environment into Azure and still allow the AWS "frontend" to connect to the Azure "backend". The following topology illustrates Distributed Cloud Mesh nodes deployed in both AWS and Azure environments as well as backend NGINX web servers running a simple demo application.

![intro2.png](./images/intro2.png)

Once the AWS and Azure cloud environments are ready, you will deploy Distributed Cloud Mesh sites in both clouds. Then you create an F5 Distributed Cloud HTTP Load Balancer to allow clients to connect publicly from a Regional Edge (AnyCast IP) to the AWS "frontend". Next you will utilize an F5 Distributed Cloud TCP Load Balancer to privately connect from AWS "frontend" to Azure "backend".

![intro3.png](./images/intro3.png)

Lab Environment - Next Steps
----------------------------

The AWS and Azure cloud environments have been pre-built already. They have Ubuntu VM instances running Docker with NGINX containers for the demo app (frontend/backend) and diagnostics app (client).

  - **[Module 1: Creating a Site (Simulator)](module1)**
  - **[Module 2: Create Load Balancer Resources](module2)**
