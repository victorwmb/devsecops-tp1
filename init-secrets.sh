#!/bin/sh
set -eu

cd "$(dirname "$0")"
mkdir -p secrets
umask 077

if [ ! -s secrets/db_password.txt ]; then
  rm -f secrets/db_password.txt
  openssl rand -hex 32 | tr -d '\r\n' > secrets/db_password.txt
fi

if ! grep -Eq '^tok_[0-9a-f]{64}$' secrets/pip_token.txt 2>/dev/null; then
  rm -f secrets/pip_token.txt
  printf 'tok_%s' "$(openssl rand -hex 32 | tr -d '\r\n')" > secrets/pip_token.txt
fi

chmod 0444 secrets/db_password.txt
chmod 0600 secrets/pip_token.txt
