# The Developer Stakeholder
There are many types of users from different types of roles that can all benefit from Serverless. In this section, we will be exploring how Serverless can immediately improve a developer's workflow and productivity.

The first major win is that it frees the developer to simply focus on their application code.  No need to worry about complicated frameworks or application servers that dictate to the developer how they should solve the business problem.

The second major win is that deploying to a development kubernetes environment becomes as easy as a simple one line command. No more messy YAML and a more intuitive workflow that fits the way a developer prefers to work.

## Services
A Knative Service is a way to abstract the underlying pods that make up a single application, similar to a Kubernetes Service.  While a Kubernetes Service is not difficult to deploy, Knative takes this ease a step further and makes it even easier.  Let's do this now.

### Deploy Service

1.  Use project/namespace with assigned user number
Make sure you are logged in first with the `oc login` command

```shell
# replace X with your assigned number
export USER_NUMBER=X
oc project user$USER_NUMBER
```

2.  Build the project

Build the project and wait until build succeeds.

```shell
oc new-build python:3.6~https://github.com/RedHatGov/serverless-workshop-code --name hello-python --context-dir=hello-python --strategy=docker
```

3.  Deploy the service

```shell
HELLO_IMAGE_URI=$(oc get is hello-python --template='{{.status.dockerImageRepository}}')
kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Python
```

Your output should look similar to:

```shell
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

4.  Test it

In one terminal, watch the pods:

```shell
oc get pods -w
```

You should see:

```shell
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Running     0          11s
```

In another terminal, curl the endpoint:

```shell
HELLO_URL=$(oc get route.serving.knative.dev hello-python --template='{{.status.url}}')
curl $HELLO_URL
```

You should see:

```shell
Hello Python!
```

After ~90s of idle time, you should see the `hello-python` service transition to `Terminating` before ultimately being removed.

```shell
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Terminating 0          67s
```

### Update Service

Now say a new requirement has come in that we need to say `Hello Pythonistas` instead of `Hello Python`.

1.  Deploy the updated service
```execute
kn service update hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas
# can alternatively force create instead of update
# kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas -f
```

2.  Test it

Ensure you are still watching the pods, if not, in one terminal run:

```execute
oc get pods -w
```

The `hello-python` should not be running.

In another terminal we'll curl the endpoint again.

```execute
curl $HELLO_URL
```

You should now see the `hello-python` service appear and change states from `Pending` to `ContainerCreating` to `Running`.

The result of the `curl` command should be:

```
Hello Pythonistas!
```

If you wait another ~90s, then you will see the `hello-python` service again be destroyed.

3.  Delete service

```execute
kn service delete hello-python
```

## Functions

Previously, we deployed a Knative Service, which was just a containerized application.  This works just fine, but notice that we had to choose the way we exposed and handled the http endpoint.  In our example above, we chose Flask.  You can imagine for Ruby we might choose Sinatra, for Java maybe Spring Boot, and for Node maybe Express.

In some use cases, it would be great if we could offload these http concerns to the platform.  That way, all we would have to do is just write a single function and just deploy that.  This is often referred to as Functions as a Service (FAAS) and this is exactly what Serverless Functions allow us to do.  For a developer, this let's us focus only on just writing the code itself and nothing else.

There is one caveat to the following section, specifically the deployment section below.  You will need and be logged into an image repository like http://quay.io or http://hub.docker.com.  If you are using quay.io, go ahead and create a registry named `func` and make the visibility public by going here https://quay.io/new/.  Also log in to it by running `docker login quay.io` or `podman login quay.io`.

### Create New Project

Let's start first by creating a new project that we will use to demonstrate Serverless Functions.  The `kn` tool allows us to easily create scaffolding for our new project.  For this example, we will be using Java and particularly some libraries from the Quarkus framework.  A quick aside on Quarkus, this is a Java framework that performs advanced compile time optimizations to lower the notoriously long Java boot time, memory footprint, and even allows us to compile our Java application down to native code; making our Java app extremely fast.  If you're interested, you can read more about [Quarkus here](https://quarkus.io).

Let's create a project directory and bootstrap our project.

```
mkdir func
cd func
kn func create -l quarkus
```

Next take a quick peek at our function.  Notice that it is a single class with just a single function.

```
cat ./src/main/java/functions/Function.java
```

This is the function:

```java
package functions;

import io.quarkus.funqy.Funq;

public class Function {

    @Funq
    public Output function(Input input) {
        return new Output(input.getMessage());
    }

}
```

### Local Function

Serverless Functions also provides us the ability to build and run our function locally.  We can do that using the `kn` tool.

```
kn func build
```

You will then get the following prompt.  If you have a dockerhub or quay account, use it here when prompted.  Replace `IMAGE_REPO_USERNAME` with your own username.

```shell
A registry for function images is required (e.g. 'quay.io/boson').

Registry for function images: quay.io/IMAGE_REPO_USERNAME
Building function image
Function image has been built, image: quay.io/IMAGE_REPO_USERNAME/func:latest
```

Notice that the name of the project is `func`, named after the directory we are in and tagged with `latest`.  Let's see how this information is actually saved.

```shell
cat ./func.yaml
```

The following is the output.  Note, we will be updating the namespace later.

```yaml
name: func
namespace: ""
runtime: quarkus
image: quay.io/IMAGE_REPO_USERNAME/func:latest
imageDigest: ""
trigger: http
builder: default
builderMap:
  default: quay.io/boson/faas-quarkus-jvm-builder
  jvm: quay.io/boson/faas-quarkus-jvm-builder
  native: quay.io/boson/faas-quarkus-native-builder
envVars: {}
```

Now let's run it.

```shell
kn func run  # wait until done, will say listening on: http://0.0.0.0:8080
```

Then in another terminal hit the endpoint.

```shell
curl "http://localhost:8080?message=test"
```

This should return the following:

```json
{"message":"test"}
```

Then stop the server by `ctrl-c` in the terminal.

### Deploy Function

Time to deploy the function to OpenShift into our namespace.

```shell
kn func deploy -n user$USER_NUMBER
```

You will see the following output:

```shell
Building function image
Function image has been built, image: quay.io/IMAGE_REPO_USERNAME/func:latest
Pushing function image to the registry
Deploying function to the cluster
Function updated at URL: http://func-user1.apps.cluster-62f2.62f2.sandbox1305.opentlc.com
```

If it fails, with an error like

```shell
Error: knative deployer failed to wait for the service to become ready: timeout: service 'func' not ready after 60 seconds` just rerun the deploy command.
```

Make sure to make your quay repository public.  You can do so by going to `https://quay.io/repository/IMAGE_REPO_USERNAME/func?tab=settings` and changing the visibility to public.

Test the endpoint.

```shell
URL=$(kn func describe -o yaml | yq e '.routes[0]' -)
curl "$URL?message=test"
```

You should see the same result:

```json
{"message":"test"}
```

### Delete Function

Finally let's clean everything up.

```shell
kn func delete
```

## Summary
In this lab you saw how easy it was for a developer to quickly build and deploy code into the OpenShift cluster.  You could deploy either a container or just a function with just a few commands.  Our service sprang to life when we used it and spun back down when it was not.  This simple workflow makes it easy for developers to get started and the low resource utilization when services are idle means potentially being able to support more services and developers on the platform.
