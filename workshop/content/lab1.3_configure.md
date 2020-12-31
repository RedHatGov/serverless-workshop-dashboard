# Setup

As a preqrequisite to running these labs, you will need access to an OpenShift v4.x cluster as a cluster admin.  We also assume you have the `oc` client installed and have logged into your cluster with it.

OpenShift Serverless install can be completely done with Operator Hub webconsole or the CLI - we are going to give you a little taste of both by adding the operator via webconsole and then the rest via CLI

## Knative Serving
Knative serving has already been installed for you.  Verify it now.

1.  Verify installation
```
oc get knativeserving.operator.knative.dev/knative-serving -n knative-serving --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
```

The output will look like:

```
DependenciesInstalled=True
DeploymentsAvailable=True
InstallSucceeded=True
Ready=True
```

2.  Verify serving pods

```
oc get pods -n knative-serving
```

You should see something like the following:
```
NAME                                READY   STATUS      RESTARTS   AGE
activator-78c57d4f4d-fxtwj          1/1     Running     0          40s
activator-78c57d4f4d-wdr7h          1/1     Running     0          25s
autoscaler-86995ff7dc-lspqj         1/1     Running     0          39s
autoscaler-hpa-c8bd7454b-k8zcs      1/1     Running     0          36s
autoscaler-hpa-c8bd7454b-lmt2c      1/1     Running     0          36s
controller-648758ffcc-2fdmt         1/1     Running     0          26s
controller-648758ffcc-zrg5s         1/1     Running     0          37s
kn-cli-downloads-6cdf999975-nkftf   1/1     Running     0          47s
webhook-75d6b55d76-zbp5f            1/1     Running     0          38s
```


## Knative Eventing
Knative eventing has already been installed for you.  Verify it now.

1.  Verify installation
```
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

```
oc get pods -n knative-eventing
```

You should see something like the following:
```
NAME                                   READY   STATUS    RESTARTS   AGE
broker-controller-58765d9d49-g9zp6     1/1     Running   0          7m21s
eventing-controller-65fdd66b54-jw7bh   1/1     Running   0          7m31s
eventing-webhook-57fd74b5bd-kvhlz      1/1     Running   0          7m31s
imc-controller-5b75d458fc-ptvm2        1/1     Running   0          7m19s
imc-dispatcher-64f6d5fccb-kkc4c        1/1     Running   0          7m18s
```


## `kn` CLI Installation

`kn` is a very powerful tool for being able to control knative from the command line.

1.  Download the CLI from [openshift.com](https://mirror.openshift.com/pub/openshift-v4/clients/serverless/latest) or from your cluster by appending `/command-line-tools` to your cluster URL
2.  Unpack and unzip the archive
```
tar -xf <file>
```
3.  Move the kn binary into your PATH
4.  Verify installation
```
kn version
```
