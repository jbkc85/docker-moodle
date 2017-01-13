Moodlenetes
===========

----

----

**WARNING**

This documentation is purely for example.  Please take into consideration all resource restraints and deployment options (such as logging) before taking this tutorial into production.  I will be adding bits and pieces over time as I am more familiar with best practices, but also welcome any comments/suggestions as people walkthrough this tutorial!

**WARNING**

----

----

**Table of Contents**:

1. [Getting Started](#getting_started)
2. [Proxy Setup](traefik.md)
  * TLDR; deploy with copy/paste
3. [Postgres Setup](postgres.md)
  * TLDR; deploy with copy/paste
4. [Moodle Setup](moodle.md)
  * TLDR; deploy with copy/paste

----

Moodlenetes is a Kubernetes deployment of Moodle.  There is absolutely an intention to move this to a [Helm Chart](http://helm.sh) however deploying Moodle to Kubernetes was the priority.  In this example I will walk you through setting up an Ingress Proxy, Postgres and finally Moodle in your Kubernetes environment to deploy Moodle.

> Note that the Ingress Proxy used here, [Traefik](traefik.io), is interchangable with any other method you choose.

---

Getting Started
---------------

**Don't have Kubernetes?**: I suggest starting with [MiniKube](https://github.com/kubernetes/minikube) to get going.

First and foremost, to get the files mentioned in this tutorial please clone the [docker-moodle](https://github.com/jbkc85/docker-moodle) repository.  As stated before, I plan on moving Moodlenetes to a Helm Chart after I get the initial manifests created.

```sh
$ git clone https://github.com/jbkc85/docker-moodle
$ cd docker-moodle
```
