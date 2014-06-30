FROM phusion/baseimage:0.9.11
MAINTAINER botez <troyolson1@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Add the JAVA repository, import it's key and accept it's license
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | sudo /usr/bin/debconf-set-selections

RUN apt-get update -qq && \
    apt-get install -qq --force-yes grep sed cpio gzip oracle-java7-installer supervisor && \
    apt-get autoremove && \
    apt-get autoclean

ADD crashplan-install.sh /opt/
ADD crashplan.sh /opt/
RUN bash /opt/crashplan-install.sh && \
    chmod 777 /opt/crashplan.sh && \
    mkdir -p /var/lib/crashplan && \
    chown -R nobody /usr/local/crashplan /var/lib/crashplan

VOLUME /data

EXPOSE 4242 4243

# Add Madsonic to runit
RUN mkdir /etc/service/crashplan
ADD crashplan_start.sh /etc/service/crashplan/run
RUN chmod +x /etc/service/crashplan/run
