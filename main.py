#!/usr/bin/env python3
"""
Shutdowns/starts up ec2 instances based on tag.
For example if instance has tag of 'Shutdown' with value of 'True'
  then script will either start or stop based on 'action'.
"""

from collections import defaultdict
import boto3

# Connect to EC2
ec2 = boto3.resource('ec2')

# define these
action = "start" 
tagKey = "Shutdown"
tagValue = "True"

candidates = []

def main():
    if action == "start":
        state = "stopped"
    else:
        state = "running"
    get_instances(state, tagKey, tagValue)

def get_instances(state, tagKey, tagValue):
    ''' get ec2 instance based on tags '''
    # Get information for all running instances
    running_instances = ec2.instances.filter(Filters=[{
        'Name': 'instance-state-name',
        'Values': [state]}])

    ec2info = defaultdict()
    for instance in running_instances:
        for tag in instance.tags:
                if tagKey in tag['Key']:
                    if tag['Value'] == tagValue:
                        candidates.append(instance.id)
                        ec2info[instance] = {
                            'Name': instance,
                            'Type': instance.instance_type,
                            'State': instance.state['Name'],
                            'Private IP': instance.private_ip_address,
                            'Public IP': instance.public_ip_address,
                            'Launch Time': instance.launch_time
                            }

    attributes = ['Name', 'Type', 'State', 'Private IP', 'Public IP', 'Launch Time']

    for instance_id, instance in ec2info.items():
        for key in attributes:
            print("{0}: {1}".format(key, instance[key]))

    if len(candidates) > 0:
        execute(action, candidates)
    else:
        print("There are no instances to action.")

def execute(action, candidates):
    ''' either start or stop instances '''
    print("")
    print("Instances to execute upon ({0}) {1}").format(action, candidates)
    try:
        if action == "stop":
            ec2.instances.filter(InstanceIds=candidates).stop()
        else:
            ec2.instances.filter(InstanceIds=candidates).start()
    except Exception as ex:
        print("Problem with actioning request {0}, error {1}").format(action, ex)

if __name__ == "__main__":
    main()
