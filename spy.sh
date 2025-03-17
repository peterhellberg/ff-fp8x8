#!/usr/bin/env bash

killall -q firefly-emulator

firefly_cli build && \
firefly-emulator --id peter.fp8x8
