# ============================================================================
# Stage 1: Base - Sistema operacional e configurações básicas
# ============================================================================
FROM ubuntu:24.04 AS base

LABEL maintainer="Carlos Nizolli carlosnizolli@gmail.com - Robot Framework and libs"
LABEL org.opencontainers.image.title="Robot Framework QA - Web/E2E Testing"
LABEL org.opencontainers.image.description="Imagem Docker completa para testes automatizados Web/E2E com Robot Framework, Browser Library, Playwright, Self-Healing e IA"
LABEL org.opencontainers.image.authors="Carlos Nizolli <carlosnizolli@gmail.com>"
LABEL org.opencontainers.image.vendor="Carlos Nizolli"
LABEL org.opencontainers.image.documentation="https://github.com/carlosnizolli/docker-robotframework/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/carlosnizolli/docker-robotframework"
LABEL org.opencontainers.image.url="https://github.com/carlosnizolli/docker-robotframework"
LABEL org.opencontainers.image.version="7.2.2"
LABEL com.logcomex.image.type="web-testing"
LABEL com.logcomex.robot.version="7.2.2"
LABEL com.logcomex.browser.library="19.12.3"

# Variáveis de ambiente
ENV ROBOT_REPORTS_DIR=/opt/robotframework/reports \
    ROBOT_TESTS_DIR=/opt/robotframework/tests \
    ROBOT_WORK_DIR=/opt/robotframework/temp \
    SCREEN_COLOUR_DEPTH=24 \
    SCREEN_HEIGHT=1080 \
    SCREEN_WIDTH=1920 \
    LANG=pt_BR.UTF-8 \
    LC_ALL=pt_BR.UTF-8 \
    TZ=America/Sao_Paulo \
    ROBOT_UID=1000 \
    ROBOT_GID=1000 \
    ROBOT_THREADS=1 \
    PATH=/opt/robotframework/bin:$PATH

# Configurar timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependências do sistema em uma única camada (OTIMIZAÇÃO: consolidar apt-get)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Locales e timezone
    locales \
    locales-all \
    # Node.js e build tools
    curl \
    ca-certificates \
    gnupg \
    build-essential \
    # Python
    python3-pip \
    python3-venv \
    # Display e browsers
    xvfb \
    firefox \
    chromium-browser \
    libgtk-3-dev \
    libnss3 \
    libxss1 \
    fonts-noto-color-emoji \
    libxtst6 \
    # OCR e PDF
    tesseract-ocr \
    tesseract-ocr-eng \
    libtesseract-dev \
    poppler-utils \
    # VPN
    openvpn \
    # Utilitários
    apt-utils \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Instalar Node.js 20.x (LTS)
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -yq nodejs \
    && node -v \
    && npm -v \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# Stage 2: Python Dependencies - Instalar todas as dependências Python
# ============================================================================
FROM base AS python-deps

# Configurar npm com retries e timeouts para evitar problemas de rede
RUN npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retries 5 \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000

# Instalar dependências Python com cache mount (OTIMIZAÇÃO: BuildKit cache)
# OTIMIZAÇÃO: Adicionar --no-cache-dir para reduzir tamanho da imagem
# Nota: pytesseract precisa ser instalado primeiro pois robotframework-imagetotextlibrary
# tem um bug no setup.py que tenta importar pytesseract durante a instalação
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --upgrade --no-cache-dir --break-system-packages \
    pytesseract

RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --upgrade --no-cache-dir --break-system-packages \
    python-dotenv==1.1.0 \
    robotframework==7.2.2 \
    robotframework-browser==19.12.3 \
    robotframework-xvfb \
    robotframework-csvlib \
    requests==2.31.0 \
    robotframework-assertion-engine==3.0.3 \
    robotframework-databaselibrary==1.4.4 \
    robotframework-datadriver==1.11.1 \
    robotframework-datetime-tz==1.0.6 \
    robotframework-faker==5.0.0 \
    robotframework-imaplibrary2==0.4.1 \
    robotframework-pabot==2.18.0 \
    robotframework-requests==1.0a14 \
    robotframework-notifications \
    pg8000==1.31.1 \
    robotframework-jsonlibrary==0.5 \
    robotframework-autorecorder \
    robotframework-screencaplibrary==1.6.0 \
    robotframework-jsonschemalibrary \
    robotframework-retryfailed==0.2.0 \
    robotframework-excellib==2.0.1 \
    pdf2image==1.17.0 \
    robotframework-pdf2textlibrary==1.0.1 \
    robotframework-imagetotextlibrary==0.0.1 \
    pyotp \
    robotframework-otp==1.1.0 \
    chardet

# Instalar google-genai com versão mais recente que suporta protobuf 6.x
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --no-cache-dir --break-system-packages \
    google-genai==1.62.0 \
    "robotframework-gemini[browser]>=0.3.1"

# Instalar robotframework-heal separadamente para garantir compatibilidade
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --no-cache-dir --break-system-packages \
    "robotframework-heal==0.2.1"

# ============================================================================
# Stage 3: Playwright - Instalar browsers do Playwright
# ============================================================================
FROM python-deps AS playwright

# Instalar Playwright Chrome com retry e tratamento de erros HTTP/2
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0 \
    PLAYWRIGHT_DOWNLOAD_CONNECTION_TIMEOUT=300000

RUN npx playwright install chrome --with-deps || \
    (echo "⚠️ Tentativa 1 falhou, tentando novamente em 10s..." && \
     sleep 10 && \
     npx playwright install chrome --with-deps) || \
    (echo "⚠️ Tentativa 2 falhou, tentando última vez em 15s com HTTP/1.1..." && \
     sleep 15 && \
     PLAYWRIGHT_DOWNLOAD_CONNECTION_TIMEOUT=600000 \
     NODE_OPTIONS="--max-old-space-size=4096 --http-parser=legacy" \
     npx playwright install chrome --with-deps || \
     (echo "❌ Falha ao instalar Playwright Chrome após 3 tentativas" && exit 1))

# Inicializar rfbrowser
RUN rfbrowser init

# ============================================================================
# Stage 4: Final - Imagem final com customizações
# ============================================================================
FROM playwright AS final

# Copiar script de execução
COPY bin/run-tests.sh /opt/robotframework/bin/
RUN chmod 755 /opt/robotframework/bin/run-tests.sh

# Criar diretórios necessários e configurar permissões
RUN mkdir -p ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} \
    && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} \
    && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} \
    && chmod ugo+w /var/log \
    && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

VOLUME ${ROBOT_REPORTS_DIR}

USER ${ROBOT_UID}:${ROBOT_GID}

WORKDIR ${ROBOT_WORK_DIR}

CMD ["run-tests.sh"]
