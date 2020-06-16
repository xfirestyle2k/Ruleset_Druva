# Terraform automated Ruleset for Druva Phoenix

First of all, all my test ran at a lab platform… Use following code at your own risk, I won't be responsible for any issues you may run into. Thanks!

In this repository I created a automated Ruleset for Druva Phoenix Cloud

To get familiar with VMC and VMC NSX-T I highly recommend to take a look on the Blog posts from Nicolas Vibert:
https://nicovibert.com or https://www.securefever.com/blog/terraform-blueprint-for-a-horizon7-ruleset-with-vmc-on-aws

# About the code

This Terraform code apply Groups, Services and Distributed Firewall Rules. Following will be created:

Groups for Druva Proxy, Druva Cache and RFC_1918 (private IP-Ranges) and SQL-Server.

Service for SQL restore TCP 3542.

Distributed Firewall Section with 4 Allow Rules and 2 disabled deny rules.

Clone this repo and create a new file, name it "terraform.tfvars" and save it to the same Folder. For NSX-T we only need 3 variables.

Host = "nsx-X-XX-X-XX.rp.vmwarevmc.com/vmc/reverse-proxy/api/orgs/84e"

vmc_token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

org-id = "XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX"

Fill this file and install Terraform.

open a console, navigate to the directory, terraform init, terraform apply.

After 5 seconds you will have a fully working Ruleset for Druva Phoenix Cloud.
Only step remaining, fill the created groups Druva Proxy, Druva Cache and SQL-Server.
Currently it is not possible to create MGW or CGW Rules, as soon as it possible I will add it to the code.

# Support

if you have any problems with the script, you always can reach out to me and I will try to support and help you as soon as possible!
