import boto3
import json
import os

MODEL_ID = os.getenv("MODEL_ID")

bedrock_client = boto3.client('bedrock-runtime')
 
 
def lambda_handler(event, context):
    user_input = event['prompt']

    message_prompt = [{"role": "user", "content": [{"text": user_input}]}]

    system_prompt = [{
        "text": """Act as an intelligent log analysis assistant. Your task is to analyze application logs and provide a structured 5-line summary that includes:
        1. Critical errors or failures (if any)
2. Key events or state changes
3. Performance metrics or anomalies
4. User/system actions of importance
5. Overall system status and recommendations
        """
    }]

    inference_params = {"maxTokens": 2500, "topP": 0.9, "topK": 20, "temperature": 0.7}

    request_body={
        "schemaVersion": "messages-v1",
        "messages": message_prompt,
        "system": system_prompt,
        "inferenceConfig": inference_params
    }

    response = bedrock_client.invoke_model(
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