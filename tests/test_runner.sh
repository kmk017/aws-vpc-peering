#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== AWS VPC Peering checks (run only after deployment) ==="
command -v aws >/dev/null || { echo "ERROR: AWS CLI is required"; exit 2; }
command -v ssh >/dev/null || { echo "ERROR: OpenSSH client is required"; exit 2; }

APP_A_PUB="$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=ewb-app-a" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].PublicIpAddress' --output text)"
APP_B_PUB="$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=ewb-app-b" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].PublicIpAddress' --output text)"

# AWS CLI may render an absent field as "None"; accept empty, None, or null only.
is_absent() { [[ -z "$1" || "$1" == "None" || "$1" == "null" ]]; }

echo "App-A public IP field: ${APP_A_PUB:-<empty>}"
echo "App-B public IP field: ${APP_B_PUB:-<empty>}"
if is_absent "$APP_A_PUB" && is_absent "$APP_B_PUB"; then
  echo "PASS: Neither private workload has a public IPv4 address."
else
  echo "FAIL: A public IPv4 address was found on a private workload."
  exit 1
fi

echo "Peering status:"
aws ec2 describe-vpc-peering-connections \
  --filters "Name=tag:Name,Values=ewb-a-b-peer" \
  --query 'VpcPeeringConnections[].{ID:VpcPeeringConnectionId,Status:Status.Code}' \
  --output table

echo "SSH / ping checks require a real deployment and configured ssh/config:"
ssh ewb-bastion 'hostname'
ssh ewb-app-a 'hostname && ping -c 4 -W 2 10.20.1.10'
ssh ewb-app-b 'hostname && ping -c 4 -W 2 10.10.2.10'
ssh ewb-app-b 'hostname && uptime'
echo "=== Checks completed; save actual output as evidence. ==="
