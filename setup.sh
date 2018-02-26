#!/bin/bash

set -euo pipefail

function createPolicy {
  aws iam create-policy --policy-name $1 --policy-document file://$1.json | jq -r '.Policy.Arn'
}

function attachPolicy {
  aws iam attach-role-policy --role-name $1 --policy-arn $2
}

function attachPolices {
  for i in "${@:2}"
  do
    attachPolicy $1 $i
  done
}

function createInstanceProfile {
  aws iam create-role --role-name $1 --assume-role-policy-document file://ec2-role-trust-policy.json > /dev/null
  for i in "${@:2}"
  do
    attachPolicy $1 $i
  done
  echo $(aws iam create-instance-profile      --instance-profile-name $1 | jq -r ".InstanceProfile.Arn")
  aws iam add-role-to-instance-profile --instance-profile-name $1 --role-name $1
}

K8sNodeAwsVpcCNIArn=$(createPolicy K8sNodeAwsVpcCNI)
K8sClusterAutoscalerArn=$(createPolicy K8sClusterAutoscaler)
K8sECRArn=$(createPolicy K8sEcr)
K8sMasterArn=$(createPolicy K8sMaster)
K8sNodeArn=$(createPolicy K8sNode)

createInstanceProfile K8sMaster $K8sMasterArn $K8sECRArn $K8sNodeAwsVpcCNIArn $K8sClusterAutoscalerArn
createInstanceProfile K8sNode $K8sNodeArn $K8sECRArn $K8sNodeAwsVpcCNIArn
