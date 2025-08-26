This is a comprehensive guide to implementing a multi-environment web application infrastructure with Auto-Scaling on Google Cloud Platform (GCP).

# GCP Services

| VPC | Subnets: VPC  Subnets are the foundational network. |
| :------ | :----------: |
| Internet Gateway | Cloud Router & Cloud NAT |  Manages egress and ingress for subnets. |
| NAT Gateway | Cloud NAT	allows private instances to access the internet. |
| Application Load Balancer (ALB) | 	HTTP(S) Load Balancer or Internal Application Load Balancer	Distributes traffic to instances. | 
| EC2 Instances	Compute Engine (GCE) | The virtual machines that run your application. |
| Auto Scaling Group (ASG)	Instance Group Manager (MIG) | Manages a group of identical VMs and handles auto-scaling. |
| Launch Template	Instance Template | Defines the configuration for new VMs (machine type, image, startup script). |
| Cloud SQL for MySQL | The fully managed relational database service. |
| Security Groups/Firewall Rules | For controlling traffic to/from resources. |
| CloudWatch	Cloud Monitoring | For monitoring metrics and creating alerts. |
| SNS	Cloud Pub/Sub | For sending alert notifications. |


## Solution Architecture Overview on GCP:

    A[Internet] --> B(Google HTTP(S) Load Balancer (Global))
    B --> C(Backend Service (Managed Instance Group))
    C --> D(Managed Instance Group (MIG) [Auto-Scaling])
    D --> E(VMs in private subnets across zones)
    E --> F(Cloud SQL for MySQL (Private IP in the same VPC))

  ## Connect project to GCP  
To connect your project with your Google Cloud, run `gcloud auth login`. This should provide your project info then you can set your project with `gcloud config set project PROJECT_ID`. Alternatively, you can authenticate with `gcloud auth application-default login` or `gcloud auth application-default login  --no-browser`<br><br><br>
<img width="1615" height="208" alt="image" src="https://github.com/user-attachments/assets/28d951ca-c151-4520-9355-30560010c316" />

## Initialize Terraform for dev environment
<img width="1386" height="273" alt="image" src="https://github.com/user-attachments/assets/d125a1eb-14dd-4d31-97e3-92c1a45db801" />

## Terraform plan
<img width="1514" height="842" alt="image" src="https://github.com/user-attachments/assets/359bdb4e-b980-440a-bbb2-4d15ab02e93a" /> <br>

<img width="813" height="728" alt="image" src="https://github.com/user-attachments/assets/a825c83c-98a8-47c1-a4d6-ccfcb2f06334" /> <br>


<img width="1644" height="818" alt="image" src="https://github.com/user-attachments/assets/c32958a1-e2bc-4822-9333-27d28b9ba541" /><br>

## output Terraform plan in an output file

`terraform plan -out=tfplan` 
This saves the plan in a binary format, and can be directly used with `terraform apply` to ensure the exact planned changes are applied <br>

To make the file human-readable, you can use `terraform show tfplan > tfplan.txt` <br>
<img width="1848" height="1032" alt="image" src="https://github.com/user-attachments/assets/1cc7aabb-1b2c-4658-a05b-dfc153fa1241" />

## Initialize Terraform for the prod environment and Terraform plan in an output file
`terraform plan -out=tfplan` and 
`terraform plan -no-color > output.txt`

<img width="1865" height="1052" alt="image" src="https://github.com/user-attachments/assets/b6108c18-b05e-4193-ba33-9fe31d11f33f" />







