
# Provider - is like importing a library 
# Resource - is like calling a function from that library that creates something
# Data - is like calling a function that returns something


# Steps # 

1. Connect to AWS using provider:
    - list of providers : https://registry.terraform.io/browse/providers
    - Aws provider doc : https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    - Add access key and secret to env (picked automatically by tf) : 
        https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
    - for unnoficial providers, its a good practice to create a providers.tf file and define the provider using the block 
        terraform {
            required_providers {

            }
        }


2. Add the credentials to the env as env var it will be accessed automatically by TF  : 
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY

3. Create VPC 
    - One vpc should exist for each region 
    - vpc is your won isolated network in cloud 
    - spans all the AZs in a region 
    - internal range of IPs


    - Subnet : private network inside a vpc network
        - Defined one for each AZ 
        - sub range within the range of the IPs for a vpc 
        - Define NACL per subnet for access control (firewall)
        - define a "security group" per server instance or component for access control 
    
4. Data sources : https://developer.hashicorp.com/terraform/language/data-sources
    - create reference to resources using specific attributes
    - to query their attributes later using data.<reference name>

5. Destroying 
    - approach 1 : remove the corresponding block and apply (preferred)
    - approach 2 : terraform destroy -target <resource type>.<resource name>

6. Output : https://developer.hashicorp.com/terraform/language/values/outputs#declaring-an-output-value

7. Custom Var file : For non default var file names - terraform apply -var-file terraform-dev.tfvars
    - usually each environment has its var file dev / stg / prod 

8. Traffic handling :  
    - Internet gateway (takes vpc id): subnets are exposed to the outer world via IG, each VPC has a IG 
    - Route Table (takes ig id): Virtual router for each IG that determines the route of the traffic from an IG to a subnet
    - Route table association (takes subnet id, rt id): Each subnet need to be associated with the route table
    
    - Security Group : Used for a component or instance 
        - ingress : used for incoming traffic - ssh and browser 
        - outgress : 
    







