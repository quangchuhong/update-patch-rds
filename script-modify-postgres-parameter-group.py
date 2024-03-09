import os
import sys
import boto3
import json

client = boto3.client('rds',region_name='ap-southeast-1')
parameter_group_name='rds-upgrade-test-postgres16-v3'
file_parameter="parameter-value-postgres16.txt"

file = open(file_parameter, "r")
content = file.readlines()
file.close()

parameters=[]
for i in content:
    line = i.strip()
    parameters.append(line)


for i in parameters:
    if i !='':
        x = i.split('=')
        parameter_name = x[0]
        parameter_value = x[1].strip()
        parameter_method = 'pending-reboot' # newline character from string'\n'
        response = client.modify_db_parameter_group(
            DBParameterGroupName=parameter_group_name,
            Parameters=[
                {
                    'ParameterName': parameter_name,
                    'ParameterValue': parameter_value,
                    'ApplyMethod': parameter_method,
                }
            ],
        )
    print(response)



