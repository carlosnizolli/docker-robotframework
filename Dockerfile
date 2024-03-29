FROM ubuntu:20.04

LABEL maintainer="Carlos Nizolli carlosnizolli@gmail.com - Robot Framework and libs"

ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

ENV ROBOT_TESTS_DIR /opt/robotframework/tests

ENV ROBOT_WORK_DIR /opt/robotframework/temp

ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

ENV TZ America/Sao_Paulo

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

ENV ROBOT_THREADS 1

COPY bin/run-tests.sh /opt/robotframework/bin/
RUN chmod 777 /opt/robotframework/bin/run-tests.sh
RUN chmod u+x /opt/robotframework/bin/run-tests.sh

RUN  apt-get update 
RUN  apt-get upgrade -y
RUN  apt-get install -y python3-pip 

RUN  apt-get install -y curl
RUN  curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN  apt-get install -yq nodejs build-essential \
      && node -v \
      && npm -v \
      && npm init -y

RUN apt-get install -y xvfb

RUN apt-get install -y firefox

RUN apt-get install -y libgtk-3-dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    libnss3 \
    libxss1 \
    libasound2 \
    fonts-noto-color-emoji \
    libxtst6
    
RUN apt-get -y install chromium-browser

RUN pip3 install \
    --no-cache-dir \
    cryptography==39.0.1 \
    robotframework-xvfb \
    robotframework-csvlib \
    requests==2.28.2 \
    robotframework==6.0.2 \  
    robotframework-browser==16.0.0 \  
    robotframework-databaselibrary==1.2.4 \
    robotframework-datadriver==1.7.0 \
    robotframework-datetime-tz==1.0.6 \
    robotframework-faker==5.0.0 \
    robotframework-ftplibrary==1.9 \
    robotframework-imaplibrary2==0.4.6 \
    robotframework-pabot==2.13.0 \
    robotframework-requests==0.9.4 \
    robotframework-sshlibrary==3.8.0 \
    PyYAML \
    robotframework-notifications \
    pg8000==1.29.4 \
    tesults \
    robot-tesults \
    robotframework-jsonlibrary==0.5 \
    robotframework-autorecorder \
    robotframework-screencaplibrary==1.6.0

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN echo "$TZ" | tee /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN rfbrowser init
 
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR}    

RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

ENV PATH=/opt/robotframework/bin:$PATH

VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

WORKDIR ${ROBOT_WORK_DIR}

CMD ["run-tests.sh"]
