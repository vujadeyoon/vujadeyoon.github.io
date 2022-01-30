# Dveloper: vujadeyoon
# Email: vujadeyoon@gmail.com
# Github: https://github.com/vujadeyoon
# Personal website: https://vujadeyoon.github.io
#
# Title: bash_install_lbc.sh
# Description: A bash script to install the AWS load balancer controller.
#
# Usage: bash ./bash_install_lbc.sh NAME_CLUSTER ACCOUNT_ID NAME_ROLE_AWS_LBC
#
#
# Set variables.
NAME_CLUSTER=$1
ACCOUNT_ID=$2
NAME_ROLE_AWS_LBC=$3
#
#
# 1. Download required files.@TODO
mkdir -p ./preparations_lbc
curl -o ./preparations_lbc/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
curl -o ./preparations_lbc/iam_policy_v1_to_v2_additional.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy_v1_to_v2_additional.json
#
#
# 2. Deploy the AWS Load Balancer Controller.
#     A. We will verify if the AWS Load Balancer Controller version has been set.
echo 'export LBC_VERSION="v2.3.1"' >>  ~/.bash_profile
. ~/.bash_profile
if [ ! -x ${LBC_VERSION} ]
  then
    tput setaf 2; echo '${LBC_VERSION} has been set.'
  else
    tput setaf 1; echo '${LBC_VERSION} has NOT been set.'
fi
#
#     B. Create IAM OIDC provider.
#        You can skip this step if you already execute the command in Setction. CA.
# eksctl utils associate-iam-oidc-provider --cluster ${NAME_CLUSTER} --approve
#
#     C. Create an IAM policy, AWSLoadBalancerControllerIAMPolicy.
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://./preparations_lbc/iam_policy.json
#
#     D. Create a IAM role and ServiceAccount.
eksctl create iamserviceaccount \
--cluster ${NAME_CLUSTER} \
--namespace kube-system \
--name aws-load-balancer-controller \
--attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve
#
#     E. Download the IAM policy.
#
#
#     F. Create the IAM policy and note the ARN that is returned.
1 $ aws iam create-policy \
2   --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy \
3   --policy-document file://./preparations_lbc/iam_policy_v1_to_v2_additional.json
#
#     G. Attach the IAM policy to the IAM role.
aws iam attach-role-policy \
2   --role-name ${NAME_ROLE_AWS_LBC} \
3   --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerAdditionalIAMPolicy
#
#     H. Add the eks-charts repository.
helm repo add eks https://aws.github.io/eks-charts
#
#     I. Update your local repo to make sure that you have the most recent charts.
helm repo update
#
#     J. Install the TargetGroupBinding CRDs.
1 $ kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
2 $ kubectl get crd
#
#     K. Install the AWS Load Balancer Controller.
1 $ helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
2   -n kube-system \
3   --set clusterName=${NAME_CLUSTER} \
4   --set serviceAccount.create=false \
5   --set serviceAccount.name=aws-load-balancer-controller
#
#     L. Verify that the controller is installed.
kubectl get deployment -n kube-system aws-load-balancer-controller
#
#
# 3. Remove the files
rm -rf ./preparations_lbc
