'''
Delete orphaned volumes'
'''
import boto3

def main(event, context):
    ''' get and delete orphaned volumes '''
    ec2_client = boto3.resource('ec2')
    volume = ec2_client.Volume('id')

    available_volumes = ec2_client.volumes.filter \
        (Filters=[{'Name': 'status', 'Values': ['available']}])

    for vol in available_volumes:
        print("Vol: Volumes to action {0}").format(vol.id)
        try:
            vol.delete()
        except Exception as ex:
             print("Problem deleting volume {0}").format(ex)