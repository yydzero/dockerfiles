FROM centos:7

# This dockfile contains a basic CentOS 7 image with common 
# used development tools and some common devel pkgs.
#
# Will also create a user named 'test', and setup
# passwordless SSH 

MAINTAINER yydzero@gmail.com

RUN yum -y update \
    && yum -y groupinstall "Development tools" \
    && yum -y install epel-release      \
    && yum -y install apr-devel         \
                      bzip2-devel       \
                      ccache            \
                      cmake             \
                      curl-devel        \
                      htop              \
                      iproute           \
                      libevent-devel    \
                      libffi-devel      \
                      libxml2-devel     \
                      libyaml           \
                      libyaml-devel     \
                      mc                \
                      net-tools         \
                      openssl-devel     \
                      openssl-libs      \
                      openssh-server    \
                      perl-CPAN         \
                      perl-devel        \
                      perl-ExtUtils-Embed   \
                      psmisc            \
                      python-devel      \
                      readline-devel    \
                      vim               \
                      zlib-devel

RUN yum -y install sudo

ADD setup_ssh.sh setup_ssh.sh

# Add a test user
RUN useradd -ms /bin/bash -d /home/test test \
    && echo '%test ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo "test:changeme" | chpasswd

RUN /setup_ssh.sh
