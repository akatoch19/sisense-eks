#!/bin/bash
set -e

NAMESPACE="${namespace}"
KUBECONFIG=${KUBECONFIG:-~/.kube/config}

echo "Labeling Sisense nodes for namespace: $NAMESPACE"

# Get all nodes
NODES=$(kubectl get nodes -o name | sed 's/node\///')

# Label first two nodes as Application/Query
echo "Labeling application/query nodes..."
for node in $(echo "$NODES" | head -2); do
  kubectl label node $node node-$NAMESPACE-Application=true --overwrite
  kubectl label node $node node-$NAMESPACE-Query=true --overwrite
  echo "Node $node labeled as Application and Query"
done

# Label third node as Build
echo "Labeling build node..."
for node in $(echo "$NODES" | sed -n '3p'); do
  kubectl label node $node node-$NAMESPACE-Build=true --overwrite
  echo "Node $node labeled as Build"
done

echo "Node labeling completed successfully!"
