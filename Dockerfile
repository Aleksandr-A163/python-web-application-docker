# Build: docker build -t python-web-application-docker .
# Run: docker run --rm -p 8000:8000 python-web-application-docker
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Cache dependency installation independently of application changes.
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt

# Includes all Python modules, templates, static assets and tests.
COPY . .

FROM base AS test
RUN python -m pip install --no-cache-dir -r requirements-dev.txt
RUN python -m pytest -W error --cov=phonebook --cov-report=term-missing --cov-fail-under=100 \
    && touch /tmp/tests-passed

FROM base AS runtime
# Require successful tests even when building the default runtime image.
COPY --from=test /tmp/tests-passed /usr/local/share/tests-passed

RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
