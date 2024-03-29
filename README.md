# Docker para o Robot Framework em Ubuntu

### Contém as seguintes Libs
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

### Orientações gerais
- Utiliza o timezone São Paulo
- Preparado para a utilização do firefox
- Para executar é necessário informar caminho dos test_cases na variável ROBOT_TESTS_DIR
- O diretório de logs pode ser alterado com a variável ROBOT_REPORTS_DIR
- Para utilizar o tesults basta passar o listener completo na variável ROBOT_LISTENER
- Usar a variável ROBOT_OPTIONS para passar options do robot framework como --exitonfailure, --name, etc.

### Utilização no Actions
Esta imagem está no dockerhub, para usar no actions basta adicionar os seguintes steps:

        runs-on: ubuntu-18.04
            steps:
            - uses: actions/checkout@v2
            - name: Create folder for reports
              run:  mkdir -m 777 reports
            - name: Execute Robot tests
              uses: carlosnizolli/docker-robotframework@v06.1
              env:
                DOCKER_SHM_SIZE: 22000000
                BROWSER: firefox
                ROBOT_TESTS_DIR: ${{ github.workspace }}/SuaPasta/SeusTestes.robot
                ROBOT_REPORTS_DIR: ${{ github.workspace }}/reports
                ROBOT_OPTIONS: "--exitonfailure"
                ROBOT_LISTENER: --listener TesultsListener:target=${{ secrets.TESULTS_TARGET }}:build-name=SeuBuildName
 
 No exemplo está sendo criada uma pasta para gravação dos logs o que permite maior controle para exportações.
 
