# Docker — Robot Framework (Ubuntu)

Imagem multi-stage baseada em **Ubuntu 24.04** para testes Web/E2E com **Robot Framework 7.2.2**, **Browser Library** (Playwright), Firefox/Chromium, OCR (Tesseract), PDF e utilitários de QA.

## O que a imagem inclui

- **SO e runtime:** Python 3 (pip/venv no sistema), Node.js 20.x, Xvfb, locale `pt_BR.UTF-8`, fuso **America/Sao_Paulo**
- **Navegadores:** Firefox, pacote `chromium-browser` (Ubuntu); **Playwright Chrome** instalado via `npx playwright` para a Browser Library
- **Ferramentas:** Tesseract OCR, Poppler (`pdftotext` etc.), OpenVPN (cliente)

### Bibliotecas Python principais (pip)

| Pacote | Versão (fixa quando indicada) |
|--------|-------------------------------|
| robotframework | 7.2.2 |
| robotframework-browser | 19.12.3 |
| python-dotenv | 1.1.0 |
| requests | 2.31.0 |
| pg8000 | 1.31.1 |
| google-genai | 1.62.0 |
| robotframework-heal | 0.2.1 |
| pdf2image | 1.17.0 |
| pytesseract | (última compatível) |

Outras bibliotecas Robot instaladas: `robotframework-xvfb`, `robotframework-csvlib`, `robotframework-assertion-engine`, `robotframework-databaselibrary`, `robotframework-datadriver`, `robotframework-datetime-tz`, `robotframework-faker`, `robotframework-imaplibrary2`, `robotframework-pabot`, `robotframework-requests`, `robotframework-notifications`, `robotframework-jsonlibrary`, `robotframework-autorecorder`, `robotframework-screencaplibrary`, `robotframework-jsonschemalibrary`, `robotframework-retryfailed`, `robotframework-excellib`, `robotframework-pdf2textlibrary`, `robotframework-imagetotextlibrary`, `robotframework-otp`, `pyotp`, `chardet`.

> O build usa **BuildKit** (`RUN --mount=type=cache` para pip). Construa com: `DOCKER_BUILDKIT=1 docker build -t sua-imagem .`

## Variáveis de ambiente

| Variável | Padrão | Uso |
|----------|--------|-----|
| `ROBOT_TESTS_DIR` | *(obrigatório na prática)* | Caminho dos testes (`.robot` ou pasta) passado ao `robot` / `pabot` |
| `ROBOT_REPORTS_DIR` | `/opt/robotframework/reports` | Saída de log, relatório e output XML |
| `ROBOT_WORK_DIR` | `/opt/robotframework/temp` | `WORKDIR` e `HOME` durante a execução |
| `ROBOT_THREADS` | `1` | Se `1`, roda `robot`; se maior, roda `pabot` com `--processes` |
| `ROBOT_OPTIONS` | *(vazio)* | Opções extras do Robot (ex.: `--exitonfailure`, `--name`) |
| `ROBOT_LISTENER` | *(vazio)* | Listeners (ex.: Tesults), repassados ao comando |
| `PABOT_OPTIONS` | *(vazio)* | Opções extras do Pabot quando `ROBOT_THREADS` > 1 |
| `SCREEN_WIDTH` / `SCREEN_HEIGHT` / `SCREEN_COLOUR_DEPTH` | `1920` / `1080` / `24` | Display virtual Xvfb |

O script de entrada é `run-tests.sh` (em `/opt/robotframework/bin`, no `PATH`), que executa tudo dentro de `xvfb-run`.

## Uso com Docker

Monte os testes e um diretório para relatórios (o usuário no container é UID/GID **1000**):

```bash
docker build -t robot-local .

docker run --rm \
  -e ROBOT_TESTS_DIR=/tests/suite.robot \
  -e ROBOT_OPTIONS="--exitonfailure" \
  -v "$(pwd)/tests:/tests:ro" \
  -v "$(pwd)/reports:/opt/robotframework/reports" \
  robot-local
```

Ajuste caminhos e variáveis conforme seu projeto. Para Pabot:

```bash
docker run --rm \
  -e ROBOT_THREADS=4 \
  -e ROBOT_TESTS_DIR=/tests \
  -v "$(pwd)/tests:/tests:ro" \
  -v "$(pwd)/reports:/opt/robotframework/reports" \
  robot-local
```

## GitHub Actions

Use `docker run` (ou uma action genérica de “run container”) com os mesmos `-e` e `-v` do exemplo acima, apontando `ROBOT_TESTS_DIR` e `ROBOT_REPORTS_DIR` para diretórios dentro de `${{ github.workspace }}`. Runners atuais costumam ser `ubuntu-latest`; não é necessário fixar `ubuntu-18.04`.

## Related projects / Projetos relacionados

| Project | Description |
|---------|-------------|
| [robotframework-gemini](https://github.com/carlosnizolli/robotframework-gemini) | Gemini oracles for RF — install with `pip install robotframework-gemini` |
| [robotframework-gemini_exemplos](https://github.com/carlosnizolli/robotframework-gemini_exemplos) | Example suites to run in this image |
| [RobotToPGListener](https://github.com/carlosnizolli/RobotToPGListener) | Persist results: `robot --listener robot_to_pg_listener.Listener` |
| [RoboCop](https://github.com/carlosnizolli/RoboCop) | Lint RF code in CI before image runs |

---

**Repositório:** [github.com/carlosnizolli/docker-robotframework](https://github.com/carlosnizolli/docker-robotframework)
