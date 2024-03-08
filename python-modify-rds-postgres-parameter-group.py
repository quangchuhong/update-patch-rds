import os
import sys
import boto3
import botocore.config
import json

client = boto3.client('rds')
response = client.modify_db_parameter_group(
    DBParameterGroupName='test-create-dbparametergroup16',
    Parameters=[
        {
            'ParameterName': 'track_activity_query_size',
            'ParameterValue': '102400',
            'ApplyMethod': 'pending-reboot',
        }

    ],
)

# Program to read the entire file using read() function
file = open("parameter-value-postgres16.txt", "r")
content = file.readlines()
file.close()
#print(content);
json_string = {
        'ApplyMethod': 'pending-reboot',
        'ParameterName': 'track_activity_query_size',
        'ParameterValue': '102400',
}

Parameters=[]
json_string = {}

content2 = ["'ParameterName': 'track_activity_query_size','ParameterValue': '102400','ApplyMethod': 'pending-reboot'", 
            "'ParameterName': 'log_checkpoints','ParameterValue': 'true','ApplyMethod': 'immediate'",
        ]
for i in content:
    x = i.split(',')
    parameter_name = x[0]
    parameter_value = x[1]
    parameter_method = x[2].strip() # newline character from string'\n'
    response = client.modify_db_parameter_group(
        DBParameterGroupName='test-create-dbparametergroup16',
        Parameters=[
            {
                'ParameterName': parameter_name,
                'ParameterValue': parameter_value,
                'ApplyMethod': parameter_method,
            }
        ],
    )
    print(Parameters)
    print(response)


