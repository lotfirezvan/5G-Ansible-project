#!/bin/bash

PLAYBOOK="DeployOAI.yaml"

START=$(date +%s%3N)

ansible-playbook -i "localhost," -c local "$PLAYBOOK"

END=$(date +%s%3N)

ELAPSED_MS=$((END - START))

echo "Ansible deployment time: ${ELAPSED_MS} ms"