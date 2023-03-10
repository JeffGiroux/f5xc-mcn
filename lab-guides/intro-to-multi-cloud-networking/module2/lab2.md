Lab 2: Create HTTP Load Balancer
================================

In this exercise, you will create an HTTP Load Balancer that allows you to access the public AWS "frontend" application and explore the AWS environment. You also connect to a private AWS EC2 instance via a secure tunnel through an F5 Distributed Cloud Mesh node, which exposes a "diagnostics" app to simulate an internal AWS client. The "diagnostics" app will be used in the next lab to connect to the Azure "backend".

You will complete the following tasks:
- Create an Origin Pool for the AWS "frontend"
- Create an HTTP Load Balancer and expose the "frontend" on F5 Distributed Cloud's Regional Edge
- Test "frontend" URL with web browser
- Create an Origin Pool for the AWS "diagnostics"
- Create an HTTP Load Balancer and expose the "diagnostics" on F5 Distributed Cloud's Regional Edge
- Test "diagnostics" URL with web browser
- Review Monitoring and Analytics

![intro3.png](../images/intro3.png)

*Logical Traffic Flow*
1. Client connects to HTTP LB deployed in Regional Edge
2. Connection forwarded to F5 node in AWS site via IPSEC tunnels
3. F5 node forwards traffic to "frontend"
4. AWS "frontend" connects to Azure "backend" via TCP LB deployed in AWS site
5. Connection forwarded from AWS F5 node to Azure F5 node via F5 Distributed Cloud Global Network
6. Azure F5 node forwards traffic to "backend"

Regional Edge
---------------------------------------------------

