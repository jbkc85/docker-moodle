Postgres Setup
--------------

Postgres is another obvious interchangable part of the Moodlenetes setup.  However since the database of Moodle is essential, I will be going a bit more in detail on how to set it up.

### Persistent Volume

The first step is getting a persistent volume setup in Kubernetes.  This is important as if you don't create a persistent volume, the data from Postgres can be potentially lost.

$ cat moodlenetes/postgres/persistent-volume.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-postgresql-pv
  labels:
    type: local
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/postgresql
```

----

### Secrets

Passwords in Kubernetes isn't that difficult if you pass them in through the environment.  However, this isn't secure nor a best practice.  Therefore instead of making an 'easy tutorial', we are going to go through the creation of secrets.  For this particular setup, we use four secrets: Root Password, Database, Username and Password.  To create them, we basically upload them to the API through the 'secrets' type from plain text files.

If you wish to create your own text files, simply use the following:

```sh
# create txt files if you wish
$ echo -n "your_value" > moodlenetes/postgres/postgres-rootpassword.txt
$ echo -n "your_value" > moodlenetes/postgres/postgres-database.txt
$ echo -n "your_value" > moodlenetes/postgres/postgres-user.txt
$ echo -n "your_value" > moodlenetes/postgres/postgres-password.txt
```

If you wish to use the default (everything is ``moodle``), just leave the files as they are.

Whichever you choose, its now time to upload these secrets.  Once again, to read more about Secrets [just visit the documentation site](https://kubernetes.io/docs/user-guide/secrets/).

```sh
$ kubectl create secret generic postgres-credentials --from-file=moodlenetes/postgres/postgres-rootpassword.txt --from-file=moodlenetes/postgres/postgres-database.txt --from-file=moodlenetes/postgres/postgres-user.txt --from-file=moodlenetes/postgres/postgres-password.txt
```

After the secret is created, you should be able to describe it based on the name given, in our case ``postgres-credentials``.

```sh
$ kubectl describe secret postgres-credentials
Name:		postgres-credentials
Namespace:	default
Labels:		<none>
Annotations:	<none>

Type:	Opaque

Data
====
postgres-database.txt:		6 bytes
postgres-password.txt:		6 bytes
postgres-rootpassword.txt:	6 bytes
postgres-user.txt:		6 bytes
```

Now we have our secrets, and we can get onto the Deployment!

----

### Deployment

The deployment of Postgres in Kubernetes requires a few pieces to operate as we want it to.  Though they all are organized in the same YAML file, I will show each one in detail here.

$ cat moodlenetes/postgres/deployment.yaml

First, we have our a service.  The service allows for communication to the pods under the ``selector`` metadata.  To learn more about services in Kubernetes, simply [read the docs for services](https://kubernetes.io/docs/user-guide/services/).

> Please note that this port is exposed only internally to the pods in the namespace we created.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: moodle-postgresql
  labels:
    app: moodle
spec:
  ports:
    - port: 5432
  selector:
    app: moodle
    tier: postgresql
  clusterIP: None
```

Next, we have to claim our Persistent Volume, which you created in the first step.  In some cases, a Persistent Volume can only have a certain amount of claims.  So, in this particular example we are making our claim!

Once again, to read more about [Persistent Volumes](https://kubernetes.io/docs/user-guide/persistent-volumes/), go to the Kubernetes Docs!

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-claim
  labels:
    app: moodle
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Finally, we get to the deployment.

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: moodle-postgresql
  labels:
    app: moodle
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: moodle
        tier: postgresql
    spec:
      containers:
      - image: postgres:9.5-alpine
        name: database
        env:
        - name: ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: postgres-rootpassword.txt
        - name: DATABASE
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: postgres-database.txt
        - name: USER
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: postgres-username.txt
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: postgres-password.txt
        ports:
        - containerPort: 5432
          name: postgresql
        volumeMounts:
        - name: postgresql-persistent-storage
          mountPath: /var/lib/postgresql/
      volumes:
      - name: postgresql-persistent-storage
        persistentVolumeClaim:
          claimName: postgresql-claim
```

#### TLDR;

```sh
$ kubectl create secret generic postgres-credentials --from-file=moodlenetes/postgres/postgres-rootpassword.txt --from-file=moodlenetes/postgres/postgres-database.txt --from-file=moodlenetes/postgres/postgres-user.txt --from-file=moodlenetes/postgres/postgres-password.txt
$ kubectl apply -f moodlenetes/postgres/

```
