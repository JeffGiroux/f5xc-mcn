Introduction to the Lab
=======================

During the lab, you will be viewing the deployed configuration of an F5 XC Console managed and orchestrated BIG-IP "External Site".

Lab Environment
---------------

- A BIG-IP which a single virtual server with an AWAF policy attached.
- An XC CE deployed using the XC AWS Transit Gateway Site type

is steering ingress traffic via a "Network Policy" (L3/L4) to the VIP through established IP in IP tunnels. 

> For demo purposes, the F5 Distributed Cloud Customer Edge and BIG-IP have been pre-built.

Narrative
---------

The F5 Distributed Cloud Console provides automation to simplify the integration of a BIG-IP into an XC AWS Transit Gateway topology.
Integration is accomplished through the use of TGW peering and IP in IP tunnels between the XC CE and the BIG-IP.

Both North/South and East/West traffic flows are easy to configure using the XC Console BIG-IP External Site type.

![intro1.png](./images/topology.png)

The deployed configuration represents a common North/South packet flow where traffic is ingressing via an AWS EIP to the XC CE.
An XC Network Policy is defined which steers traffic at the Network (L3/L4) Level to the BIG-IPs VIP through IP in IP tunnels.

The BIG-IPs serverside traffic egresses via the XC CE to its pool member -- in this case an application server in a peered VPC.

![intro2.png](./images/packet-flow.png)


Next Steps
----------------------------

  - **[Module 1: Creating a Site (Simulator)](module1)**
  - **[Module 2: Create Load Balancer Resources](module2)**