A Regional Edge (RE) is part of the F5 Distributed Cloud Global Network and provides connectivity to services. Previously when you deployed the AWS and Azure sites (via F5 Simulator), those are considered "Customer Edge (CE)" sites running on [F5 Nodes](https://docs.cloud.f5.com/docs/ves-concepts/site). The CE communicates with the RE via IPSEC/SSL tunnels (redundant), and each CE is associated with 2x RE for redundancy.

Exercise 1:  Frontend Origin Pool
---------------------------------------------------
The first task is to create an Origin Pool that refers to the "frontend" application service running in the AWS site. You will demonstrate how to securely connect to the private AWS resource with an F5 Distributed Cloud Mesh node running in the AWS site.

1. Using the Distributed Cloud Console, switch to the "Load Balancers" context. It can be accessed either from the Home page or the internal page.

<img src=../images/choosing-service-lb.png width="50%">

2. On the left menu, go to "Manage"->"Load Balancers"->"Origin Pools". Click "Add Origin Pool".

<img src=../images/menu-origin-pool.png width="50%">

3. Enter the following variables in the *Metadata* section:

| Variable | Value |
| --- | --- |
| Name | frontend |

4. Click on "Add Item" under Origin Servers.

5. Enter the following information:

| Variable | Value |
| --- | --- |
| Select Type of Origin Server | IP address of Origin Server on given Sites |
| IP | 10.1.52.200 |
| Site | system/q2lw-aws-c8e4 |
| Select Network on the site | Inside Network |

<img src=../images/pool-aws-private.png width="50%">

6. Click "Apply" to return to the previous screen.
7. Enter "80" for the *Port*.
8. Under the *Health Checks* section, click "Add Item".
9. Click the *Health Check object* dropdown list and choose "Add Item".
10. Enter the following variables in the *Metadata* section:

| Variable | Value |
| --- | --- |
| Name | http |

11. Under *HTTP HealthCheck*, click "View Configuration".
12. Leave the default values and click "Apply" to return to the previous screen.
13. Click "Continue" to return to the *Origin Pool* configuration.
14. Click "Save and Exit" to create the Origin Pool.

Exercise 2: Frontend HTTP Load Balancer
---------------------------------------

1. On the left menu, go to "Manage"->"Load Balancers"->"HTTP Load Balancers". Click "Add HTTP Load Balancer".

<img src=../images/menu-http-lb.png width="40%">

2. Enter the following information:

*Note: Replace the host **\<adjective-animal\>** with your namespace (found in "Account Settings"...see [Module2>Lab1](lab1.md))*

| Variable | Value |
| --- | --- |
| Name | frontend |
| Domains | frontend.***\<adjective-animal\>***.sales-demo.f5demos.com |
| Select type of Load Balancer | HTTP |
| Automatically Manage DNS Records | Yes/Check |

<img src=../images/lb-frontend.png width="75%">

> My demo ephemeral namespace is "***protective-mouse***". Therefore my domain is "frontend.***protective-mouse***.sales-demo.f5demos.com".

3. Under the *Origin Pools* section, click "Add Item".
4. The method for "Select Origin Pool Method" should be "Origin Pool". Under the "Origin Pool" dropdown menu, select the "frontend" you created earlier.
5. Click "Apply" to return to the previous screen.
6. Back in the *HTTP Load Balancer* creation menu, scroll down to the section *Other Settings*.
7. The value "Internet" has been selected by default under "VIP Advertisement".

<img src=../images/lb-vip.png width="75%">

8. Click "Save and Exit" to create the HTTP Load Balancer.

Once the HTTP Load Balancer has been deployed, you can use a web browser to access the AWS "frontend". The FQDN used in our example is http://frontend.protective-mouse.sales-demo.f5demos.com. Your FQDN should follow the format of *frontend.****[unique-namespace]****.sales-demo.f5demos.com*.

The public demo app should look like the following:

<img src=../images/public-vip-frontend.png width="100%">

In this topology, you are sending traffic to an AnyCast IP that is hosted in the F5 Distributed Cloud RE. The RE communication to the AWS site is via IPSEC tunnels to the F5 node. Finally, traffic is forwarded from the F5 node to the "frontend" AWS instance's private IP address.

Exercise 3: Diagnostics Origin Pool
-----------------------------------

In this exercise, you will create a new Origin Pool that contains the "diagnostics" application running in AWS. This tool will allow testing from within AWS like an "internal client" in the VPC.

1. On the left menu, go to "Manage"->"Load Balancers"->"Origin Pools". Click "Add Origin Pool".

2. Enter the following variables in the *Metadata* section:

| Variable | Value |
| --- | --- |
| Name | diagnostics |

3. Click on "Add Item" under Origin Servers.

4. Enter the following information:

| Variable | Value |
| --- | --- |
| Select Type of Origin Server | IP address of Origin Server on given Sites |
| IP | 10.1.52.200 |
| Site | system/q2lw-aws-c8e4 |
| Select Network on the site | Inside Network |

<img src=../images/pool-aws-private.png width="50%">

5. Click "Apply" to return to the previous screen.
6. Enter "8080" for the *Port*.
7. Under the *Health Checks* section, click "Add Item".
8. Click the *Health Check object* dropdown list and choose "Add Item".
9. Enter the following variables in the *Metadata* section:

| Variable | Value |
| --- | --- |
| Name | http-diag |

10. Under *HTTP HealthCheck*, click "View Configuration".
11. Enter "/diag" for *Path*.
12. Click "Apply" to return to the previous screen.
13. Click "Continue" to return to the *Origin Pool* configuration.
14. Click "Save and Exit" to create the Origin Pool.

Exercise 4: Diagnostics HTTP Load Balancer
------------------------------------------

1. On the left menu, go to "Manage"->"Load Balancers"->"HTTP Load Balancers". Click "Add HTTP Load Balancer".

2. Enter the following information:

*Note: Replace the host **\<adjective-animal\>** with your namespace (found in "Account Settings"...see [Module2>Lab1](lab1.md))*

| Variable | Value |
| --- | --- |
| Name | diagnostics |
| Domains | diagnostics.***\<adjective-animal\>***.sales-demo.f5demos.com |
| Select type of Load Balancer | HTTP |
| Automatically Manage DNS Records | Yes/Check |

<img src=../images/lb-diagnostics.png width="75%">

> My demo ephemeral namespace is "***protective-mouse***". Therefore my domain is "diagnostics.***protective-mouse***.sales-demo.f5demos.com".

3. Under the *Origin Pools* section, click "Add Item".
4. The method for "Select Origin Pool Method" should be "Origin Pool". Under the "Origin Pool" dropdown menu, select the "diagnostics" you created earlier.
5. Click "Apply" to return to the previous screen.
6. Back in the *HTTP Load Balancer* creation menu, scroll down to the section *Other Settings*.
7. The value "Internet" has been selected by default under "VIP Advertisement".

<img src=../images/lb-vip.png width="75%">

8. Click "Save and Exit" to create the HTTP Load Balancer.

You now have access to the "diagnostics" app running inside the AWS environment. You will use this in later labs to explore and run tests as an "internal client". The FQDN used in our example is http://diagnostics.protective-mouse.sales-demo.f5demos.com. Your FQDN should follow the format of *diagnostics.****[unique-namespace]****.sales-demo.f5demos.com*.

<img src=../images/public-vip-diagnostics.png width="75%">

Exercise 5: Review General Monitoring Stats
---------------------------------------------------

In the previous section, you demonstrated how to securely connect from the Internet to private resources inside your AWS site. No special public cloud provider knowledge was required! Next, you will review the built-in analytics of F5 Distributed Cloud platform.

> Note: Go explore!!!

1. On the left menu, go to "Virtual Hosts"->"HTTP Load Balancers" and click "Performance Monitoring" under the "frontend" HTTP LB.

<img src=../images/http_lb_stats1.png width="50%">

2. Review statistics on the *Dashboard* screen. Change the ***clock*** time filter in the upper right if needed (example "Last 1 hour").

<img src=../images/http_lb_stats2.png width="50%">

3. Click the *Request* tab to see the URL requests.

<img src=../images/http_lb_stats3.png width="75%">

4. Expand a request to see more details like full HTTP request, user agent, site location, and more.

<img src=../images/http_lb_stats4.png width="75%">

Next
----

  - **[Lab 3: Create TCP Load Balancer](lab3.md)**
  - **[Lab 4: Video Walk-Through (Optional)](lab4.md)**
