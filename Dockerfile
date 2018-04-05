# mpro install using setup image
FROM oe117-setup:latest AS mpro_install

# copy our response.ini in from our test install
COPY conf/response.ini /install/openedge/

#do a background progress install with our response.ini
RUN /install/openedge/proinst -b /install/openedge/response.ini -l silentinstall.log

###############################################

# actual mpro server image
FROM centos:7.3.1611

LABEL maintainer="Nick Heap (nickheap@gmail.com)" \
 version="0.1" \
 description="Mpro Server Image for OpenEdge 11.7.2" \
 oeversion="11.7.2"

# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# copy openedge files in
COPY --from=mpro_install /usr/dlc/ /usr/dlc/

# the directories for the appserver code
RUN mkdir -p /var/lib/openedge/base/ && mkdir -p /var/lib/openedge/code/

COPY base/ /var/lib/openedge/base/

WORKDIR /var/lib/openedge/code/

# add startup script
COPY scripts/ /var/lib/openedge/

# set required vars
ENV \
 TERM="xterm" \
 JAVA_HOME="/usr/dlc/jdk/bin" \
 PATH="$PATH:/usr/dlc/bin:/usr/dlc/jdk/bin" \
 DLC="/usr/dlc" \
 WRKDIR="/usr/wrk" \
 PROCFG="" \
 MPRO_STARTUP=" -b -p server.p" \
 PROPATH="/var/lib/openedge/base/:/var/lib/openedge/code/" \
 LOGGING_LEVEL="2" \
 LOG_ENTRY_TYPES="DB.Connects,4GLMessages" \
 LOCK_FILE=""

# volume for application code
VOLUME /var/lib/openedge/code/
VOLUME /usr/wrk/

#EXPOSE

# Run start.sh under Tini
CMD ["/var/lib/openedge/start.sh"]

