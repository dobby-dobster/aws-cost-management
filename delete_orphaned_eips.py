'''
Delete orphaned eips
'''
import boto3

def main(event, context):

    client = boto3.client('ec2')
    addresses_dict = client.describe_addresses()

    for eip_dict in addresses_dict['Addresses']:
        if "InstanceId" not in eip_dict:
            print (eip_dict['PublicIp'] + " doesn't have any instances associated, releasing")
            try:
                client.release_address(AllocationId=eip_dict['AllocationId'])
            except Exception as ex:
                print (ex)