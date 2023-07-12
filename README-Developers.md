# Developers Instructions
## Building this locally
You need the docker or podman CLI. Then simply run:
> `docker build . -t serverless-workshop-dashboard`

## Running locally (note this requires a lot of memory)
You'll need [Code Ready Containers](https://cloud.redhat.com/openshift/install/crc/installer-provisioned).

Start your cluster and create a project to work in
> `crc start`
> 
> `oc new-project homeroom --display-name="Homeroom Workshops"`

Build the image in your cluster: 
> `oc new-build --strategy docker --binary --docker-image quay.io/redhatgov/workshop-dashboard:latest --name=serverless-workshop-dashboard`
> 
> `oc start-build serverless-workshop-dashboard --from-dir . --follow`

Export a cluster subdomain:
> `CLUSTER_SUBDOMAIN=<apps.openshift.com>`

Deploy the workshop using the imported image:
> ```
> oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
>    -p SPAWNER_NAMESPACE=homeroom \
>    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
>    -p WORKSHOP_NAME=serverless-workshop \
>    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.12 \
>    -p WORKSHOP_IMAGE=serverless-workshop-dashboard:latest \
>    -p IDLE_TIMEOUT=86400 \
>    | oc apply -n homeroom -f -
> ```

Wait until it's ready
> `oc get pods -w`

It will be available here (login your developer/developer account - kubadmin doesn't seem to work):
> `open https://serverless-workshop-homeroom.$CLUSTER_SUBDOMAIN`
