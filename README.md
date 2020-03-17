# ss\_homework
Basic nginx container running on Ubuntu or CentOS


## Packer Template
- uses Docker builder
- uses Ansible, Puppet, or Shell provisioners
- makes generic nginx server in a ubuntu:latest or centos:latest container
- operating system switches via Packer command line
- after build, should push Docker image to a docker hub account creating either a <yourDockerHubUser>/ubuntu-nginx or <yourDockerHubUser>/centos-nginx container
- SSL is not required and should be disabled in nginx config file
- serve an index.html "hello world" text document via `docker run -v /tmp/test_html:/html -p 8888:80 homework/nginx-ubuntu:latest`

