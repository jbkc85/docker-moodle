Proxy Setup
-----------

As mentioned before, we will be using [Traefik](traefik.io).  To get traefik setup, you can just run the following command:

```sh
$ kubectl apply -f moodlenetes/proxy/
```

This will apply a Kubernetes Ingress Provider as well as a WebUI for Traefik.  This is basically taken directly from the [Kubernetes Documentation](https://docs.traefik.io/user-guide/kubernetes/) over at Traefik, so I won't be going too into detail here about it.

* Traefik Ingress: [proxy/traefik.yaml](moodlenetes/proxy/traefik.yaml)
* Traefik WebUI: [proxy/traefik-webui.yaml](moodlenetes/proxy/traefik-webui.yaml)

To verify we have our proxy setup (taken directly from the documentation in Traefik mentioned earlier), simply run the following:

```sh
$ kubectl get pods --namespace=kube-system
NAME                                         READY     STATUS    RESTARTS   AGE
kube-addon-manager-minikube                  1/1       Running   3          29d
kubernetes-dashboard-fhz0w                   1/1       Running   3          29d
tiller-deploy-327544198-dgfaw                1/1       Running   3          29d
traefik-ingress-controller-678226159-q50aw   1/1       Running   0          11s
```
> notice the traefik-ingress-controller and you are good

```sh
$ curl -XGET $(minikube ip)
404 page not found
```
> we get a 404 because no ingress is currently configured for the minikube ip, and therefore nothing is routed.

*Note:* The reason we only create a service and ingress in the ``traefik-webui.yaml`` is because the ``traefik.yaml`` actually starts the WebUI on port 8080 - it just doesn't expose it outside of the internal network.

