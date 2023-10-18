import boto3
import json
scaling = boto3.client('autoscaling')
ec2 = boto3.resource('ec2')

def lambda_handler(event, context):
    print(event)

    eventDetail = event['detail']
    eip_address = eventDetail['NotificationMetadata']['allocation_id']
    vpc_address = ec2.VpcAddress(eip_address)

    response = vpc_address.associate(
        InstanceId=event['detail']['EC2InstanceId'],
        AllowReassociation=True
    )

    scaling.complete_lifecycle_action(
        LifecycleHookName=eventDetail['LifecycleHookName'],
        LifecycleActionToken=eventDetail['LifecycleActionToken'],
        AutoScalingGroupName=eventDetail['AutoScalingGroupName'],
        LifecycleActionResult='CONTINUE',
        InstanceId=eventDetail['EC2InstanceId']
    )
