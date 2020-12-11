# Drinking from the Firehose
A very common use case for Serverless is responding to a stream of events. These events can represent almost anything within the context of your system but the powerful idea here is the separation of the consumer from the producer of these events. This allows for massively scalable architectures while still being able to offer real time capabilities.

In this lab, we will be using the popular event streaming technology called Apache Kafka. In addition to its scalability, Kafka also provides event persistence which allows for the ability of event consumers to resume reading from where they left off in the event of consumer failure. Using Kafka as the Knative Event Source means that our Knative Eventing system inherits all of the benefits of Kafka, including its scalability and persistence features.

## Architecture

### Channel and Subscription
Entry into the Serverless sytems starts with a Knative Event Source. The role of a Knative Event Source is to convert an external event, in this case a Kafka event, into a special vendor agnostic, Cloud Native Computing Foundation (CNCF) event, called a [CloudEvent](https://cloudevents.io).

From the event source, the CloudEvent is sent to a Channel. Channels then send CloudEvents to "subscribed" Knative (or Kubernetes) Services. Many services can subscribe to a given Channel.

![Source to Sink](./images/serverless-eventing-channels-subs.png)


## Configure Kafka
Kafka has already been installed for you using the Red Hat Integration - AMQ Streams operator.  You can verify this by running:

```
oc get operators -o name | grep amq
```

Now we will create your own Kafka cluster.

1.  Create a project for it
```
oc new-project user-<user-number>
```

2.  Create the Kafka cluster
```
oc apply -f ./kafka/kafka-cluster.yml
```

3.  Wait for creation
```
oc wait kafka/my-cluster --for=condition=Ready --timeout=300s
```

4.  Verify
```
# In one terminal, run the following producer
oc run kafka-producer -ti --image=strimzi/kafka:0.19.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic my-topic

# In another terminal, run the following consumer
oc run kafka-consumer -ti --image=strimzi/kafka:0.19.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

# Whatever you type in the producer terminal should appear in the consumer terminal.
# When done, quit both the producer and consumer
```

## Knative Eventing
The first thing we need to configure is the Knative Event Source. Since we are interested in consuming Kafka events, we will need to use the `KafkaSource`.

### Deploy `KafkaSource`
We need to deploy the KafkaSource eventing source so that we can create an instance of it later.

To deploy run:

```
oc apply -f ./kafka/kafka-source.yml
```

To validate we can see the `kafka-controller-manager`

```
watch "oc get pods -n knative-sources"
```

```
NAME                                        READY   STATUS    RESTARTS   AGE
kafka-controller-manager-67cb856b5c-79kwz   1/1     Running   0          4m23s
```

and the eventing pods

```
watch "oc get pods -n knative-eventing"
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
eventing-controller-848bcbd4f9-7zz68               1/1     Running     0          3d13h
eventing-webhook-78dcf96448-6568h                  1/1     Running     0          3d13h
imc-controller-8559ff856b-2sdk6                    1/1     Running     0          3d13h
imc-dispatcher-575c7fcd8d-lrpmt                    1/1     Running     0          3d13h
mt-broker-controller-56857cccc5-h49sp              1/1     Running     0          3d13h
mt-broker-filter-784b7db965-5ngkk                  1/1     Running     0          3d13h
mt-broker-ingress-6b9f847866-bhk5w                 1/1     Running     0          3d13h
sugar-controller-594784974b-rpvsm                  1/1     Running     0          3d13h
```

We can also see the new api resources, starting first with the eventing sources.

```
oc api-resources --api-group='sources.knative.dev'
```

```
NAME               SHORTNAMES   APIGROUP              NAMESPACED   KIND
apiserversources                sources.knative.dev   true         ApiServerSource
containersources                sources.knative.dev   true         ContainerSource
kafkasources                    sources.knative.dev   true         KafkaSource
pingsources                     sources.knative.dev   true         PingSource
sinkbindings                    sources.knative.dev   true         SinkBinding
```

Next we can see the specific eventing forwarding api resources.

```
kubectl api-resources --api-group='messaging.knative.dev'
```

```
NAME               SHORTNAMES   APIGROUP                NAMESPACED   KIND
channels           ch           messaging.knative.dev   true         Channel
inmemorychannels   imc          messaging.knative.dev   true         InMemoryChannel
subscriptions      sub          messaging.knative.dev   true         Subscription
```

### Configure Knative Channel
Channels are the mechanism that actually forward events through the system, from the source (producer) to the sink (consumer). By default, all Knative Eventing API use the InMemoryChannel (imc), which is great to get started, but is not applicable for all use cases due to it's inability to persist messages. To get durability, we need to use other channels, such as GCP PubSub or Kafka.

To change the channel for our project, we create a new config map.

```
# edit line 12 and change it to your project name `user-<user-number>`, then apply it
oc apply -f ./kafka/kafka-channel-configmap.yml
```

### Create Sink
We have an eventing source and a channel. The last thing we need is a sink, which will be a Serverless service. Let's create one now:

```
oc apply -f ./kafka/kafka-sink.yml
```

Verify that it is there

```
oc get ksvc
```

```
NAME            URL                                                                                         LATESTCREATED      LATESTREADY        READY   REASON
eventinghello   http://eventinghello-jon-user.apps.cluster-tysons-9387.tysons-9387.sandbox373.opentlc.com   eventinghello-v1   eventinghello-v1   True
```

When Serverless services are created they are initially spun up, which is why we can see the logs: `stern eventinghello -c user-container`.

### Create Topic
We have a Kafka topic, we should now go ahead and create the Kafka topic.

```
oc apply -f ./kafka/kafka-topic.yml
```

Verify it was created:

```
oc get kafkatopics
```

```
NAME                                                          PARTITIONS   REPLICATION FACTOR
consumer-offsets---84e7a678d08f4bd226872e5cdd4eb527fadc1c6a   50           1
my-topic                                                      10           1
```

### Create KafkaSource Instance
Now we create a KafkaSource instance that ties our topic to our sink.

```
oc apply -f ./kafka/kafka-source-to-sink.yml
```

Verify the pod gets created

```
watch oc get pods
```

```
NAME                                          READY  STATUS   RESTARTS  AGE
mykafka-source-vxs2k-56548756cc-j7m7v         1/1    Running  0         11s
```


TODO:
1.  produce events
2.  see logs `stern eventinghello -c user-container`
3.  scale

```
oc -n kafka run kafka-spammer --image=quay.io/rhdevelopers/kafkaspammer:1.0.2
watch oc -n kafka get pods
KAFKA_SPAMMER_POD=$(kubectl -n kafka get pod -l "run=kafka-spammer" -o jsonpath='{.items[0].metadata.name}')
oc -n kafka exec -it $KAFKA_SPAMMER_POD -- /bin/sh
curl localhost:8080/3
```

```
NAME                                                              READY   STATUS    RESTARTS   AGE
camel-k-operator-65db5d46bb-llc6g                                 1/1     Running   0          20h
eventinghello-v1-deployment-57c686cc96-6k9r2                      2/2     Running   0          15s
eventinghello-v1-deployment-57c686cc96-jcv8b                      2/2     Running   0          13s
eventinghello-v1-deployment-57c686cc96-lh8xr                      2/2     Running   0          15s
eventinghello-v1-deployment-57c686cc96-n2slh                      2/2     Running   0          16s
kafkasource-mykafka-source-a29a50ca-4d76-4e65-8b96-1507372bfphb   1/1     Running   0          119s
```

4.  Cleanup

```
oc delete pod kafka-spammer
oc delete -f ./kafka/kafka-source-to-sink.yml
oc delete -f ./kafka/kafka-sink.yml
oc delete -f kafka-topic.yml
```
