# ss\_homework
Basic nginx container running on Ubuntu or CentOS

## Packer criteria
- uses Docker builder
- uses Ansible, Puppet, or Shell provisioners
- makes generic nginx server in a ubuntu:latest or centos:latest container
- operating system switches via Packer command line
- after build, should push Docker image to a docker hub account creating either a `<yourDockerHubUser>/ubuntu-nginx` or `<yourDockerHubUser>/centos-nginx` container
- SSL is not required and should be disabled in nginx config file
- serve an index.html "hello world" text document via `docker run -v /tmp/test_html:/html -p 8888:80 homework/nginx-ubuntu:latest`

## Usage
Built with:
```
read -s -p "Enter docker hub password: " docker_hub_password
packer build -var "docker_hub_password=\"${docker_hub_password}\"" -var "image=\"centos:latest\"" packer
packer build -var "docker_hub_password=\"${docker_hub_password}\"" -var "image=\"ubuntu:latest\"" packer
```

Images tested with:
```
mkdir -p /tmp/test_html ; echo "hello world" > /tmp/test_html/index.html
docker run -v /tmp/test_html:/html -p 8888:80 homework/nginx-centos:latest
docker run -v /tmp/test_html:/html -p 8888:80 homework/nginx-ubuntu:latest
docker run -v /tmp/test_html:/html -p 8888:80 robzr/centos-nginx
docker run -v /tmp/test_html:/html -p 8888:80 robzr/ubuntu-nginx
```

## Caveats
- Packer HCL2 support appears to be immature, and JSON would probably be a better choice for production use
- Depending on usage, the choice to modify distro nginx configs rather than supplying user configs may be sub-optimal
- For security, a dedicated config, non-privileged port, and running as non-root would be preferable

## Branches
- robzr/packer\_bug - Simplified Packer template demonstrating bug
- robzr/testing\_nightly\_build - Updated version of template that *should* work with fixed Packer

## robzr/testing\_nightly\_build for use with Packer v1.5.5 (pre-release)
The upcoming Packer v1.5.5 will fix the local ref issue, as well as change the variable quoting behavior.
When using with v1.5.5 (or current nightly build), the following var syntax is used to build:
```
read -s -p "Enter docker hub password: " docker_hub_password
packer build -var "docker_hub_password=${docker_hub_password}" -var "image=centos:latest" packer
packer build -var "docker_hub_password=${docker_hub_password}" -var "image=ubuntu:latest" packer
```
