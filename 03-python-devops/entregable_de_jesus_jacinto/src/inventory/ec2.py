import boto3

def get_ec2_instances(region="us-east-1"):
    ec2 = boto3.client("ec2", region_name=region)

    instances = []

    response = ec2.describe_instances()

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:

            instances.append({
                "id": instance["InstanceId"],
                "type": instance["InstanceType"],
                "state": instance["State"]["Name"],
                "ip": instance.get("PublicIpAddress", "N/A")
            })

    return instances
