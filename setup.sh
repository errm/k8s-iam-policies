#!/bin/bash

set -euxo pipefail

function createPolicy {
  aws iam create-policy --policy-name $1 --policy-document file://$1.json | jq -r '.Policy.Arn'
}

function attachPolicy {
  aws iam attach-role-policy --role-name $1 --policy-arn $2
}

K8sNodeAwsVpcCNIArn=$(createPolicy K8sNodeAwsVpcCNI)
K8sClusterAutoscalerArn=$(createPolicy K8sClusterAutoscaler)
K8sECRArn=$(createPolicy K8sEcr)
K8sMasterArn=$(createPolicy K8sMaster)
K8sNodeArn=$(createPolicy K8sNode)

aws iam create-role --role-name K8sMaster --assume-role-policy-document file://ec2-role-trust-policy.json

attachPolicy K8sMaster $K8sMasterArn
attachPolicy K8sMaster $K8sECRArn
attachPolicy K8sMaster $K8sNodeAwsVpcCNIArn
attachPolicy K8sMaster $K8sClusterAutoscalerArn

aws iam create-instance-profile      --instance-profile-name K8sMaster
aws iam add-role-to-instance-profile --instance-profile-name K8sMaster --role-name K8sMaster

aws iam create-role --role-name K8sNode --assume-role-policy-document file://ec2-role-trust-policy.json
attachPolicy K8sNode $K8sNodeArn
attachPolicy K8sNode $K8sECRArn
attachPolicy K8sNode $K8sNodeAwsVpcCNIArn

aws iam create-instance-profile      --instance-profile-name K8sNode
aws iam add-role-to-instance-profile --instance-profile-name K8sNode --role-name K8sNode

