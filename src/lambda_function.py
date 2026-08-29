import boto3
import json
import os

MODEL_ID = os.getenv("MODEL_ID")

client_sme = boto3.client('bedrock-runtime')
 
 
def lambda_handler(event, context):
    user_input = event['prompt']

    message_prompt = [{"role": "user", "content": [{"text": user_input}]}]

    system_prompt = [{
        "text": "Act as wind turbine manufactoring assistant. Summarize the logs in 5 lines."
    }]

    inference_params = {"maxTokens": 2500, "topP": 0.9, "topK": 20, "temperature": 0.7}

    request_body={
        "schemaVersion": "messages-v1",
        "messages": message_prompt,
        "system": system_prompt,
        "inferenceConfig": inference_params
    }

    response = client_sme.invoke_model(
        body=json.dumps(request_body),
        contentType='application/json',
        accept='application/json',
        modelId=MODEL_ID,
        trace='ENABLED',
        performanceConfigLatency='standard'
    )

    response_dict = json.loads(response['body'].read())
    
    final_response = response_dict['output']['message']['content'][0]['text']
 
    return {
        "statusCode": 200,
        "body": json.dumps(final_response),
    }