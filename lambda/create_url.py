import json, boto3, string, random, os

TABLE_NAME = os.environ["TABLE_NAME"]
API_BASE   = os.environ["API_BASE"]

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def generate_short_code(length=6):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))
    long_url = body.get("url")
    if not long_url:
        return {"statusCode": 400, "body": json.dumps({"error":"URL required"})}

    short_code = generate_short_code()
    table.put_item(Item={"short_code": short_code, "long_url": long_url, "clicks":0})

    return {"statusCode":200, "body": json.dumps({"short_url": f"{API_BASE}/{short_code}"})}