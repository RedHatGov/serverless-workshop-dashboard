# A Brief Introduction to Serverless
The word taken at face value, is a bit of a misnomer.  More accurately, "serverless" doesn't mean to imply there are no servers.  After all, something must run your application code.  Rather, the term serverless means the developer need not worry about the specifics of the server that will be running the application code.  This concern has been pushed back into the infrastructure.
There is a nice analogy to all this.  Let's say you're in a coffee shop and they say they offer all guests "free wireless internet".  We know somewhere there must be wires, for example from the modem to the router.  But what's important here is that for you, the guest, there are no wires.  This same concept applies to the term serverless.

## Why serverless?
There are a lot of benefits to using serverless. One of the most popular is the productivity gain that development teams get by reducing their scope and areas of concerns in their deployable artifacts.  Coupled with the ability to spin up quickly to handle bursts in traffic, and the ability to dynamically spin back down when there is no traffic, this means our application is truly elastic.  This leads to additional added benefits, such as:

* lower cost
* faster time from inception to market
* agility and speed
* easier experimentation

## What is a Serverless?
If the concerns have been pushed away from the developer, how does this actually work?  How does code get turned into an artifact that we can run and how does it get deployed?

Red Hat OpenShift Serverless is built upon the Red Hat OpenShift platform, which is a Kubernetes based platform for container management and orchestration.  Building on top of OpenShift gives us the power to work with and manage containers.  Ultimately, the container is the base unit of a serverless application and is what enables serverless capabilities.  Taking source code, we build small, lightweight containers that OpenShift Serverless can use to dynamically and efficiently spin up and down your containers.

Red Hat OpenShift makes it easy to take advantage of delivering serverless applications. Through the CLI or through the GUI, you can easily specify which containers should be ran as serverless applications.  It does this by leveraging the open source project known as Knative.  This project provides a vendor agnostic way of making containers serverless capable.

It does this by applying two key concepts:

- Serving - Builds on Kubernetes to support deploying and serving serverless applications and functions.
- Eventing - Is a system that is designed to address a common need for cloud native development and provides composable primitives to enable late-binding event sources and event consumers.

Red Hat OpenShift Serverless not only opens serverless architecture, but also adds monitoring, metering, A/B testing, canary releases, and publicly exposed routes.  Another benefit of it running within the OpenShift ecosystem is that all of the hybrid cloud and cloud native development tools are available and all integrate and work well with each other.  This includes things like CodeReady Workspaces, supported runtimes for your container, and hundreds of integration connectors ready to go out of the box like Kafka event streams.
