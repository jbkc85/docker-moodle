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
    -p 443:443 -p 80:80 yourtag/moodle
```

> Please take into consideration the resources needed to run this Container.  Moodle has a decent footprint and should not be taken for granted

## Testing

### Local Testing with Compose

If you are interested in running this container locally to see what it acts like, simply run the test-compose.yml which will provide you with a Postgres Database and Moodle.  By default it will be listening on the localhost port 41337 to avoid any issues with port collisions.

```sh
git clone https://github.com/jbkc85/docker-moodle.git
docker-compose -f test-compose.yml up -d
```

### TravisCI

UNDER CONSTRUCTION...

This repository utilizes [TravisCI](https://travis-ci.org) for testing and then pushing to the Docker Hub.  To find more information about TravisCI and its utilization in this repository, please look at the [Docs Directory for Testing](docs/testing.md)


# M8s

To see Moodlenetes and a brief tutorial on deploying Moodle to Kubernetes, you can [follow the documentationa](https://github.com/jbkc85/moodle-kubernetes-tutorial)


