# syntax=docker/dockerfile:1.28.0@sha256:bb22d9815c728170f72750f4e5b0d672e06176142e1d602c7e66c050100b7e5b
FROM cgr.dev/chainguard/python@sha256:dde1a2549dd62864f0263dae8e877680837b4e738a7ecc85c671c55c069848ac AS builder

WORKDIR /build

COPY requirements.txt .

RUN --mount=type=cache,id=pip,target=/home/nonroot/.cache/pip,uid=65532,gid=65532 \
    --mount=type=secret,id=pip_token,required=true,uid=65532,mode=0400 \
    if ! grep -Eq '^tok_[0-9a-f]{64}$' /run/secrets/pip_token; then \
        echo "Jeton du dépôt de paquets interne absent ou invalide" >&2; exit 1; \
    fi \
    && pip install --no-compile --target /build/deps -r requirements.txt

FROM cgr.dev/chainguard/python@sha256:49fd266eb8a1331194c318b742087c7a2939cc5794fa64f17feb9e17e12703e2

ENV PYTHONPATH=/opt/deps

WORKDIR /app

COPY --from=builder /build/deps /opt/deps
COPY app.py .

USER 65532:65532

EXPOSE 5000

ENTRYPOINT ["python", "app.py"]
