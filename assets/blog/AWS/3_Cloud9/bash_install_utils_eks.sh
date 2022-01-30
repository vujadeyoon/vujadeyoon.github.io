# Dveloper: vujadeyoon
# Email: vujadeyoon@gmail.com
# Github: https://github.com/vujadeyoon
# Personal website: https://vujadeyoon.github.io
#
# Title: bash_install_utils_eks.sh
# Description: A bash script to install utilities for EKS.
#
#
# Set name of the created IAM role for the AWS cloud9.
NAME_IAM_ROLE=$1
#
#
# Installing utilities
echo '============================================'
echo 'Utilities'
echo '============================================'
sudo apt-get install -y yum
sudo snap install yq
sudo apt-get install -y gettext bash-completion moreutils jq
sudo pip install --upgrade awscli && hash -r
#
#
# Environmnet configuration
echo '============================================'
echo 'Environment configuration'
echo '============================================'
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
aws sts get-caller-identity --query Arn | grep ${NAME_IAM_ROLE} -q && echo "IAM role valid" || echo "IAM role NOT valid"
#
#
# Installing Elastic Load Balancing (ELB)
echo '============================================'
echo 'Elastic Load Balancing (ELB)'
echo '============================================'
aws iam get-role --role-name "AWSServiceRoleForElasticLoadBalancing" || aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"
#
#
# Installing eksctl
echo '============================================'
echo 'EKSCTL'
echo '============================================'
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
#
#
# Installing kubectl
echo '============================================'
echo 'KUBECTL'
echo '============================================'
sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl
#
sudo chmod +x /usr/local/bin/kubectl
#
#
# Installing yq for yaml processing
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc
#
#
# Verifying the binaries are in the path and executable
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
#
#
# Enable kubectl bash_completion
kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
#
#
# Set the AWS Load Balancer Controller version
echo 'export LBC_VERSION="v2.0.0"' >>  ~/.bash_profile
.  ~/.bash_profile
#
echo '============================================'
echo 'Helem'
echo '============================================'
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short
helm repo add stable https://charts.helm.sh/stable
helm search repo stable
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
#
echo 'eksctl version is' $(eksctl version)
echo 'kubectl version is' $(kubectl version --client --short)
