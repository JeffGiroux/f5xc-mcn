Lab 1: Creating a Site (Simulator)
==================================

F5 Simulators
-------------

F5 provides "simulations" of its services via "F5 Simulators". You will first use the Distributed Cloud Simulator to familiarize yourself with the environment. Later in the lab, you will use a shared lab environment to let you interact with a "live" system.

> For demo purposes, the F5 Distributed Cloud nodes in AWS and Azure have been pre-built. This is to simplify the lab and avoid the requirement for user to need public cloud credentials. In addition, it helps with overall lab clean up of F5 Distributed Cloud resources.


Exercise #1
-----------

Please visit: https://simulator.f5.com/s/cloud2cloud_via_httplb/nav/sim1/020/0


Note that you will need to pay attention for fields that are highlighted. Some of them like "Show Advanced Fields" may appear on the bottom right of the screen.

![f5-simulator-show-advanced-fields.png](../images/f5-simulator-show-advanced-fields.png)

You can opt to fill in the form fields or you can click on the "Next" button to allow the simulator to fill-in the fields as required. Note that all of these actions can also be performed via the Distributed Cloud API.

![f5-simulator-next.png](../images/f5-simulator-next.png)

You will first simulate creating an AWS Site, then hit "Apply".

![f5-simulator-apply-site.png](../images/f5-simulator-apply-site.png)

Then you will simulate creating an Azure Site. Stop when you reach the step of clicking on "Apply" after creating your Azure Site.

Congratulations you just simulated deploying your AWS Site and Azure Site via the Distributed Cloud Console. In the next Lab Exercise we will be creating Load Balancer resources in the "Live" lab environment.

Next
----

  - **[Module 2: Create Load Balancer Resources](../module2)**
