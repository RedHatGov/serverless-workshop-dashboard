# Alternative Deployment to RHPDS
## AgnosticD Deployment

Please see [agnosticd repo](https://github.com/redhat-cop/agnosticd) if you need a primer.

1. Order an OpenShift 4.8 Cluster on [RHPDS](https://rhpds.redhat.com).

2. Scale the worker nodes to 3 (this is required to deploy an OCS cluster for the workshop).

3. Set environment variables (substitute your own values)

```bash
export TARGET_HOST=changeme     # example: bastion.b454.sandbox1682.opentlc.com
export OCP_USERNAME=changeme
export WORKLOAD="ocp4_workload_serverless_ml_workshop"
export GUID=example             # example: b454
export USER_COUNT=5             # number of users for the workshop
```

4. Run AgnosticD (use the development branch)

```bash
ansible-playbook -i ${TARGET_HOST}, ./configs/ocp-workloads/ocp-workload.yml \
    -e"ansible_ssh_private_key_file=$HOME/.ssh/id_rsa" \
    -e"ansible_user=${OCP_USERNAME}" \
    -e"ocp_username=${OCP_USERNAME}" \
    -e"ocp_workload=${WORKLOAD}" \
    -e"silent=False" \
    -e"guid=${GUID}" \
    -e"num_users=${USER_COUNT}" \
    -e"ACTION=create"
```
