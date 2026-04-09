#!/bin/bash
# Measure execution time of manual OAI deployment

SCRIPT="./DeployOAI.sh"

START=$(date +%s%3N)

bash "$SCRIPT"

END=$(date +%s%3N)

ELAPSED_MS=$((END - START))

echo "Execution time: ${ELAPSED_MS} ms"
