import boto3, os

TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    short_code = event["pathParameters"]["code"]
    resp = table.get_item(Key={"short_code": short_code})
    item = resp.get("Item")
    if not item:
        return {"statusCode":404, "body":"Not found"}

    table.update_item(Key={"short_code": short_code},
                      UpdateExpression="SET clicks = clicks + :inc",
                      ExpressionAttributeValues={":inc":1})

    return {"statusCode":301, "headers":{"Location": item["long_url"]}}