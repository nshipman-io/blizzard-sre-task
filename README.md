# Blizzard SRE Task

## Setup
* Go through the kind installation process from their [documentation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## Task

- Start v1 of the application
- Write a simple test client to call {service_base_url}/version repeatedly
- Update the version of the sample application
- Utilize your deployment strategy to execute a blue/green deploy of test application v2
- Capture the output of your test client to show that no requests failed and the version being returned from the sample application changed

## Prerequisites MacOS
- [brew](https://brew.sh/)
- [Docker](https://docs.docker.com/get-docker/)
- Kubernetes
    - `brew install kubectl`
- Kind (Kubernetes in Docker)
    - `brew install kind`

## Setting up Kind Cluster
- You can deploy and test `th3-server` by running `make run_cluster` in the root of this repository.
    - Running make will build a kind cluster called `blizzard-1` with the `nginx-ingress` controller running in the `ingress-nginx` namespace. 
- You can initialize the cluster resources by running `make VERSION=0.0.1 init_app` which will perform the following operations:
  - Build `th3-server` webapp container
  - Load the image from our local docker daemon into the kind cluster
  - Apply the deployment, service and ingress manifests in the `default` namespace on your `blizzard-1` cluster
  
- Once deployed, open your web-browser and enter the address `localhost/version`. You should see the output `{'version': '0.0.1', 'errors': []}`.

- You can also test from the terminal with `curl localhost/version` and if successful, receive the following response:

```
{'version': '0.0.1', 'errors': []}
```

## Blue/Green Deployment Method
We want to ensure we are able to run two separate versions of our application and be able to cutover seamlessly with 0 downtime.

### Update the Non-Active Deployment with the Latest Version
- Run `make VERSION=$NEW_VERSION update_deploy` which will build and tag a new version of the webapp.
```
make VERSION=0.0.3 update_deploy
```
### Swap the current Live Deployment with the Latest Version
- Run `make blue_green_swap`
```
> make blue_green_swap
./scripts/bg-swap.sh
service/th3-server-service configured
Switched to the green environment.
```

### Rolling Back
In the event that you need to rollback the deployment, due to errors running `make blue_green_swap` will revert the environment to the previous deployment.
```
> make blue_green_swap
./scripts/bg-swap.sh
service/th3-server-service configured
Switched to the blue environment.

```
### Verification
```
> kubectl describe deployments
Name:                   th3-server-blue
Namespace:              default
CreationTimestamp:      Fri, 28 Apr 2023 08:24:00 -0400
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 5
Selector:               app=th3-server,version=blue
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=th3-server
           version=blue
  Containers:
   th3-server-container:
    Image:      th3-server:0.0.2
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      APP_VERSION:  0.0.2
    Mounts:         <none>
  Volumes:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   th3-server-blue-746bf57f6f (2/2 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  58m                deployment-controller  Scaled up replica set th3-server-blue-544d595c88 to 1
  Normal  ScalingReplicaSet  57m (x2 over 58m)  deployment-controller  Scaled down replica set th3-server-blue-544d595c88 to 0 from 1
  Normal  ScalingReplicaSet  57m (x2 over 58m)  deployment-controller  Scaled up replica set th3-server-blue-746bf57f6f to 1 from 0
  Normal  ScalingReplicaSet  57m                deployment-controller  Scaled down replica set th3-server-blue-746bf57f6f to 0 from 1
  Normal  ScalingReplicaSet  57m                deployment-controller  Scaled up replica set th3-server-blue-544d595c88 to 1 from 0
  Normal  ScalingReplicaSet  57m                deployment-controller  Scaled down replica set th3-server-blue-b85dfc8dc to 1 from 2
  Normal  ScalingReplicaSet  57m                deployment-controller  Scaled up replica set th3-server-blue-746bf57f6f to 2 from 1
  Normal  ScalingReplicaSet  57m                deployment-controller  Scaled down replica set th3-server-blue-b85dfc8dc to 0 from 1


Name:                   th3-server-green
Namespace:              default
CreationTimestamp:      Fri, 28 Apr 2023 08:27:45 -0400
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=th3-server,version=green
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=th3-server
           version=green
  Containers:
   th3-server-container:
    Image:      th3-server:0.0.3
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      APP_VERSION:  0.0.3
    Mounts:         <none>
  Volumes:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   th3-server-green-549f9859bd (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled up replica set th3-server-green-57c59dd694 to 1
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled down replica set th3-server-green-57c59dd694 to 0 from 1
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled up replica set th3-server-green-549f9859bd to 1 from 0
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled down replica set th3-server-green-77f88cf788 to 1 from 2
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled up replica set th3-server-green-549f9859bd to 2 from 1
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled down replica set th3-server-green-77f88cf788 to 0 from 1
```
Additional verification can be found in the `README.md` of the `overwatched` directory, showcasing 0 downtime. Instructions for running the client can be found in the directory as well for your own verification.

## Cleanup
- `make delete_cluster` from the root of the repo, will delete the `blizzard-1` kind cluster.
