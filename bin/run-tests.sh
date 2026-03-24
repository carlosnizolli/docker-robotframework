#!/bin/sh

HOME=${ROBOT_WORK_DIR}

# Função para printar o comando que será executado
print_command() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 Comando Robot Framework a ser executado:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

if [ $ROBOT_THREADS -eq 1 ]
then
    # Monta o comando completo para exibição
    CMD="robot ${ROBOT_LISTENER} --outputDir ${ROBOT_REPORTS_DIR} ${ROBOT_OPTIONS} ${ROBOT_TESTS_DIR}"
    
    # Printa o comando
    print_command "$CMD"
    
    # Executa o comando
    xvfb-run \
        --server-args="-screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_COLOUR_DEPTH} -ac" \
        robot \
            ${ROBOT_LISTENER} \
            --outputDir ${ROBOT_REPORTS_DIR} \
            ${ROBOT_OPTIONS} \
            $ROBOT_TESTS_DIR 
else
    # Monta o comando completo para exibição
    CMD="pabot --verbose --artifactsinsubfolders --processes ${ROBOT_THREADS} ${PABOT_OPTIONS} --outputDir ${ROBOT_REPORTS_DIR} ${ROBOT_OPTIONS} ${ROBOT_TESTS_DIR}"
    
    # Printa o comando
    print_command "$CMD"
    
    # Executa o comando
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

exit $ROBOT_EXIT_CODE
