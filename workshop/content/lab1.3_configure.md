# Setup

As a preqrequisite to running these labs, you will need access to an OpenShift v4.x cluster.  You should also have a few things preconfigured which we'll verify now.

## Knative Serving
Knative serving has already been installed for you.  Verify it now.

1.  Verify installation
```execute
oc get knativeserving.operator.knative.dev/knative-serving \
  -n knative-serving \
  --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
```

The output will look like:

```
DependenciesInstalled=True
DeploymentsAvailable=True
InstallSucceeded=True
Ready=True
```

2.  Verify serving pods

```execute
oc get pods -n knative-serving
```

You should see something like the following:
```
NAME                                                     READY   STATUS      RESTARTS   AGE
activator-58fb6669f6-hkzr7                               2/2     Running     0          90s
activator-58fb6669f6-tltgh                               2/2     Running     0          104s
autoscaler-769678c97d-btrrp                              2/2     Running     0          104s
autoscaler-hpa-cd895c4bf-cfdvl                           2/2     Running     0          102s
autoscaler-hpa-cd895c4bf-m447l                           2/2     Running     0          102s
controller-69ccdc78fc-bb9fl                              2/2     Running     0          103s
controller-69ccdc78fc-vxlj6                              2/2     Running     0          85s
domain-mapping-6655558fc4-rzgwb                          2/2     Running     0          100s
domainmapping-webhook-7d8b776b4-rvhm4                    2/2     Running     0          100s
kn-cli-00001-deployment-7666bf67dc-z2qd2                 2/2     Running     0          64s
kn-cli-00002-deployment-557655bfd9-bqhh6                 2/2     Running     0          64s
storage-version-migration-serving-serving-0.20.0-hd7ws   0/1     Completed   0          99s
webhook-576b57b4d6-jtphz                                 2/2     Running     0          88s
webhook-576b57b4d6-ml6b8                                 2/2     Running     0          103s
```


## Knative Eventing
Knative eventing has already been installed for you.  Verify it now.

1.  Verify installation
```execute
oc get knativeeventing.operator.knative.dev/knative-eventing \
  -n knative-eventing \
  --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
```

The output will look like:
```
InstallSucceeded=True
Ready=True
```

2.  Verify eventing pods

```execute
oc get pods -n knative-eventing
```

You should see something like the following:
```
NAME                                        READY   STATUS    RESTARTS   AGE
eventing-controller-7b9cdbf9cf-9sszp        1/1     Running   0          28m
eventing-webhook-b8f8cdc96-swgh2            1/1     Running   0          28m
imc-controller-55dc57b4d-7b675              1/1     Running   0          28m
imc-dispatcher-79f447d6f-w4nc5              1/1     Running   0          28m
kafka-ch-controller-fd859cc5f-nrk8d         1/1     Running   0          2m6s
kafka-ch-dispatcher-649945777d-q88pq        1/1     Running   0          2m6s
kafka-controller-manager-79644f667f-jpkjb   1/1     Running   0          2m6s
kafka-webhook-68db549d7-hk59h               1/1     Running   0          2m6s
mt-broker-controller-55d65b468b-gvfzx       1/1     Running   0          28m
mt-broker-filter-7c8ff49f98-mbklc           1/1     Running   0          28m
mt-broker-ingress-5458f4c5bc-wzttt          1/1     Running   0          28m
sugar-controller-5f6fb848b8-2shg8           1/1     Running   0          28m
```

## Tools
The environment set up for you to perform this lab should have all the tools pre-installed already. The oc and kn tools are available on OpenShift at https://console-openshift-console.%cluster_subdomain%/command-line-tools.

### `kn` CLI

`kn` is a very powerful tool for being able to control knative from the command line. Verify that you have it installed by running:

```execute
kn version
```

### `stern` CLI

`stern` is a great tool to easily be able to view logs for a particular container.  Verify that you have it installed by running:

```execute
stern -v
```
