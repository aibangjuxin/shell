#!/bin/bash
set -euo pipefail
# Define variables
namespace="kube-system"
configmap="ip-masq-agent"
configfile="ip-masq-agent.txt"

# Define ip-masq-agent.txt for configmap
cat <<EOF >$configfile
nonMasqueradeCIDRs:
  - 10.0.0.0/8
  - 128.0.0.0/2
  - 192.168.64.0/19
  - 100.64.0.0/14
masqLinkLocal: false
resyncInterval: 60s
EOF

# Check if ip-masq-agent DaemonSet exists in $namespace namespace
if ! kubectl get daemonsets/ip-masq-agent -n $namespace >/dev/null 2>&1; then
	echo "ip-masq-agent DaemonSet not found in $namespace namespace"
	exit 1
fi

# Check if configmap exists in $namespace namespace
if ! kubectl get configmaps/$configmap -n $namespace >/dev/null 2>&1; then
	echo "$configmap configmap not found in $namespace namespace"
	echo "Creating $configmap configmap"
	kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $configmap
  namespace: $namespace
data:
  config: $(cat $configfile)
EOF
	echo "Describing $configmap configmap"
	kubectl describe configmaps/$configmap -n $namespace
else
	echo "$configmap configmap already exists in $namespace namespace"
fi

kubectl describe configmaps/$configmap -n $namespace

set -euo pipefail
# Define ip-masq-agent.txt for configmap
cat <<EOF >ip-masq-agent.txt
nonMasqueradeCIDRs:
  - 10.0.0.0/8
  - 128.0.0.0/2
  - 192.168.64.0/19
  - 100.64.0.0/14
masqLinkLocal: false
resyncInterval: 60s
EOF

# Check if ip-masq-agent DaemonSet exists in kube-system namespace
if ! kubectl get daemonsets/ip-masq-agent -n kube-system >/dev/null 2>&1; then
	echo "ip-masq-agent DaemonSet not found in kube-system namespace"
	exit 1
fi

# Check if configmaps exists in kube-system namespace
if ! kubectl get configmaps/ip-masq-agent -n kube-system >/dev/null 2>&1; then
	echo "ip-masq-agent configmap not found in kube-system namespace"
	echo "The next will create configmap"
	kubectl create configmap ip-masq-agent -n kube-system --from-file=config=ip-masq-agent.txt
	echo "describe configmaps"
	kubectl describe configmaps/ip-masq-agent -n kube-system
else
	exit 1
fi

kubectl describe configmaps/ip-masq-agent -n kube-system
