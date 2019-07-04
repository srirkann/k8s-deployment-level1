# K8s Deployment-Level1

### Description:
The repo contains a set of ansible scripts to deploys a cluster in Google Kubernetes Engine(GKE) and perform the following tasks.
  1.  Created a GKE cluster with the name defined in the inventory file
  2.  Configure the kubectl client
  3.  Deploys NGINX as ingress controller
  4.  Create two namespaces Production and Staging
  5.  Deploys guestbook application in both the namespaces
  6.  Configures ingress resources so that the guestbook application from both the namespaces are accessible from outside at a time.
  7.  Create Horizontal pod autoscaler for both application with autoscaling up to 5 on 20% cpu load.
  
The repo also contains a Dockerfile for building a docker image which wraps up all the scripts to perform a single click deployment. 

### Pre-Requisite
The following list of task to be done before you begin the deployment.
  1.  Open a Google cloud account in GCP, Login 
  2.  Create a new project. Note down the project id <projectname-random number>
  3.  Navigate to IAM and create a new service account with "Owner" role for the project.
  4.  Create a service account key of type json, Store the key in the inventory directory.
  5.  Open the inventory file "gcp-inventory.yml" and update the below as per your desire
      ```
       - Cluster Name: <As per your desire or leave as it is> 
       - node_count_host: <As per your desire or leave as it is>
       - service_account_file: <Fully path of the file download as a part of step 4> 
       - Project_Name: <project id of step 2>
      ```
### Steps to Deploy
1. In order to start the deployment, Build a docker container from the dockerfile present in the repo with the following command
   ``` 
    #docker build -t gcp_automation .
   ``` 
   This wraps all the required tools installation and configurations. For the list of tools,sdk and rpms refer the dockerfile.
2. Once the docker container is build, run the docker container and execute the deployment script.
   ```
    # docker run -it -v $PWD/inventory:/home/automation/inventory gcp_automation /bin/bash
    # ./entrypoint.sh inventory/<service_account_key file> inventory/gcp-inventory.yml 
   ```
   This shall perform all the task as defined in description
   
### Validation 
1. Once the deployment is successful, Open the GCP console, The GKE cluster shall be created in defined project with the name defined in  the inventory.
2. Navigate to workloads and verify 4 deployments ( frontend, redis master , redis slave and nginx-ingress-controller) status shall be in green
3. Navigate to Services & Ingress, verify services for ( frontend, redis master , redis slave and nginx-ingress-controller) and ingress guestbook.mstakx.io ( production) and staging-guestbook.mstakx.io	(staging)
4. Access the application via
```
    - Production: http://<ingressIp>/production/
    - Staging : http://<ingressIp/staging/
```
#### Validation of Horizontal Pod Autoscaling
To validate the horizontal pod autoscaling, we will generate infinite loop of queries to the application causing the cpu to spike.
1. Access the docker container used for deployment and execute
```
kubectl run -i --tty load-generator --image=busybox /bin/sh
Hit enter for command prompt
while true; do wget -q -O- http://<IP>/production/; done
```
2. Verify the frontend deployment in workloads and observe the managed pods are increased to 5 as the cpu spikes.

