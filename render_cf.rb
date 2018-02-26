#!/usr/bin/env ruby

require "json"
require "yaml"

def policy(name)
  {
    "PolicyName": name,
    "PolicyDocument": JSON.parse(File.read("#{name}.json")),
  }
end

def profile(name, *policies)
  {
    "#{name}InstanceProfile": {
      "Type": "AWS::IAM::InstanceProfile",
      "Properties": {
        "Path": "/",
        "Roles": [{ "Ref": "#{name}InstanceRole" }],
      },
    },
    "#{name}InstanceRole": {
      "Type": "AWS::IAM::Role",
      "Properties": {
        "AssumeRolePolicyDocument": JSON.parse(File.read("ec2-role-trust-policy.json")),
        "Path": "/",
        "Policies": policies.map { |p| policy(p) },
      },
    }
  }
end

def resources(*profiles)
  profiles.each_with_object({}) { |profile, hash| hash.merge!(profile) }
end

def outputs(*names)
  names.each_with_object({}) do |name, hash|
    hash.merge!(
      "#{name}InstanceProfileArn": {
        "Description": "Kubernetes #{name} instance profile",
        "Value": { "Fn::GetAtt": ["#{name}InstanceProfile", "Arn"] },
        "Export": {
          "Name": {
            "Fn::Sub": "${AWS::StackName}-#{name}InstanceProfileArn",
          }
        },
      }
    )
  end
end


def stack
  {
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "Kubernetes IAM Instance Profiles",
    "Resources": resources(
      profile("Master", "master", "ecr", "cni", "autoscaler", "loadbalancing"),
      profile("Node", "node", "ecr", "cni"),
    ),
    "Outputs": outputs("Master", "Node"),
  }
end

def clean_yaml(data)
  YAML.dump(JSON.parse(JSON.dump(data)))
end

File.write("cf.yaml", clean_yaml(stack))
