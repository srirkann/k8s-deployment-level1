# CentOS based container with Ansible, Python and access to GCP

FROM williamyeh/ansible:centos7

MAINTAINER Sriram Kannan <sriramk.kannan@gmail.com>

# Install all dependencies available through yum

RUN mkdir -p  /home/automation
COPY deploy-k8s /home/automation
COPY entrypoint.sh /home/automation
RUN chmod +x /home/automation/entrypoint.sh


#Install Google SDK for gcloud
RUN echo $'[google-cloud-sdk] \n\
name=Google Cloud SDK \n\
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64 \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg \n\
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' > /etc/yum.repos.d/google-cloud-sdk.repo

RUN echo $'[kubernetes] \n\
name=Kubernetes \n\
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' > /etc/yum.repos.d/kubernetes.repo 

RUN yum update -y \
    && yum clean all \
    && yum install -y wget \
    && yum install -y kubectl \
    && pip install requests google-auth \
    && yum install -y google-cloud-sdk

WORKDIR /home/automation


CMD ["ansible --version"]
