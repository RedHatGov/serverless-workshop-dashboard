# Overview

In this lab, you will add a new machine learning capability to the Emergency Response Demo using OpenShift Serverless.

As you explored in the previous lab, an incident user must register to the Emergency Response application in order to create an incident for help.  This isn't the best user experience; in the middle of a disaster, people need the ability to ask for help quickly and efficiently.

Let's create a new user experience.  A person texts a phone number to ask for help by sending details of the disaster they are experiencing.  On the backend, the system verifies if the message describes a legitimate disaster by using a machine learning Natural Language Processing (NLP) model.  If verification succeeds, the system replies to the user with a link to a mobile website to ask for help.  If it does not, the system asks for more details.  We will call this the **NLP Prediction Service** going forward.

The backend for this service doesn't need to be running until a disaster strikes.  When it does, it needs to scale very quickly when people start asking for help.  In other words, you need scale-to-zero and a fast way to build and iterate on this new feature.

Enter OpenShift Serverless.  Here is the architecture:

![Architecture](images/ml_architecture_flow.png)

You will focus on building, debugging, and deploying the NLP Prediction Service.  You will also integrate the following important components:

* [Lifeline](https://github.com/RedHatGov/serverless-workshop-code/tree/main/lifeline) - a React based web application
* [Twilio](https://www.twilio.com/) - a communications API for building the phone/text user interaction

Feel free to ask your instructor if you have any questions with this architecture.  Let's get started!