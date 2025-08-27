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


## create infrastructure

Run `terraform apply`
You might encounter this error message, follow the URL and enable API & Services for Service Networking API and Compute Engine API <br>
<img width="1494" height="686" alt="image" src="https://github.com/user-attachments/assets/59d8d8f6-f31b-4267-8a20-181baebd5d07" /><br>

<img width="1804" height="1039" alt="image" src="https://github.com/user-attachments/assets/719a599a-7103-401c-9670-86583bc664e2" />



## Monitoring on instances
Follow through the official Google Docs to create monitoring and alerting `https://cloud.google.com/logging/docs/logs-based-metrics/charts-and-alerts#alert-on-lbm` <br><br>
<img width="2926" height="1082" alt="image" src="https://github.com/user-attachments/assets/d682b633-f330-4a33-96c8-c14151c1c4b5" /> <br>

<img width="2896" height="1074" alt="image" src="https://github.com/user-attachments/assets/2e41bb58-1ca8-45d8-b485-e77c985229f9" /><br>

## create Logs Alert <br><br>
From Logs Explorer in the GCP console
<img width="1907" height="525" alt="image" src="https://github.com/user-attachments/assets/f2f5d084-8815-40c5-9be9-668e601c960d" /><br><br>

<img width="466" height="954" alt="image" src="https://github.com/user-attachments/assets/c0a4d74a-514b-4a93-b66b-d5552f20cf27" /><br><br>
<img width="1020" height="957" alt="image" src="https://github.com/user-attachments/assets/8f2ac62a-9a0a-4a01-8865-68eef0926453" /><br><br>

<img width="762" height="362" alt="image" src="https://github.com/user-attachments/assets/13e2189e-e5b9-4241-877f-6f28d53c7033" /><br><br>

## Log-based metric alert
<img width="1914" height="703" alt="image" src="https://github.com/user-attachments/assets/2e0b7477-5f17-4817-bddb-f0124f602d91" /> <br><br>
<img width="1095" height="921" alt="image" src="https://github.com/user-attachments/assets/085642d2-70d3-49a3-8fe2-b4784a4ce21e" /><br><br>
<img width="1853" height="506" alt="image" src="https://github.com/user-attachments/assets/0bc40bfa-a85f-4f44-8f66-1674a66e9fd6" /> <br><br>


Accessing instances<br>
<img width="1492" height="502" alt="image" src="https://github.com/user-attachments/assets/c65397fb-fbfc-4b94-b575-48636babf064" /><br>
<img width="1502" height="974" alt="image" src="https://github.com/user-attachments/assets/7085a85f-cb48-4b45-a4c1-c9963e86da02" /><br>


## Created Database <br>
<img width="1686" height="584" alt="image" src="https://github.com/user-attachments/assets/0af1e6dc-0d05-498f-a965-4a1c29be069a" /> <br>
<img width="2658" height="822" alt="image" src="https://github.com/user-attachments/assets/fbc80c32-138f-40ac-9afd-5c55e6243f8c" /><br>

## Managed Instance Group <br>
<img width="1860" height="1238" alt="image" src="https://github.com/user-attachments/assets/073f38de-020d-45cf-b08d-bc6f28e12665" /> <br>
## Load Balancing framework<br>
<img width="2752" height="506" alt="image" src="https://github.com/user-attachments/assets/29461cb5-bfc9-4c79-badc-cf2c0cd86325" /><br>
## Switching between instances using the load balancer IP<br>
<img width="2234" height="1520" alt="image" src="https://github.com/user-attachments/assets/febd7fc5-e5f0-4dce-8534-1846d26b4e0e" /><br>

<img width="1340" height="452" alt="image" src="https://github.com/user-attachments/assets/d28105f4-c9c9-412d-9c7b-4c33dbef0b52" /> <br>
<img width="1082" height="338" alt="image" src="https://github.com/user-attachments/assets/7d84da16-0842-4aa4-8905-1b732a476f4b" /> <br>

## Terraform Destroy<br>
<img width="1804" height="543" alt="image" src="https://github.com/user-attachments/assets/6de7e995-5b2e-4a56-8584-d5b326c3e3e9" />











