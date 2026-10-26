FROM cgr.dev/chainguard/python@sha256:dde1a2549dd62864f0263dae8e877680837b4e738a7ecc85c671c55c069848ac AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --no-compile --target /build/deps -r requirements.txt

FROM cgr.dev/chainguard/python@sha256:49fd266eb8a1331194c318b742087c7a2939cc5794fa64f17feb9e17e12703e2

ENV PYTHONPATH=/opt/deps

WORKDIR /app

COPY --from=builder /build/deps /opt/deps
COPY app.py .

USER nonroot:nonroot

EXPOSE 5000

ENTRYPOINT ["python", "app.py"]
