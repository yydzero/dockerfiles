FROM centos:7

# This dockfile contains a basic CentOS 7 image with common 
# used development tools and some common devel pkgs.

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

