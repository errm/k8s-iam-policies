#!/usr/bin/env ruby

require "json"

def compact_json(path)
  "'#{JSON.dump(JSON.parse(File.read(path)))}'"
end

SCRIPT  = <<-HEREDOC
#!/bin/sh -e

HEREDOC

{
  "K8sMaster" => %w[master ecr cni autoscaler loadbalancing],
  "K8sNode"   => %w[node ecr cni],
}.each do |role, policies|
  SCRIPT << "aws iam create-role --role-name #{role} --assume-role-policy-document #{compact_json("ec2-role-trust-policy.json")} > /dev/null\n"
  policies.each do |policy|
    SCRIPT << "aws iam put-role-policy --role-name #{role} --policy-name #{policy} --policy-document #{compact_json("#{policy}.json")}\n"
  end
  SCRIPT << "aws iam create-instance-profile --instance-profile-name #{role}\n"
  SCRIPT << "aws iam add-role-to-instance-profile --instance-profile-name #{role} --role-name #{role}\n"
end

File.write("setup.sh", SCRIPT)
