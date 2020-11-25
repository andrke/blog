# Distributed locust on AWS

## Prerequiments

* Terraform cli tool is installed

* Apply AWS credentials and set region

    `export AWS_ACCESS_KEY_ID="XX"`

    `export AWS_SECRET_ACCESS_KEY="XX"`

    `export AWS_SESSION_TOKEN="XX"`

    `export AWS_REGION="xx-xx-1`

* Ensure you have default VPC in place

## Run the code
* Replace your ssh public key into locust/master-key.pub
* Inizialize terrafrom module
    
    ``terraform init``
* Terrafrom Plan

    ``terraform plan``

* Terrafrom apply
    
    ``terraform apply``
    
* Follow the url 
        
        ....
        Outputs:

        locust_master_url = http://ec2-1-2-3-4.x-region-1.compute.amazonaws.com:8089/

        
        
   