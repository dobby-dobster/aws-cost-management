# aws-cost-management
 
## shutdown_instances
Scheduled CloudWatch rule which triggers a Lambda to power off instances where tags match critera

## delete orphaned volumes
Scheduled CloudWatch rule which triggers a Lambda to delete orphaned volumes

## delete orphaned loadbalancers
Scheduled CloudWatch rule which triggers a Lambda to delete orphaned loadbalancers

![logo](media/functions.png)

![logo](media/cw_event_rules.png)

### TODO
* Restrict IAM polices further