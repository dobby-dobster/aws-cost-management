'''
Delete old snapshots
'''
import boto3
import datetime
import sys

def main(event, context):

    ec2 = boto3.client('ec2')
    age = 30

    snapshots = ec2.describe_snapshots()

    for ami in snapshots['Snapshots']:
        created_date = ami['StartTime']
        snapshot_id = ami['SnapshotId']

        create_date = date.replace(tzinfo=None)
        diff = datetime.datetime.now() - create_date
        day_old = diff.days

        if day_old > age:
            try:
                print("Snapshot {0} is {1} days old (threshold {2}), deleting..").format(snapshot_id, str(day_old), age)
                ec2.delete_snapshot(SnapshotId=snapshot_id)
            except Exception as ex:
                print(ex)