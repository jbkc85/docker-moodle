# docker-moodle
Moodle Docker Image, Documentation and Compose files to get Moodle up and running for development and production purposes.

# Setup

There are multiple ways to get this container up and running, and which way you choose really depends on your environment.

### Docker Compose

docker-compose is a valid choice for production deployments, however in this particular compose file I am keeping persistent data out of the equation as unless you know more about volumes and persistent data in Docker, its easier to keep these resources outside of your container environment (please note, that if you have someone who does understand all the ends-and-outs of the volume/container data environment let them help you out!).

### Kubernetes
