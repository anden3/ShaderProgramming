#!/bin/bash
DIR=$(dirname "$1")
FILE=$(basename "$1" .sl)

aqsl -o build/$FILE.slx $1