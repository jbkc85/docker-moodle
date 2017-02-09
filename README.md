# docker-moodle

Moodle Docker Image, Documentation and Compose files to get Moodle up and running for development and production purposes.

## Build and Run

```sh
git clone https://github.com/jbkc85/docker-moodle.git
cd docker-moodle
docker build -t yourtag/moodle .
```

Once you have the image available, you need to have your config.php available for mounting

```sh
docker run -d -h moodle.example.com --name moodle.example.com \
    -v moodle-config.php:/var/www/html/config.php:ro \
    -p 80:80 yourtag/moodle
```

### Production Considerations

* Resources: Ensure that you have a good understanding of the resources required around running this container.  This will give you a better idea of how to deploy, when to scale, and what limits/requirements to set up upon deploying to your favorite orchestrator.
* Load Balancer: I typically don't run Moodle on port 443, rather use a front end load balancer.  This is reflected in the examples you see here and in the example on the [Kubernetes Deployment Tutorial](https://github.com/jbkc85/moodle-kubernetes-tutorial).


### Extending the Image

UNDER CONSTRUCTION...

## Testing

### Local Testing with Compose

If you are interested in running this container locally to see what it acts like, simply run the test-compose.yml which will provide you with a Postgres Database and Moodle.  By default it will be listening on the localhost port 41337 to avoid any issues with port collisions.

```sh
git clone https://github.com/jbkc85/docker-moodle.git
docker-compose -f test-compose.yml up -d
```

### TravisCI

This repository utilizes [TravisCI](https://travis-ci.org) for testing and then pushing to the Docker Hub.

```yaml
sudo: required
services:
  - docker
before_install:
  - docker-compose -f travis-compose.yml -p travis up -d
  - docker exec -it travis_moodle_1 /usr/local/bin/php /var/www/html/admin/cli/install_database.php --adminpass=pa55w0rd --adminemail=moodleadmin@example.com --agree-license --fullname TravisCI --shortname travis
  - curl -XGET --header 'Host: moodle.local' localhost
# Check site to see if it works
# run jMeter tests
# run PHPUnit Tests inside of container
```

**TODO**:

* create jMeter Tests
* run PHPUnit Tests from Moodle
* BeHat tests?


# M8s

To see Moodlenetes and a brief tutorial on deploying Moodle to Kubernetes, you can [follow the documentationa](https://github.com/jbkc85/moodle-kubernetes-tutorial)


