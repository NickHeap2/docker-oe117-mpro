# mpro install using setup image
FROM oe117-setup:latest AS mpro_install

# copy our response.ini in from our test install
COPY conf/response.ini /install/openedge/

#do a background progress install with our response.ini
RUN /install/openedge/proinst -b /install/openedge/response.ini -l silentinstall.log

# gcc-c++ for build
RUN yum install -y gcc-c++ && \
    yum clean all && \
    rm -rf /var/cache/yum

# build the 4gl client
WORKDIR /usr/dlc/oebuild/make
ENV DLC=/usr/dlc
RUN ./build_rx.sh

# replace the 4gl client and remove the license file
RUN cp /usr/dlc/oebuild/_progres /usr/dlc/bin/ && \
    rm /usr/dlc/progress.cfg

###############################################

# actual mpro server image
FROM centos:7.3.1611

LABEL maintainer="Nick Heap (nickheap@gmail.com)" \
 version="0.1" \
 description="Mpro Server Image for OpenEdge 11.7.2" \
 oeversion="11.7.2"

# Add Tini
ENV TINI_VERSION v0.18.0
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
 PROPATH="/var/lib/openedge/code/:/var/lib/openedge/base/" \
 LOGGING_LEVEL="2" \
 LOG_ENTRY_TYPES="DB.Connects,4GLMessages" \
 LOCK_FILE="" \
 LOG_FILE_NAME="mpro" \
 display_banner=no

# volume for application code
#VOLUME /var/lib/openedge/code/
#VOLUME /usr/wrk/

#EXPOSE

# Run start.sh under Tini
CMD ["/var/lib/openedge/start.sh"]

RUN mkdir /usr/wrk/

RUN adduser -G root openedge

RUN chmod -R 775 /usr/wrk/
RUN chown -R openedge:root /usr/wrk/

RUN chmod -R 775 /var/lib/openedge/code/
RUN chown -R openedge:root /var/lib/openedge/code/

# allow progress exe to access environment variables
RUN chmod 755 /usr/dlc/bin/_progres

USER 1000
