FROM ubuntu:20.04

LABEL Robot Framework and libs

ENV DEBIAN_FRONTEND noninteractive 

ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

ENV ROBOT_TESTS_DIR /opt/robotframework/tests

ENV ROBOT_WORK_DIR /opt/robotframework/temp

ENV METRICS_LOGO https://upload.wikimedia.org/wikipedia/commons/e/e4/Robot-framework-logo.png

ENV TZ America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

COPY bin/run-tests.sh /opt/robotframework/bin/

RUN  apt-get update \
    && apt-get install -y python3-pip \
    && apt-get install -y nodejs
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN pip install \
    robotframework==5.0 \
    robotframework-browser==12.2.0 \
    robotframework-databaselibrary==1.2.4 \
    robotframework-datadriver==1.6.0 \
    robotframework-datetime-tz==1.0.6 \
    robotframework-faker==5.0.0 \
    robotframework-ftplibrary==1.9 \
    robotframework-imaplibrary2==0.4.2 \
    robotframework-pabot==2.5.2 \
    robotframework-requests==0.9.2 \
    robotframework-sshlibrary==3.8.0 \
    PyYAML \
    robotframework-metrics==3.2.2 \
    robotframework-notifications \
    pg8000==1.26.0 \
    tesults \
    robot-tesults

RUN pip3 install robotframework-browser \
    rfbrowser init

RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR}    

RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log  

ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

WORKDIR ${ROBOT_WORK_DIR}

CMD ["run-tests.sh"]
