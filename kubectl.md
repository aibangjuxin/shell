# Kubernetes Cheat Sheet
# reference: https://raw.githubusercontent.com/Borosan/kubernetes-cheatsheet/master/README.md
https://github.com/eon01/kubectl-SheetCheat


**What is Kubernetes?** [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/), also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications.

It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon [15 years of experience of running production workloads at Google](http://queue.acm.org/detail.cfm?id=2898444), combined with best-of-breed ideas and practices from the community.

**What is kubectl?** Kubectl is a command line tool used to run commands against Kubernetes clusters. It does this by authenticating with the Master Node of your cluster and making API calls to do a variety of management actions. 

The format of a kubectl command looks like this:

```
kubectl [command] [type] [name] [flags]
```

* \[command]: specifies the action you want to perform like create, delete, get, apply
* \[type]: any Kubernetes resource, whether automatically provided by Kubernetes (like a service or a pod) or created by you with a Custom Resource Definition
* \[name]: the name you have given the resource — if you omit the name, kubectl will return every resource specified by the type
* \[flags]: specify any additional global or command specific options such as the output format

**What is kubeconfig ?** kubeconfig is a configuration file which is used by kubectl  In order to access your Kubernetes cluster.  The default kubectl configuration file is located at `~/.kube/config` and is referred to as the kubeconfig file.

kubeconfig files organize information about clusters, users, namespaces, and authentication mechanisms. The kubectl command uses these files to find the information it needs to choose a cluster and communicate with it. 

The loading order follows these rules:

1. If the `--kubeconfig` flag is set, then only the given file is loaded. The flag may only be set once and no merging takes place.
2. If the `$KUBECONFIG` environment variable is set, then it is parsed as a list of filesystem paths according to the normal path delimiting rules for your system.
3. Otherwise, the `${HOME}/.kube/config` file is used and no merging takes place.

If you see a message similar to the following, `kubectl` is not configured correctly or is not able to connect to a Kubernetes cluster.

### Cluster Management

```
#Display endpoint information about the master and services in the cluster
kubectl cluster-info

#Display the status of all components in the cluster
kubectl get componentstatuses

#Display the Kubernetes version running on the client and server
kubectl version

#Get the configuration of the cluster
kubectl config view

#List the API resources that are available
kubectl api-resources

#List the API versions that are available
kubectl api-versions

#List everything
kubectl get all --all-namespaces

#List all objects in current namespace plus labels
kubectl get all --show-labels

#List components that match label
kubectl get all --selector <label>

#Get a list of contexts
kubectl config get-contexts

#Get the current context
kubectl config current-context

#Switch current context
kubectl config use-context <context_name>
```

_The context consist of the clustername and namespace that the current user connects to._

### ConfigMaps

Shortcode=**cm**

```
#Display ConfigMaps information
kubectl get configmaps

#create a configmap form a file
kubectl create configmap <my-cmname> --from-file=path/to/configmap/

#See the content of a configmap in yaml format
#kubectl get configmap <configmap_name> -o yaml

#Display detailed information of a configmap
kubectl describe configmaps <configmap_name>

#delete a configmap
kubectl delete configmap  <configmap_name>
```

### Daemonsets

Shortcode = **ds**

```
#List one or more daemonsets
kubectl get daemonset

#Display the detailed state of daemonsets within a namespace
kubectl describe ds <daemonset_name> -n <namespace_name>

#Edit and update the definition of one or more daemonset
kubectl edit daemonset <daemonset_name>

#Create a new daemonset
kubectl create daemonset <daemonset_name>

#Delete a daemonset
kubectl delete daemonset <daemonset_name>

#Manage the rollout of a daemonset
kubectl rollout daemonset
```

### Deployments

Shortcode = **deploy**

```
#List one or more deployments
kubectl get deployments

#dumps all the deployment yaml code on the screen
kubectl get deployments <deployment_name> -o yaml

#Display the detailed state of one or more deployments
kubectl describe deployment <deployment_name>

#Edit and update the definition of one or more deployment on the server
kubectl edit deployment <deployment_name>

#Create one a new deployment
kubectl create deployment --image=<img_name> <deployment_name>

#Delete deployments
kubectl delete deployment <deployment_name>

#scale a deployment
kubectl scale deployment <deployment_name> --replicas=[X]

#Set Autoscaling config
kubectl autoscale deployment <deployment_name> --min=10 --max=15 --cpu-percent=80

#See the rollout status of a deployment
kubectl rollout status deployment <deployment_name>

#see rollout history of all deployments
kubectl rollout history deployment

#See the overview of recent changes
kubectl rollout history deployment <deployment_name>
kubectl rollout history deployment <deployment_name> --reversion=2

#bring down the new replicaset and bring up the old ones
kubectl rollout undo deployment <deployment_name>
kubectl rollout undo deployment <deployment_name> --to-revision=1

#Pause a rollout
kubectl rollout pause deployment <my_deployment>

#Resume a rollout
kubectl rollout resume deployment <my_deployment>

#expose a deployment as a kubernetes service (type can be  NodePort/ClusterIP for on-promise cluster)
kubectl expose deployment <deployment_name> --type=NodePort --targetport=80 --name=<myapp-service>

#Add label to a deployment
kubectl lable deployments <deployment_name> state=LA

#Show deployments labels
kubectl get deployments --show-labels
```

_If you use kubectl create to create a deployment, it will automatically get a lable with the  name  app=\<NameofDeployment> . _

_Label  plays an essential role in the monitoring that the kubernetes deployment is doing, label is used to make sure that the suffcient amount of pods are available._

### Events

Shortcode = **ev**

```
#List recent events for all resources in the system
kubectl get events

#List Warnings only
kubectl get events --field-selector type=Warning

#List events but exclude Pod events
kubectl get events --field-selector involvedObject.kind!=Pod

#Pull events for a single node with a specific name
kubectl get events --field-selector involvedObject.kind=Node, involvedObject.name=<node_name>

#Filter out normal events from a list of events
kubectl get events --field-selector type!=Normal
```

### Ingress

Shortcode=**ing**

```
#List 
kubectl get ingress <ingress-resource-name>

# Display detailed information about an ingress resource
kubectl describe ingress <ingress-resource-name>
```

### Labels

Labels play an essential role in the kubernetes.

```
#General command for adding label to one of kubernetes resources
kubectl label <resource_type> <resource_name> <label>
```

_Usually labels are applied automatically, or we add them trough the yaml files._

### Logs

Container doesn't have stout, to see what's happening within a container use logs:

```
#Print the logs for a pod
kubectl logs <pod_name>

#Quering pod logs using label selector
kubectl logs -l app=<my-app>

#Print the logs for the last hour for a pod
kubectl logs --since=1h <pod_name>

#Get the most recent 20 lines of logs
kubectl logs --tail=20 <pod_name>

#Print the logs for a pod and follow new logs
kubectl logs -f <pod_name>

#Print the logs for a container in a pod
kubectl logs -c <container_name> <pod_name>

#Output the logs for a pod into a file named ‘pod.log’
kubectl logs <pod_name> pod.log

#Copy files out of pod (Requires tar binary in container).
kubectl cp <pod_name>:/var/log .

#View the logs for a previously failed pod
kubectl logs --previous <pod_name>

#Watch logs in real time:
kubectl attach <pod_name>
```

_For logs we also recommend using a tool developed by Johan Haleby called Kubetail. This is a bash script that will allow you to get logs from multiple pods simultaneously. You can learn more about it at its _[_Github repository_](https://github.com/johanhaleby/kubetail)_._

### Manifest Files

Another option for modifying objects is through Manifest Files. Using this method is highly recommend. It is done by using yaml files with all the necessary options for objects configured. Also it is recommended to store your  yaml files in a git repository, so you can track changes and streamline changes.

```
#Create objects
kubectl create -f manifest_file.yaml

#Create objects in all manifest files in a directory
kubectl create -f ./dir

#Create objects from a URL
kubectl create -f ‘url’

#Delete an object
kubectl delete -f manifest_file.yaml

#Apply a configuration to an object by filename or stdin. Overrides the existing configuration.
kubectl apply -f manifest_file.yaml

#Replace a configuration to an object by filename or stdin.
kubectl replace -f manifest_file.yaml
```

_Incase of error while using `apply `or `replace`, use `delete `and then `create `combination._

### Namespaces

Shortcode = **ns**

```
#List one or more namespaces
kubectl get namespace <namespace_name>

#Display the detailed state of one or more namespace
kubectl describe namespace <namespace_name>

#Set default namesapce
kubectl config set-context $(kubectl config current-context) --namespace=<my-namespace>

#Create namespace <name>
kubectl create namespace <namespace_name>

#Delete a namespace
kubectl delete namespace <namespace_name>

#Edit and update the definition of a namespace
kubectl edit namespace <namespace_name>

#Display Resource (CPU/Memory/Storage) usage for a namespace
kubectl top namespace <namespace_name>
```

_The optional _[_kubectx_](https://github.com/ahmetb/kubectx)_ package can be used to make switching between namespaces easier, it contains** kubectx** to switch between context, and **kubens** to switch between Namespaces.  If multiple clusters are available to a kubernetes client, switching context is relevant. If multiple namespaces exist within a cluster, switching namespaces is relevant._

### Nodes

Shortcode = **no**.

```
#List one or more nodes
kubectl get nodes

#Delete a node or multiple nodes
kubectl delete node <node_name>

#edit a node
kubectl edit node <node_name>

#Display Resource usage (CPU/Memory/Storage) for node(s)
kubectl top node <node_name> 

#Resource allocation per node
kubectl describe nodes | grep Allocated -A 5

#Pods running on a node
kubectl get pods -o wide | grep <node_name>

#Annotate a node
kubectl annotate node <node_name> <annotation>

#Update the taints on one or more nodes
kubectl taint node <node_name> <taint_name> 

#Mark a node as unschedulable
kubectl cordon node <node_name>

#Mark node as schedulable
kubectl uncordon node <node_name>

#Drain a node in preparation for maintenance
kubectl drain node <node_name>

#Add or update the labels of one or more nodes
kubectl label nodes <node-name> disktype=ssd

#list nodes and their labels
kubectl get nodes --show-labels
```

### Pods

Shortcode = **po**

```
#List one or more pods
kubectl get pods

#dumps all the pod yaml code on the screen
kubectl get pods <pod_name> -o yaml

#Display the detailed state of a pods
kubectl describe pod <pod_name>

#create a pod, impremitive (depricated)
kubectl run <pod_name> --image=<image_name>

#Create a pod from a yaml file
kubectl create -f <pod.yaml>

#Delete a pod
kubectl delete pod <pod_name>

#edit a pod
kubectl edit pod <pod_name>

#Get interactive shell on a a single-container pod
kubectl exec -it <pod_name> /bin/sh


#Execute a command in a pod (pod contains a single container)
kubectl exec -it <pod_name>  -- <command>

#Execute a command against a container in a pod (pod contains multiple containers)
kubectl exec -it <pod_name> -c <container_name> -- <command>

#Display Resource usage (CPU/Memory/Storage) for pods
kubectl top pod

#Add or update the annotations of a pod
kubectl annotate pod <pod_name> <annotation>

#Add or update the label of a pod
kubectl label pods <pod_name> env=prod

#Get pods showing labels
kubectl get pods --show-labels

#Remove the lable of a pod
kubectl label pods <pod_name> <label>-
```

_kubectl exec only works on pods!_

### Persistent Volume

Shortcode=**pv**

```
#List one or more persistent volumes
kubectl get pv

#Display the detailed information about a persistent volume
kubectl describe pv <pv_name>
```

### **Persistent Volume Claim**

shortcode=**pvc**

```
#List one or more persistent volume claims
kubectl get pvc

#Display the detailed information about a persistent volume claim
kubectl describe pvc <pvc_name>
```

### Replication Controllers

Shortcode = **rc**

```
#List the replication controllers
kubectl get rc

#List the replication controllers by namespace
kubectl get rc --namespace=<namespace_name>
```

### ReplicaSets

Shortcode = **rs**

```
#List ReplicaSets
kubectl get replicasets

#Display the detailed state of one or more ReplicaSets
kubectl describe replicasets <replicaset_name>

#Scale a ReplicaSet
kubectl scale --replicas=[x] replicaset <replicaset_name>

#autoscale replicaset
kubectl autoscale rs <replicaset_name> --max=10 --min=3 --cpu-percent=50

#Delete a ReplicaSet
kubectl delete replicaset <replicaset-name>
```

### Secrets

```
#List secrets
kubectl get secrets

#List details about secrets
kubectl describe secrets

#Create a generic/docker registry/tls secret
kubectl create secret generic <secret_name> --from-literal=user=user1 --from-literal=password=password

#See the content of a secret in yaml format
kubectl get secret <secret_name> -o yaml

#Delete a secret
kubectl delete secret <secret_name>
```

### Services

Shortcode = **svc**

```
#List one or more services
kubectl get services

#List endpoint pods of a service
kubectl get endpoints <service_name>

#Display the detailed state of a service
kubectl describe services <service_name>

#Expose a deployment as a new Kubernetes service
kubectl expose deployment <deployment_name> --port=[X] --target-port=[Y]

#Edit and update the definition of one or more services
kubectl edit services <service_name>

#delete a service
kubectl delete services <service_name>
```

_Select service type using --type . it could be ClusterIP, NodePort, LoadBalancer or ExternalName. Default is 'ClusterIP'._

_Services are using Labels, So it is very important for a Service that  a Label is present, if you try to expose something that doesn't have a lablel, you can use a Service on top of that._

### Service Accounts

Shortcode = **sa**

```
#List service accounts
kubectl get serviceaccounts

#Display the detailed state of one or more service accounts
kubectl describe serviceaccounts

#Replace a service account
kubectl replace serviceaccount

#Delete a service account
kubectl delete serviceaccount <service_account_name>
```

### StatefulSet

Shortcode = **sts**

```
#List StatefulSet
kubectl get statefulset

#Delete StatefulSet only (not pods)
kubectl delete statefulset/[stateful_set_name] --cascade=false
```

### Common Options

In Kubectl you can specify optional flags with commands. Here are some of the most common and useful ones. 

\-o Output format. For example if you wanted to list all of the pods in ps output format with more information:

```
kubectl get pods -o wide 
```

`  --dry-run  `you can generate the yaml file  using  kubectl command,  with out creating that object`:`

```
kubectl create pod <pod_name> --image=nginx --dry-run -o yaml > my-pod.yaml
```

\-n Shorthand for --namespace. For example, if you’d like to list all the Pods in a specific Namespace you would do this command:

```
kubectl get pods --namespace=[namespace_name]
kubectl get pods -n=[namespace_name]
```

`-f Filename`, directory, or URL to files to use to create a resource. For example when creating a pod using data in a file named newpod.json.

```
kubectl create -f ./newpod.json
```

 _**Create vs Apply** :kubectl create can be used to create new resources while kubectl apply inserts or updates resources while maintaining any manual changes made like scaling pods._

`--field-selector`let you [select Kubernetes resources](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects) based on the value of one or more resource fields.  This `kubectl` command selects all Pods for which the value of the [`status.phase`](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase) field is `Running`:

```
kubectl get pods --field-selector status.phase=Running
```

 You can use the `=`, `==`, and `!=` operators with field selectors (`=` and `==` mean the same thing). 

```
kubectl get pods -l environment=production,tier!=frontend
kubectl get pods -l 'environment in (production,test),tier notin (frontend,backend)'
```

 \--watch or -w - watch for changes:

```
kubectl get pods -n kube-system -w
```

`--record ` Add the current command as an annotation to the resource. The recorded change is useful for future introspection. For example, to see the commands executed in each Deployment revision:

```
#it would add CHANGE-CAUSE
kubectl create -f deployment-definition.yml --record 

#Now it shows CHANGE-CAUSE
kubectl rollout history deployment/myapp-deployment
```

`-h` for getting help:

```
kubectl -h
kubectl create -h
kubectl run -h
```

explain command is always handy:

```
kubectl explain deployment
kubectl explain deployment.spec
kubectl explain deployment.spec.strategy
```

good luck!

.

.

.

Collected by Payam Borosan


#Kubernetes commands 
#https://kubernetes.io/docs/reference/kubectl/cheatsheet/

###########
#Install
##########

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/windows/amd64/kubectl.exe        #Windows 

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"     #Linux 

brew install kubectl/brew install kubernetes-cli             #MacOS 


###########
#Configuration - view and modify configuration information 
##########
kubectl config view # Show Merged kubeconfig settings.
# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts 
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce

kubectl config unset users.foo                       # delete user foo

###########
#Apply - creates and updates resources in a cluster 
##########
kubectl apply -f ./my-manifest.yaml            # create resource(s)
kubectl apply -f ./my1.yaml -f ./my2.yaml      # create from multiple files
kubectl apply -f ./dir                         # create resource(s) in all manifest files in dir
kubectl apply -f https://git.io/vPieo          # create resource(s) from url
kubectl create deployment nginx --image=nginx  # start a single instance of nginx
kubectl explain pods                           # get the documentation for pod manifests



###########
#View and Find
##########
# Get commands with basic output
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the current namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML

# Describe commands with verbose output
kubectl describe nodes my-node
kubectl describe pods my-pod

# List Services Sorted by Name
kubectl get services --sort-by=.metadata.name

# List pods Sorted by Restart Count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# List PersistentVolumes sorted by capacity
kubectl get pv --sort-by=.spec.capacity.storage

# Get the version label of all pods with label app=cassandra
kubectl get pods --selector=app=cassandra -o \
  jsonpath='{.items[*].metadata.labels.version}'

# Retrieve the value of a key with dots, e.g. 'ca.crt'
kubectl get configmap myconfig \
  -o jsonpath='{.data.ca\.crt}'

# Get all worker nodes (use a selector to exclude results that have a label
# named 'node-role.kubernetes.io/master')
kubectl get node --selector='!node-role.kubernetes.io/master'

# Get all running pods in the namespace
kubectl get pods --field-selector=status.phase=Running

# Get ExternalIPs of all nodes
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# List Names of Pods that belong to Particular RC
# "jq" command useful for transformations that are too complex for jsonpath, it can be found at https://stedolan.github.io/jq/
sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})

# Show labels for all pods (or any other Kubernetes object that supports labelling)
kubectl get pods --show-labels

# Check which nodes are ready
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# List all Secrets currently in use by a pod
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

# List all containerIDs of initContainer of all pods
# Helpful when cleaning up stopped containers, while avoiding removal of initContainers.
kubectl get pods --all-namespaces -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{"\n"}{end}' | cut -d/ -f3

# List Events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Compares the current state of the cluster against the state that the cluster would be in if the manifest was applied.
kubectl diff -f ./my-manifest.yaml

# Produce a period-delimited tree of all keys returned for nodes
# Helpful when locating a key within a complex nested JSON structure
kubectl get nodes -o json | jq -c 'path(..)|[.[]|tostring]|join(".")'

# Produce a period-delimited tree of all keys returned for pods, etc
kubectl get pods -o json | jq -c 'path(..)|[.[]|tostring]|join(".")'


###########
#Resources
##########
#Types 
kubectl api-resources   #list all supported resource types along with thier shortnames,API, namespaced, kind
kubectl api-resources --namespaced=true      # All namespaced resources
kubectl api-resources --namespaced=false     # All non-namespaced resources
kubectl api-resources -o name                # All resources with simple output (just the resource name)
kubectl api-resources -o wide                # All resources with expanded (aka "wide") output
kubectl api-resources --verbs=list,get       # All resources that support the "list" and "get" request verbs
kubectl api-resources --api-group=extensions # All resources in the "extensions" API group

#Updating 
kubectl set image deployment/frontend www=image:v2               # Rolling update "www" containers of "frontend" deployment, updating the image
kubectl rollout history deployment/frontend                      # Check the history of deployments including the revision 
kubectl rollout undo deployment/frontend                         # Rollback to the previous deployment
kubectl rollout undo deployment/frontend --to-revision=2         # Rollback to a specific revision
kubectl rollout status -w deployment/frontend                    # Watch rolling update status of "frontend" deployment until completion
kubectl rollout restart deployment/frontend                      # Rolling restart of the "frontend" deployment


cat pod.json | kubectl replace -f -                              # Replace a pod based on the JSON passed into std

# Force replace, delete and then re-create the resource. Will cause a service outage.
kubectl replace --force -f ./pod.json

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000
kubectl expose rc nginx --port=80 --target-port=8000

# Update a single-container pod's image version (tag) to v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # Add a Label
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # Add an annotation
kubectl autoscale deployment foo --min=2 --max=10                # Auto scale a deployment "foo"

#Patching 
# Partially update a node
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

# Update a container's image; spec.containers[*].name is required because it's a merge key
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# Update a container's image using a json patch with positional arrays
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# Disable a deployment livenessProbe using a json patch with positional arrays
kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'

# Add a new element to a positional array
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'

#Editing
kubectl edit svc/docker-registry                      # Edit the service named docker-registry
KUBE_EDITOR="nano" kubectl edit svc/docker-registry   # Use an alternative editor

#Scaling
kubectl scale --replicas=3 rs/foo                                 # Scale a replicaset named 'foo' to 3
kubectl scale --replicas=3 -f foo.yaml                            # Scale a resource specified in "foo.yaml" to 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  # If the deployment named mysql's current size is 2, scale mysql to 3
kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   # Scale multiple replication controllers

#Deleting 
kubectl delete -f ./pod.json                                              # Delete a pod using the type and name specified in pod.json
kubectl delete pod,service baz foo                                        # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=myLabel                              # Delete pods and services with label name=myLabel
kubectl -n my-ns delete pod,svc --all                                      # Delete all pods and services in namespace my-ns,
# Delete all pods matching the awk pattern1 or pattern2
kubectl get pods  -n mynamespace --no-headers=true | awk '/pattern1|pattern2/{print $1}' | xargs  kubectl delete -n mynamespace pod
kubectl delete --all pods --namespace=foo   #Delete all pods in given namespace
kubectl delete --all deployments --namespace=foo    #Delete all deployments in 
kubectl delete namespaces <namespace>

###########
#Interacting
##########
#w/running Pods 
kubectl logs my-pod                                 # dump pod logs (stdout)
kubectl logs -l name=myLabel                        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod --previous                      # dump pod logs (stdout) for a previous instantiation of a container
kubectl logs my-pod -c my-container                 # dump pod container logs (stdout, multi-container case)
kubectl logs -l name=myLabel -c my-container        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod -c my-container --previous      # dump pod container logs (stdout, multi-container case) for a previous instantiation of a container
kubectl logs -f my-pod                              # stream pod logs (stdout)
kubectl logs -f my-pod -c my-container              # stream pod container logs (stdout, multi-container case)
kubectl logs -f -l name=myLabel --all-containers    # stream all pods logs with label name=myLabel (stdout)
kubectl run -i --tty busybox --image=busybox -- sh  # Run pod as interactive shell
kubectl run nginx --image=nginx -n 
mynamespace                                         # Run pod nginx in a specific namespace
kubectl run nginx --image=nginx                     # Run pod nginx and write its spec into a file called pod.yaml
--dry-run=client -o yaml > pod.yaml

kubectl attach my-pod -i                            # Attach to Running Container
kubectl port-forward my-pod 5000:6000               # Listen on port 5000 on the local machine and forward to port 6000 on my-pod
kubectl exec my-pod -- ls /                         # Run command in existing pod (1 container case)
kubectl exec my-pod -c my-container -- ls /         # Run command in existing pod (multi-container case)
kubectl top pod POD_NAME --containers               # Show metrics for a given pod and its containers


#w/nodes and clusters
kubectl cordon my-node                                                # Mark my-node as unschedulable
kubectl drain my-node                                                 # Drain my-node in preparation for maintenance
kubectl uncordon my-node                                              # Mark my-node as schedulable
kubectl top node my-node                                              # Show metrics for a given node
kubectl cluster-info                                                  # Display addresses of the master and services
kubectl cluster-info dump                                             # Dump current cluster state to stdout
kubectl cluster-info dump --output-directory=/path/to/cluster-state   # Dump current cluster state to /path/to/cluster-state

# If a taint with that key and effect already exists, its value is replaced as specified.
kubectl taint nodes foo dedicated=special-user:NoSchedule

##########
#kind
##########
brew install kind

kind create cluster

kind build node-image
kind create cluster --image kindest/node:latest

kind get clusters

kubectl cluster-info --context <name>

kind delete cluster --name    #if name flag is not specificed, kind uses the defualt cluster context name kind and deletes that cluster 


######################
#Running a simple container
######################
1. create a deployment: > kubectl create deployment --image nginx <name>
2. list pods: > kubectl get pods
3. view Deployment: > kubectl get deployment
4. scale Deployment: > kubectl scale deployment --replicas 2 <name>
5. list pods to check they are running: > kubectl get pods
6. expose kubectl as an API: > kubectl proxy
7. run : > POD_NAME=<pod-name>
8. run: > echo $POD_NAME
9. monitoring: 
  - curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME
  - kubectl logs $POD_NAME
  - kubectl exec $POD_NAME env
10. open container bash: > kubectl exec -ti $POD_NAME bash and run app: > curl http://localhost:80
11. run: > exit
12. cleanup deployments: > kubectl delete deployment <name>
13. cleanup Services: > kubectl delete svc <name>

#Expose to internet: 
1. kubectl expose deployment <name> --port=80 --type=LoadBalancer
2. view Service created: > kubectl get services or > kubectl get service -o wide
3. configure Cloud controller Manager to see External IP #TODO






list all pods that have more than one gcePersistentDisk volume in spec

kubectl get pods --all-namespaces  -o \
jsonpath="{range .items[*]}{'\n'}{.metadata.name}{': '}{range .spec.volumes[*]}{.gcePersistentDisk.pdName}{end}{'\n'}{end}" \
| tail -n +2 \
| awk 'NF>=2'
