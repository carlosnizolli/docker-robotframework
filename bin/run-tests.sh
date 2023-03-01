#!/bin/sh

HOME=${ROBOT_WORK_DIR}

if [ $ROBOT_THREADS -eq 1 ]
then
    xvfb-run \
        --server-args="-screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_COLOUR_DEPTH} -ac" \
        robot \
            ${ROBOT_LISTENER} \
            --outputDir ${ROBOT_REPORTS_DIR} \
            ${ROBOT_OPTIONS} \
            $ROBOT_TESTS_DIR 
else
    xvfb-run \
        --server-args="-screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_COLOUR_DEPTH} -ac" \
        pabot \
        --verbose \
        --artifactsinsubfolders \
        --processes $ROBOT_THREADS \
        ${PABOT_OPTIONS} \
        --outputDir ${ROBOT_REPORTS_DIR} \
        ${ROBOT_OPTIONS} \
        $ROBOT_TESTS_DIR
fi       

ROBOT_EXIT_CODE=$?

robotmetrics -M metrics-log.html --inputpath $ROBOT_REPORTS_DIR --output output.xml --log log.html

exit $ROBOT_EXIT_CODE