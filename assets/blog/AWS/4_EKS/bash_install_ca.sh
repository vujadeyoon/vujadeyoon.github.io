# Dveloper: vujadeyoon
# Email: vujadeyoon@gmail.com
# Github: https://github.com/vujadeyoon
# Personal website: https://vujadeyoon.github.io
#
# Title: bash_install_ca.sh
# Description: A bash script to install a cluster autoscaler (CA).
#
# Usage: bash ./bash_install_ca.sh NAME_CLUSTER ACCOUNT_ID
#
#
# Set variables.
NAME_CLUSTER=$1
ACCOUNT_ID=$2
#
#
# 1. Download required files.
mkdir -p ./perparations_ca
wget -O ./perparations_ca/k8s-asg-policy.json https://vujadeyoon.github.io/assets/blog/AWS/4_EKS/k8s-asg-policy.json
wget -O ./perparations_ca/cluster-autoscaler-autodiscover.yaml https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml
#
#
# 2. IAM roles for service accounts.
#     A. Enabling IAM roles for service accounts on your cluster (i.e. Creating IAM OIDC provider).
eksctl utils associate-iam-oidc-provider --cluster ${NAME_CLUSTER} --approve
#
#     B. Creating an IAM policy for your service account that will allow your CA pod to interact with the autoscaling groups.
aws iam create-policy --policy-name k8s-asg-policy --policy-document file://./perparations_ca/k8s-asg-policy.json
#
#     C. Finally, create an IAM role for the cluster-autoscaler Service Account in the kube-system namespace.
eksctl create iamserviceaccount \
--name cluster-autoscaler \
--namespace kube-system \
--cluster ${NAME_CLUSTER} \
--attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
--approve \
--override-existing-serviceaccounts
#
#     D. Make sure your service account with the ARN of the IAM role is annotated.
kubectl -n kube-system describe sa cluster-autoscaler
#
#
# 3. Deploy the Cluster Autoscaler (CA).
#     A. Deploy the Cluster Autoscaler to your cluster with the following command.
kubectl apply -f ./perparations_ca/cluster-autoscaler-autodiscover.yaml
sed -i "s/eksworkshop-eksctl/${NAME_CLUSTER}/g" ./perparations_ca/cluster-autoscaler-autodiscover.yaml
#
#     B. To prevent CA from removing nodes where its own pod is running, execute below command.
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
#
#     C. Finally let’s update the autoscaler image.
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}
#
#     D. You can watch logs
# kubectl -n kube-system logs -f deployment/cluster-autoscaler
#
#     E. Check the created cluster autoscaler.
kubectl get deploy -A
#
#
# 4. Remove the files
rm -rf ./perparations_ca
