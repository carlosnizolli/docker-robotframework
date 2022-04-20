robot \
    ${ROBOT_LISTENER} \
    --outputDir ${ROBOT_REPORTS_DIR} \
    ${ROBOT_OPTIONS} \
    $ROBOT_TESTS_DIR 

robotmetrics -M metrics-log.html --inputpath $ROBOT_REPORTS_DIR --output output.xml --log log.html --logo  "${METRICS_LOGO}"