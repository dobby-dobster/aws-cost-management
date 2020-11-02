'''
Delete orphaned security groups
'''
import boto3

def main(event, context):
    ec2 = boto3.resource('ec2')
    security_group = ec2.SecurityGroup('id')

    # get all sgs and instances
    sgs = list(ec2.security_groups.all())
    instances = list(ec2.instances.all())
    
    all_sgs = set([sg.group_name for sg in sgs ])
    all_inst_sgs = set([sg['GroupName'] for inst in instances for sg in inst.security_groups])
    
    #find unused sgs
    unused_sgs = all_sgs - all_inst_sgs
    
    # remove the aws default sg - we dont want to remove this
    unused_sgs.remove("default")

    try:
        for sg in unused_sgs:
            print("Deleting sg {0}".format(sg))
            security_group.delete(GroupName=sg)
    except Exception as ex:
        print(ex)
