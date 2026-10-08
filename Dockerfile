FROM cgr.dev/chainguard/python@sha256:894aed3297d91283e1fc4c542f5374a4b5f3726134fda7c94eaa539342be1e05 AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --no-compile --target /build/deps -r requirements.txt

FROM cgr.dev/chainguard/python@sha256:b6248c85ba9b97e1e61b30197f309cc4d21661f889fefa5268f0a7bc530dad46

ENV PYTHONPATH=/opt/deps

WORKDIR /app

COPY --from=builder /build/deps /opt/deps
COPY app.py .

USER nonroot:nonroot

EXPOSE 5000

ENTRYPOINT ["python", "app.py"]
