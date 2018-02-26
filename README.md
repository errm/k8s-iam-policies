# Kubernetes IAM Policies

This repository contains IAM policies useful for running Kubernetes on AWS.

The contents of this repository is subject to changes at any time based on the
current latest and greatest version of Kubernetes, and my thinking about how
IAM policies should be best implimented for AWS. Therefore please do not
rely on the contents of this repository for your own use, rather review them
and then pull a copy into your own infrastructure as code.

## [K8sMaster](K8sMaster.json)
The minimial required policy for a master node with the AWS cloud provider
enabled.

To limit the scope of the permissions `K8sMasterTaggedResourcesWritable`
can be restricted to nodes in your cluster by editing the tag Condition.

This depends on your EC2 nodes having the `KubernetesCluster` tag with
the cluster name as the value.


## [K8sNode](K8sNode.json)
The minimial required policy for a worker node with the AWS cloud provider
enabled.

## [K8sClusterAutoscaler](K8sClusterAutoscaler.json)

Based on [this documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#permissions)

## [K8sECR](K8sECR.json)
Allows an instance to authenticate with ECR and pull images.

## [K8sNodeAwsVpcCNI](K8sNodeAwsVpcCNI.json)

Policy for allowing the L-IPAM daemon in the amazon-vpc-cni-k8s CNI plugin
to attach ENIs and private IPs to instances. Based on the documentation
found [here](https://github.com/aws/amazon-vpc-cni-k8s#requirements).

## [setup.sh](setup.sh)

Yuck, a dirty shell script for setting this stuff up quickly.

Run `./setup.sh` to create all the Policies and add them to
Instance Profiles for `K8sMaster` and `K8sNode`.

Once the script is done, it spits out the InstanceProfile
ARNs ready to use in your cluster.

Depends on bash, the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [jq](https://stedolan.github.io/jq/download/)

** Warning **
No idempotency, so this will fail hard if you run it twice!

## License / Disclamer

[Apache License Version 2.0](LICENSE)

Use at your own risk!

Security and whatnot is way to important to entrust to me!
Please read and review these policies carefully before you
think about using them.

Oh and if I messed up please open a PR!
