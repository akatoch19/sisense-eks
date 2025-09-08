#!/bin/bash
set -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

ROLE="${ROLE:-Application}"
NAMESPACE="${NAMESPACE:-sisense}"

yum update -y
yum install -y gawk python3 python3-pip nc jq git libselinux-python3 amazon-ssm-agent
if ! command -v sshpass &>/dev/null; then
  yum install -y https://rpmfind.net/linux/fedora/linux/releases/38/Everything/x86_64/os/Packages/s/sshpass-1.09-5.fc38.x86_64.rpm || true
fi

python3 -m pip install --upgrade pip==21.1.3
python3 -m pip install selinux configparser zipp
pip3 install git+https://github.com/lilydjwg/pssh || true
ln -sf /usr/bin/pip3 /usr/local/bin/pip || true

# AWS CLI
if ! command -v aws &>/dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
fi

# kubectl
if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# eksctl
if ! command -v eksctl &>/dev/null; then
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin
fi

# Docker ulimits
if grep -q "nofile=1024:4096" /etc/sysconfig/docker 2>/dev/null; then
  sed -i 's/--default-ulimit nofile=1024:4096/--default-ulimit nofile=1024000:1024000/' /etc/sysconfig/docker
  systemctl daemon-reexec
  systemctl restart docker || true
fi

ulimit -n || true

# Node labeling
NODE_NAME=$(hostname)
kubectl label node "${NODE_NAME}" node-${NAMESPACE}-Application=true --overwrite || true
kubectl label node "${NODE_NAME}" node-${NAMESPACE}-Query=true --overwrite || true
if [[ "$ROLE" == "Build" ]]; then
  kubectl label node "${NODE_NAME}" node-${NAMESPACE}-Build=true --overwrite || true
fi

echo "Bootstrap completed successfully"
