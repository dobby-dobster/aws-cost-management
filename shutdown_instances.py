'''
Shutdown EC2 instances where tag 'Shutdown:True'
'''
import boto3

def main(event, context):
    ec2_client = boto3.resource('ec2')
    victims = []
    running_instances = ec2_client.instances.filter(Filters=[{
        'Name': 'instance-state-name',
        'Values': ['running']}])

    for instance in running_instances:
        for tag in instance.tags:
                if 'Shutdown' in tag['Key']:
                    if tag['Value'] == "True":
                        victims.append(instance.id)

    if len(victims) > 0:
        print("Shutting down {0} instances ({1}).").format(len(victims), victims)
        ec2_client.instances.filter(InstanceIds=victims).stop()
    else:
        print("No instances found to shutdown.")
