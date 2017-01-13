Moodle
======

Now what we have all been waiting for, the deployment of Moodle.  In this example, Moodle will be utilizing the following resources in Kubernetes:

* [Persistent Volume](https://kubernetes.io/docs/user-guide/persistent-volumes/): Once again, the Persistent Volume is used to ensure our 'moodledata' is not erased on accident when/if this group of pods are destroyed. In production deployments, I would highly suggest looking into alternative methods other than Host-based Mounting, but as this is an example it is what I am using. [skip to PersistentVolumes]()
* [Service](https://kubernetes.io/docs/user-guide/services/): As mentioned before Services expose underlying pods in a given namespace. [skip to Services]()
* [Ingress](https://kubernetes.io/docs/user-guide/ingress/): An ingress is an instruction to inform Kubernetes (also Traefik in our tutorial) on how to route incoming traffic. [skip to Ingress]()
* [ConfigMap](https://kubernetes.io/docs/user-guide/configmap/): ConfigMaps are as they sound, a method of storing configurations in Kubernetes. Please remember to read about them and security implications before using them in Production! [skip to configmap]()
* [Deployment](https://kubernetes.io/docs/user-guide/deployments/): Providing metadata to spin up pods and replica sets in Kubernetes. [skip to Deployment]()

Persistent Volume
-----------------

Again, creating the persitent-volume is pretty straight forward.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-moodledata-pv
  labels:
    type: local
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /tmp/moodledata
```

Because we are using a persistent volume on the hostPath, we are going to have to create it manually and adjust some permissions to ensure its readable/writable by ``www-data``, our Moodle user.

```sh
$ minikube ssh mkdir /tmp/moodledata
$ minikube ssh sudo chown 33:33 /tmp/moodledata
$ kubectl apply -f moodlenetes/moodle/persistent-volume.yaml
```

Check our work:

```sh
$ kubectl describe pv local-moodledata-pv
Name:		local-moodledata-pv
Labels:		type=local
Status:		Available
Claim:
Reclaim Policy:	Retain
Access Modes:	RWO
Capacity:	2Gi
Message:
Source:
    Type:	HostPath (bare host directory volume)
    Path:	/tmp/moodledata
```

Service and Ingress
-------------------

Now we want to create a service and Ingress for the underlying Moodle deployment.  Note we are doing this first before any deployment is created.

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: moodle
  labels:
    app: moodle
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: moodle
    tier: frontend
```

> Note: If you want to use SSL, you would still only expose port 80 on this device.  Port 443 would be exposed on the proxy which would be responsible for all SSL transactions while the backend can still simply listen on 80.


### Ingress

For this ingress, we can use the following host map to access Moodle once brought up in the cluster:

``$(minikube ip) : http://moodle.local``

This is due to the fact our rules in the Ingress map to 'moodle.local', which then will map to oour backend service (under the backend serviceName metadata).

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: moodle-ingress
spec:
  rules:
  - host: moodle.local
    http:
      paths:
      - backend:
          serviceName: moodle
          servicePort: 80
```


```sh
$ kubectl apply -f moodlenetes/moodle/service.yaml
service "moodle" created
$ kubectl apply -f moodlenetes/moodle/ingress.yaml
ingress "moodle-ingress" created
```

Check our work:

```sh
$ kubectl describe svc moodle
Name:			moodle
Namespace:		default
Labels:			app=moodle
Selector:		app=moodle,tier=frontend
Type:			ClusterIP
IP:			10.0.0.64
Port:			<unset>	80/TCP
Endpoints:		<none>
Session Affinity:	None
$ kubectl describe ingress moodle-ingress
Name:			moodle-ingress
Namespace:		default
Address:
Default backend:	default-http-backend:80 (<none>)
Rules:
  Host		Path	Backends
  ----		----	--------
  moodle.local
    		 	moodle:80 (<none>)
Annotations:
No events.
```

ConfigMap
---------

As mentioned at the top, using configMap isn't for everyone.  This can certainly be done a bit more securely using an ![ExtraDopeBadge](https://img.shields.io/badge/Hightower-extra%20dope-E5E4E2.svg) tool like [Kelsey Hightower's Konfd](https://github.com/kelseyhightower/konfd) or the likes, so please keep that in mind as we work through this tutorial.

Basically, I am going to take our config.php that we use with Moodle and pump it into configMap.  *If you make changes to any of the above persistent volumes or ingress settings, you will need to make changes in the file used in this configMap*.

```sh
$ kubectl create configmap moodle-site-config --from-file=moodlenetes/moodle/moodle-config.php
configmap "moodle-site-config" created
```

Check our work:

```sh
$ kubectl get configmaps moodle-site-config -o yaml
apiVersion: v1
data:
  moodle-config.php: |
    <?php  // Moodle configuration file

    unset($CFG);
    global $CFG;
    $CFG = new stdClass();

    $CFG->dbtype    = 'pgsql';
    $CFG->dblibrary = 'native';
    $CFG->dbhost    = 'moodle-postgresql';
    $CFG->dbname    = 'moodle';
    $CFG->dbuser    = 'moodle';
    $CFG->dbpass    = 'moodle';
    $CFG->prefix    = 'mdl';
    $CFG->dboptions = array (
      'dbpersist' => 0,
    );

    $CFG->wwwroot  = 'http://moodle.local';
    $CFG->dataroot  = '/var/moodledata';
    $CFG->admin     = 'admin';

    $CFG->directorypermissions = 02775;

    $CFG->passwordsaltmain = 'y0uR34l!ySh0uldtU$3-th1sS&lt';

    require_once "/var/www/html/lib/setup.php";
    // There is no php closing tag in this file,
    // it is intentional because it prevents trailing whitespace problems!
kind: ConfigMap
metadata:
  creationTimestamp: 2017-01-13T15:36:38Z
  name: moodle-site-config
  namespace: default
  resourceVersion: "6087"
  selfLink: /api/v1/namespaces/default/configmaps/moodle-site-config
  uid: 12db3f35-d9a6-11e6-9f63-4217ea3347ce
```

Great, we should be good to go for the deployment!


Deployment
----------

The deployment is identical to the Postgres deployment in many ways - using the PersistentVolumeClaim and basic Deployment kubernetes objects.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: moodledata-claim
  labels:
    app: moodle
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: moodle
  labels:
    app: moodle
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: moodle
        tier: frontend
    spec:
      containers:
      - image: jbkc85/docker-moodle
        name: moodle
        ports:
        - containerPort: 80
          name: moodle
        resources:
          requests:
            cpu: 300m
            memory: 128Mi
        volumeMounts:
        - name: moodledata
          mountPath: /var/moodledata
        - name: config
          mountPath: /var/moodlecfg
      volumes:
      - name: moodledata
        persistentVolumeClaim:
          claimName: moodledata-claim
      - name: config
        configMap:
          name: moodle-site-config
          items:
          - key: moodle-config.php
            path: config.php
```

Lets fire her up!

```sh
$ kubectl apply -f moodlenetes/moodle/deployment.yaml
persistentvolumeclaim "moodledata-claim" created
deployment "moodle" created
```

Check our work:

```sh
$ kubectl describe deployment moodle
Name:			moodle
Namespace:		default
CreationTimestamp:	Fri, 13 Jan 2017 09:54:39 -0600
Labels:			app=moodle
Selector:		app=moodle,tier=frontend
Replicas:		1 updated | 1 total | 0 available | 1 unavailable
StrategyType:		Recreate
MinReadySeconds:	0
OldReplicaSets:		<none>
NewReplicaSet:		moodle-476540258 (1/1 replicas created)
Events:
  FirstSeen	LastSeen	Count	From				SubobjectPath	Type		Reason			Message
  ---------	--------	-----	----				-------------	--------	------			-------
  19s		19s		1	{deployment-controller }			Normal		ScalingReplicaSet	Scaled up replica set moodle-476540258 to 1
```