# RDS Password Rotation with AWS Lambda

This project automates the secure rotation of RDS database passwords using AWS Lambda, EventBridge, and Systems Manager (SSM) Parameter Store. It ensures that database credentials are rotated regularly and securely stored, minimizing the risk of unauthorized access.

---

## **Features**

- **Automated Password Rotation**:
  - Uses an AWS Lambda function to generate and rotate RDS database passwords.
  - Supports both MySQL and PostgreSQL databases.

- **Secure Credential Storage**:
  - Stores the rotated passwords in AWS SSM Parameter Store as encrypted SecureString parameters.

- **Event-Driven Execution**:
  - Uses AWS EventBridge to trigger the Lambda function at regular intervals (e.g., every 10 minutes).

- **VPC Integration**:
  - Ensures the Lambda function can securely connect to the RDS instance within a VPC.

- **Customizable Configuration**:
  - Modular Terraform setup allows for easy customization of VPC, subnets, RDS, and Lambda configurations.

---

## **Architecture**

1. **VPC and Subnets**:
   - A VPC is created with public and private subnets for secure communication between resources.

2. **RDS Instance**:
   - An RDS database instance is deployed in private subnets.

3. **Lambda Function**:
   - A Lambda function is deployed to handle password rotation.
   - The function connects to the RDS instance, rotates the password, and updates the SSM Parameter Store.

4. **EventBridge**:
   - An EventBridge rule triggers the Lambda function at regular intervals.

5. **SSM Parameter Store**:
   - Stores the database credentials securely and provides them to the Lambda function during execution.

---

## **Modules**

### **1. VPC**
- Creates a VPC with public and private subnets.
- Provides networking infrastructure for the RDS instance and Lambda function.

### **2. Subnets**
- Configures public and private subnets within the VPC.

### **3. RDS**
- Deploys an RDS database instance in private subnets.
- Configures security groups to allow access from the Lambda function.

### **4. Lambda Rotation**
- Deploys the Lambda function for password rotation.
- Configures IAM roles and policies for secure access to RDS and SSM.

### **5. Secrets**
- Manages the storage of database credentials in SSM Parameter Store.

---

## **Terraform Configuration**

### **Inputs**
The project uses the following input variables:

| Variable Name         | Description                                      | Default Value                          |
|------------------------|--------------------------------------------------|----------------------------------------|
| `region`              | AWS region where resources will be deployed      | `us-east-1`                            |
| `vpc_cidr_block`      | CIDR block for the VPC                           | `10.0.0.0/16`                          |
| `subnets`             | List of subnet CIDR blocks                       | `["10.0.1.0/24", "10.0.2.0/24"]`       |
| `db_port`             | Port for the RDS database                        | `3306`                                 |
| `lambda_function_name`| Name of the Lambda function                      | `rds-password-rotation`                |
| `parameter_name`      | Name of the SSM parameter to store credentials   | `/prod/database/credentials`           |
| `ca_bundle_path`      | Path to the CA bundle for SSL connections        | `/var/task/certs/global-bundle.pem`    |

### **Outputs**
The project provides the following outputs:

| Output Name           | Description                                      |
|------------------------|--------------------------------------------------|
| `vpc_id`              | ID of the created VPC                           |
| `private_subnet_ids`  | IDs of the private subnets                      |
| `rds_instance_id`     | ID of the RDS instance                          |
| `lambda_function_arn` | ARN of the deployed Lambda function             |

---

## **Deployment Instructions**

### **Prerequisites**
1. Install [Terraform](https://www.terraform.io/downloads).
2. Configure AWS CLI with appropriate credentials:
   ```bash
   aws configure
   ```

### **Steps**
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd rds-instance
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the Terraform plan:
   ```bash
   terraform plan
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

5. Verify the deployment:
   - Check the AWS Management Console for the created resources (VPC, RDS, Lambda, etc.).
   - Monitor the CloudWatch Logs for the Lambda function to ensure it is working as expected.

---

## **Running the Lambda Function**

### **Manually Trigger the Lambda Function**
You can manually invoke the Lambda function using the AWS CLI:
```bash
aws lambda invoke \
  --function-name rds-password-rotation \
  --payload '{}' \
  output.json
```

- Replace `rds-password-rotation` with the name of your Lambda function.
- The output of the function will be saved in the `output.json` file.

### **Automated Execution**
The Lambda function is automatically triggered by an EventBridge rule at regular intervals (e.g., every 10 minutes). You can adjust the schedule by modifying the `schedule_expression` in the Terraform configuration.

---

## **Testing**

1. **Trigger the Lambda Function**:
   - Manually invoke the Lambda function from the AWS Management Console or CLI:
     ```bash
     aws lambda invoke --function-name rds-password-rotation output.json
     ```

2. **Verify Password Rotation**:
   - Check the RDS instance to ensure the password has been updated.
   - Verify that the new password is stored in the SSM Parameter Store.

3. **Monitor Logs**:
   - Use CloudWatch Logs to monitor the execution of the Lambda function.

---

## **Troubleshooting**

1. **Access Denied Errors**:
   - Ensure the Lambda function has the necessary IAM permissions to access RDS and SSM.

2. **Database Connection Issues**:
   - Verify that the security groups and subnet configurations allow the Lambda function to connect to the RDS instance.

3. **SSM Parameter Not Found**:
   - Ensure the correct parameter name is specified in the Terraform configuration.

---

## **Future Enhancements**

- Add support for additional database engines (e.g., Oracle, SQL Server).
- Integrate with AWS Secrets Manager for enhanced secret management.
- Implement Slack notifications for password rotation failures.

---