#!/bin/sh

./bin/zold node --no-colors --trace \
    --bind-port=$PORT --port=80 --host=b1.zold.io --threads=0 \
    --invoice=ML5Ern7m@912ecc24b32dbe74 --never-reboot \
    --bonus-wallet=81c9c25789b03876 --private-key=bonus.key --bonus-amount=1 --bonus-time=60
