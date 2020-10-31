'''
Delete orphaned classic and application loadbalancers
'''
import boto3

def main(event, context):
    elb_client = boto3.client('elb')
    elbv2_client = boto3.client('elbv2')

    #classic load balancers
    victims = []
    bals = elb_client.describe_load_balancers()
    for elb in bals['LoadBalancerDescriptions']:
        if len(elb['Instances']) < 1:
            try:
                elb_client.delete_load_balancer(LoadBalancerName=elb)
            except Exception as ex:
                print(ex)

    # application load balancers
    victims = []
    bals = elbv2_client.describe_load_balancers()
    for elb in bals['LoadBalancers']:
        listeners = elbv2_client.describe_listeners(LoadBalancerArn=elb['LoadBalancerArn'])
        for key, value in listeners.items():
            if key == "Listeners":
                if len(value) < 1:
                    try:
                        elbv2_client.delete_load_balancer(LoadBalancerArn=elb)
                    except Exception as ex:
                        print(ex)
    
    # application load balancers target groups
    victims = []
    bals = elbv2_client.describe_target_groups()
    for tg in bals['TargetGroups']:
        for key, value in tg.items():
            if key == "LoadBalancerArns":
                if len(value) < 1:
                    try:
                        elbv2_client.delete_target_group(TargetGroupArn=tg)
                    except Exception as ex:
                        print(ex)        
                    
    