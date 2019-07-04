###################################################################
#   Author: Sriram Kannan (c). All rights reserved.
####################################################################

#!/bin/sh
#

set -e

if [[ -z "${SERVICE_ACCOUNT_FILE}" ]]; then
  if [ $# -lt 2 ]; then
    echo "Usage ./entrypoint.sh [service_account_file] [inventory_file]"
    echo "  [service_account_file] = service account file for authentication(e.g. /home/automation/inventory/kubernetes-244404-e161b191a0f7.json)"
    echo "  [inventory_file] = Ansible inventory file for deployment(e.g /home/automation/inventory/gcp_inventory.yml"
    exit 1
  fi
  SERVICE_ACCOUNT=$1
  INVENTORY=$2

else
  SERVICE_ACCOUNT="${SERVICE_ACCOUNT_FILE}"
fi

if [ ! -f ${SERVICE_ACCOUNT} ]; then
    echo "Service Account file ${SERVICE_ACCOUNT} not found"
    exit 1
fi

if [ ! -f ${INVENTORY} ]; then
    echo "Ansible Inventory file ${INVENTORY} not found"
    exit 1
fi

echo "Configuring ssh key"
ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""

echo "Configuring gcloud auth"
gcloud auth activate-service-account --key-file $SERVICE_ACCOUNT

BASE=`dirname $0`
TIMESTAMP=`date -u +%FT%T | sed 's/[T:-]//g'`

echo "Running Ansible playbooks"
ansible-playbook -i $INVENTORY playbook/deploy.yml
