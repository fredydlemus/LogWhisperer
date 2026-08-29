import boto3
import json

client_sme = boto3.client('bedrock-runtime')
 
 
def lambda_handler(event, context):
    user_input = event['prompt']
    print(event)
    print(user_input)
 
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from placeholder Lambda!",
        }),
    }