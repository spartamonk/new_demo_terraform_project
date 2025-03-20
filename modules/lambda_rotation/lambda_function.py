import boto3
import os
import json
import string
import random
import logging
import pg8000
import pymysql
from botocore.config import Config
from botocore.exceptions import ClientError, BotoCoreError

# AWS Clients with retry config
boto_config = Config(
    retries={
        'max_attempts': 5,
        'mode': 'standard'
    },
    connect_timeout=5,
    read_timeout=10
)

ssm = boto3.client('ssm', config=boto_config)

# Logging setup
logger = logging.getLogger()
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Environment variables
SSM_PARAMETER_NAME = os.environ.get('SSM_PARAMETER_NAME', 'default-param')
# SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL')  # Commented out
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')
ENABLE_SSL = ENVIRONMENT == 'prod'
CA_BUNDLE_PATH = os.environ.get('CA_BUNDLE_PATH', '/var/tasks/certs/global-bundle.pem')

# Password generation with industry best practices
def generate_secure_password(length=20):
    chars = string.ascii_letters + string.digits + "!@#$%^&*()-_+="
    return ''.join(random.SystemRandom().choice(chars) for _ in range(length))

# DB Connectors
def connect_mysql(host, user, password, database, port):
    try:
        ssl_options = {'ca': CA_BUNDLE_PATH} if ENABLE_SSL else None
        conn = pymysql.connect(host=host, user=user, password=password, database=database, port=port, ssl=ssl_options, connect_timeout=10)
        logger.info("Connected to MySQL/Aurora MySQL successfully.")
        return conn
    except pymysql.MySQLError as e:
        logger.error(f"MySQL connection failed: {e}")
        raise

def connect_postgres(host, user, password, database, port):
    try:
        ssl_context = None
        if ENABLE_SSL:
            import ssl
            ssl_context = ssl.create_default_context(cafile=CA_BUNDLE_PATH)
        conn = pg8000.connect(
            host=host,
            user=user,
            password=password,
            database=database,
            port=port,
            ssl_context=ssl_context
        )
        logger.info("Connected to PostgreSQL/Aurora PostgreSQL successfully using pg8000.")
        return conn
    except pg8000.exceptions.InterfaceError as e:
        logger.error(f"PostgreSQL connection failed: {e}")
        raise

def wait_for_aurora_serverless():
    logger.info("Aurora Serverless detected, sleeping to allow warm-up...")
    import time
    try:
        time.sleep(20)  # Adjustable based on Aurora autoscaling warm-up times
    except Exception as e:
        logger.warning(f"Error during Aurora warm-up wait: {e}")

# Commented out Slack notification function
# def publish_alert(subject, message):
#     if not SLACK_WEBHOOK_URL:
#         logger.warning("SLACK_WEBHOOK_URL not provided.")
#         return
#     payload = {
#         "attachments": [
#             {
#                 "color": "#FF0000",  # Red color for alerts
#                 "pretext": f":warning: *{subject}*",
#                 "text": f"{message}",
#                 "mrkdwn_in": ["pretext", "text"]
#             }
#         ]
#     }
#     try:
#         response = requests.post(SLACK_WEBHOOK_URL, data=json.dumps(payload), headers={'Content-Type': 'application/json'})
#         if response.status_code != 200:
#             logger.error(f"Slack webhook returned status {response.status_code}: {response.text}")
#         else:
#             logger.info("Alert sent to Slack successfully.")
#     except Exception as e:
#         logger.error(f"Failed to send alert to Slack: {e}")

def lambda_handler(event, context):
    try:
        # Step 1: Fetch consolidated credentials
        response = ssm.get_parameter(Name=SSM_PARAMETER_NAME, WithDecryption=True)
        secret_data = json.loads(response['Parameter']['Value'])
        db_engine = secret_data.get('db_engine', 'mysql')
        db_user = secret_data['db_user']
        old_password = secret_data['db_password']
        db_endpoint = secret_data['db_endpoint']
        db_name = secret_data['db_name']
        db_port = secret_data.get('db_port', 3306)

        if 'aurora' in db_engine:
            wait_for_aurora_serverless()

        # Step 2: Generate new secure password
        new_password = generate_secure_password()

        # Step 3: Check if password has already been rotated
        logger.info("Testing if new password already in use...")
        try:
            conn_test = connect_postgres(db_endpoint, db_user, new_password, db_name, db_port) if 'postgres' in db_engine else connect_mysql(db_endpoint, db_user, new_password, db_name, db_port)
            conn_test.close()
            logger.info("New password already active, skipping rotation.")
            return {'statusCode': 200, 'body': 'Password already rotated.'}
        except Exception:
            logger.info("New password not yet active, continuing...")

        # Step 4: Connect with old password and rotate
        logger.info("Connecting to DB using current password...")
        try:
            conn = connect_postgres(db_endpoint, db_user, old_password, db_name, db_port) if 'postgres' in db_engine else connect_mysql(db_endpoint, db_user, old_password, db_name, db_port)
        except Exception as e:
            logger.error(f"Failed to connect with old password: {e}")
            # Commented out Slack alert
            # publish_alert("Password Rotation Failed", f"Could not connect to DB: {e}")
            return {'statusCode': 500, 'body': 'Connection failed.'}

        with conn.cursor() as cursor:
            logger.info("Rotating DB user password...")
            if 'postgres' in db_engine:
                cursor.execute("ALTER USER %s WITH PASSWORD %s", (db_user, new_password))
            else:
                cursor.execute("ALTER USER %s@'%%' IDENTIFIED BY %s", (db_user, new_password))
            conn.commit()
        conn.close()

        # Step 5: Verify new password
        logger.info("Testing DB connection using new password...")
        conn_new = connect_postgres(db_endpoint, db_user, new_password, db_name, db_port) if 'postgres' in db_engine else connect_mysql(db_endpoint, db_user, new_password, db_name, db_port)
        conn_new.close()
        logger.info("DB connection with new password successful.")

        # Step 6: Update SSM Parameter Store with new password
        secret_data['db_password'] = new_password
        ssm.put_parameter(Name=SSM_PARAMETER_NAME, Value=json.dumps(secret_data), Type='SecureString', Overwrite=True)
        logger.info("Rotation complete and SSM updated.")

        return {'statusCode': 200, 'body': 'Rotation successful.'}

    except Exception as e:
        logger.error(f"Unhandled error: {e}")
        # Commented out Slack alert
        # publish_alert("Unhandled Lambda Error", str(e))
        return {'statusCode': 500, 'body': f"Unhandled error: {e}"}