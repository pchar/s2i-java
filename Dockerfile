# s2i-java
FROM openshift/base-centos7
MAINTAINER Patrick Charbonneir <charbo@nextmind.net>
# HOME in base image is /opt/app-root/src
 
# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.6
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel tree" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src
## check maven version test 
ENV MAVEN_VERSION 3.5.2
RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2


ENV PATH=/opt/maven/bin/:$PATH

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Mule  applications with maven " \
      io.k8s.display-name="Mule S2I builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,java,microservices,mule"

# TODO (optional): Copy the builder files into /opt/openshift
# COPY ./<builder_folder>/ /opt/openshift/
# COPY Additional files,configurations that we want to ship by default, like a default setting.xml
COPY ./contrib/settings.xml $HOME/.m2/

LABEL io.openshift.s2i.scripts-url=image:///usr/local/sti
COPY ./sti/bin/ /usr/local/sti
############### MULE STUFF  #####################
ENV MULE_VERSION=3.9.0

RUN curl -s  https://repository-master.mulesoft.org/nexus/service/local/repositories/releases/content/org/mule/distributions/mule-standalone/$MULE_VERSION/mule-standalone-$MULE_VERSION.tar.gz -o mule-standalone-$MULE_VERSION.tar.gz  
RUN cd /opt && tar xvzf ~/mule-standalone-$MULE_VERSION.tar.gz 2>&1 /dev/null
RUN rm ~/mule-standalone-$MULE_VERSION.tar.gz
RUN ln -s /opt/mule-standalone-$MULE_VERSION /opt/mule 





##############################################


RUN chown -R 1001:1001 /opt/openshift


# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
