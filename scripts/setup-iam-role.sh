#!/bin/bash
# Setup IAM Role and Instance Profile for Elastic Beanstalk with ECR Access
# This script creates a custom IAM policy and role for EB to pull Docker images from ECR

set -e  # Exit on error

echo "🚀 Setting up IAM Role for Elastic Beanstalk with ECR Access..."
echo ""

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📋 AWS Account ID: $ACCOUNT_ID"
echo ""

# Step 1: Create custom policy
echo "1️⃣  Creating custom IAM policy..."
cat > eb-ecr-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ElasticBeanstalkPermissions",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeInstanceStatus",
        "ssm:*",
        "ec2messages:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRPullPermissions",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::elasticbeanstalk-*",
        "arn:aws:s3:::elasticbeanstalk-*/*"
      ]
    }
  ]
}
EOF

# Check if policy already exists
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/ElasticBeanstalkECRAccess"
if aws iam get-policy --policy-arn "$POLICY_ARN" &>/dev/null; then
  echo "   ⚠️  Policy already exists: ElasticBeanstalkECRAccess"
else
  aws iam create-policy \
    --policy-name ElasticBeanstalkECRAccess \
    --policy-document file://eb-ecr-policy.json \
    --description "Custom policy for Elastic Beanstalk to pull Docker images from ECR"
  echo "   ✅ Created policy: ElasticBeanstalkECRAccess"
fi
echo ""

# Step 2: Create trust policy
echo "2️⃣  Creating trust policy..."
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
echo "   ✅ Created trust-policy.json"
echo ""

# Step 3: Create IAM role
echo "3️⃣  Creating IAM role..."
ROLE_NAME="aws-elasticbeanstalk-ec2-role-docker"
if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
  echo "   ⚠️  Role already exists: $ROLE_NAME"
else
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file://trust-policy.json \
    --description "IAM role for Elastic Beanstalk EC2 instances with ECR access"
  echo "   ✅ Created role: $ROLE_NAME"
fi
echo ""

# Step 4: Attach custom policy to role
echo "4️⃣  Attaching policy to role..."
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "$POLICY_ARN"
echo "   ✅ Attached policy to role"
echo ""

# Step 5: Create instance profile
echo "5️⃣  Creating instance profile..."
INSTANCE_PROFILE_NAME="aws-elasticbeanstalk-ec2-role-docker"
if aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" &>/dev/null; then
  echo "   ⚠️  Instance profile already exists: $INSTANCE_PROFILE_NAME"
else
  aws iam create-instance-profile \
    --instance-profile-name "$INSTANCE_PROFILE_NAME"
  echo "   ✅ Created instance profile: $INSTANCE_PROFILE_NAME"
fi
echo ""

# Step 6: Add role to instance profile
echo "6️⃣  Adding role to instance profile..."
# Check if role is already in instance profile
if aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" | grep -q "$ROLE_NAME"; then
  echo "   ⚠️  Role already added to instance profile"
else
  aws iam add-role-to-instance-profile \
    --instance-profile-name "$INSTANCE_PROFILE_NAME" \
    --role-name "$ROLE_NAME"
  echo "   ✅ Added role to instance profile"
fi
echo ""

# Cleanup temporary files
echo "🧹 Cleaning up temporary files..."
rm -f eb-ecr-policy.json trust-policy.json
echo ""

# Summary
echo "✅ Setup Complete!"
echo ""
echo "📋 Summary:"
echo "   Policy ARN: $POLICY_ARN"
echo "   Role Name: $ROLE_NAME"
echo "   Instance Profile: $INSTANCE_PROFILE_NAME"
echo ""
echo "🎯 Next Steps:"
echo "   1. Create ECR repository if not exists:"
echo "      aws ecr create-repository --repository-name react-demo --region ap-southeast-2"
echo ""
echo "   2. When creating EB environment, use this instance profile:"
echo "      --instance-profile $INSTANCE_PROFILE_NAME"
echo ""
echo "   Or the workflow will automatically use this profile when creating environments."
echo ""
