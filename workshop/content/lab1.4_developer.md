# The Developer Stakeholder
There are many types of users from different types of roles that can all benefit from Serverless. In this section, we will be exploring how Serverless can immediately improve a developer's workflow and productivity.

The first major win is that it frees the developer to simply focus on their application code.  No need to worry about complicated frameworks or application servers that dictate to the developer how they should solve the business problem.

The second major win is that deploying to a development kubernetes environment becomes as easy as a simple one line command. No more messy YAML and a more intuitive workflow that fits the way a developer prefers to work.

## Deploy Service

1.  Create project/namespace
```
oc new-project hello
```

2.  Build the project
```
oc new-build python:3.6~https://github.com/jkeam/hello-python --name hello-python
```

4.  Deploy the service
```
HELLO_IMAGE_URI=$(oc get is hello-python --template='{{.status.dockerImageRepository}}')
kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Python
```

Your output should look similar to:
```
Creating service 'hello-python' in namespace 'hello':

  0.042s The Configuration is still working to reflect the latest desired specification.
  0.075s The Route is still working to reflect the latest desired specification.
  0.140s Configuration "hello-python" is waiting for a Revision to become ready.
 21.017s ...
 21.018s Ingress has not yet been reconciled.
 21.018s unsuccessfully observed a new generation
 21.223s Ready to serve.

Service 'hello-python' created to latest revision 'hello-python-dydsc-1' is available at URL:
http://hello-python-hello.apps.cluster-tysons-4d23.tysons-4d23.example.opentlc.com
```

5.  Test it

In one terminal, watch the pods:
```
oc get pods -w
```

You should see:

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Running     0          11s
```

In another terminal, curl the endpoint:
```
# Your service endpoint will vary
curl http://hello-python-hello.apps.cluster-tysons-4d23.tysons-4d23.example.opentlc.com
```

You should see:
```
Hello Python!
```

After ~90s of idle time, you should see the `hello-python` service transition to `Terminating` before ultimately being removed.

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Terminating 0          67s
```


## Update Service

Now say a new requirement has come in that we need to say `Hello Pythonistas` instead of `Hello Python`.

1.  Deploy the updated service
```
kn service update hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas
# can alternatively force create instead of update
# kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas -f
```

2.  Test it

Ensure you are still watching the pods, if not, in one terminal run:
```
oc get pods -w
```

The `hello-python` should not be running.

In another terminal we'll curl the endpoint again.
```
# Your service endpoint will vary
curl http://hello-python-hello.apps.cluster-tysons-4d23.tysons-4d23.example.opentlc.com
```

You should now see the `hello-python` service appear and change states from `Pending` to `ContainerCreating` to `Running`.

The result of the `curl` command should be:
```
Hello Pythonistas!
```

If you wait another ~90s, then you will see the `hello-python` service again be destroyed.

5.  Delete service
```
kn service delete hello-python
```

## Summary
In this lab you saw how easy it was as a developer to quickly build and deploy code into the OpenShift cluster.  It was a single command to build and another to deploy.  Our service sprang to life when we used it and spun back down when it was not.  This simple workflow makes it easy for developers to get started and the low resource utilization when services are idle means potentially being able to support more services and developers on the platform.
