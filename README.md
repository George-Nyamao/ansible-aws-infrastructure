# Ansible AWS Infrastructure Automation

Complete AWS infrastructure automation using Ansible - VPC, EC2, RDS, S3, ELB, and security configuration.

## Features

## 🔗 Connect With Me

[![GitHub](https://img.shields.io/badge/GitHub-George--Nyamao-181717?style=for-the-badge&logo=github)](https://github.com/George-Nyamao)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-George_Nyamao-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/george-nyamao-842137218/)
[![Email](https://img.shields.io/badge/Email-gmnyamao@hotmail.com-D14836?style=for-the-badge&logo=gmail)](mailto:gmnyamao@hotmail.com)

- ✅ VPC with public and private subnets
- ✅ Internet Gateway and NAT Gateway
- ✅ EC2 instances with Auto Scaling
- ✅ Application Load Balancer
- ✅ RDS MySQL database
- ✅ S3 bucket with encryption
- ✅ Security groups and network ACLs
- ✅ CloudWatch monitoring
- ✅ Infrastructure as Code
- ✅ One-command deployment

## Project Structure

```
.
├── ansible.cfg
├── site.yml
├── destroy.yml
├── Makefile
├── requirements.yml
├── inventory/
│   └── hosts
├── group_vars/
│   └── all.yml
└── roles/
    ├── aws-vpc/
    ├── aws-ec2/
    ├── aws-rds/
    ├── aws-s3/
    ├── aws-elb/
    └── aws-security/
```

## Prerequisites

### AWS Account Setup

1. **AWS Account**: Active AWS account
2. **AWS CLI**: Installed and configured
3. **IAM User**: With programmatic access
4. **Permissions**: Administrator or equivalent

### Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "s3:*",
        "elasticloadbalancing:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### Local Requirements

- Python 3.6+
- Ansible 2.9+
- boto3
- botocore
- AWS CLI

## Quick Start

### 1. Clone Repository

```bash
git clone git@github.com:George-Nyamao/ansible-aws-infrastructure.git
cd ansible-aws-infrastructure
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region name: us-east-1
# Default output format: json
```

Verify credentials:
```bash
aws sts get-caller-identity
```

### 3. Install Dependencies

```bash
make install
# or
pip3 install boto3 botocore
ansible-galaxy collection install -r requirements.yml
```

### 4. Configure Variables

Edit `group_vars/all.yml`:

```yaml
project_name: "myproject"
environment: "production"
aws_region: "us-east-1"
ec2_instance_type: "t3.micro"
rds_master_password: "YourSecurePassword123!"
```

### 5. Deploy Infrastructure

```bash
make deploy
# or
ansible-playbook site.yml
```

### 6. Check Status

```bash
make status
```

## Usage

### Deploy Specific Components

```bash
# VPC only
ansible-playbook site.yml --tags vpc

# EC2 instances only
ansible-playbook site.yml --tags ec2

# RDS database only
ansible-playbook site.yml --tags rds

# Load balancer only
ansible-playbook site.yml --tags elb
```

### View Infrastructure Details

```bash
# VPC information
cat vpc_info.txt

# EC2 instances
cat ec2_instances.txt

# RDS database
cat rds_info.txt

# Load balancer
cat elb_info.txt
```

### Access EC2 Instances

```bash
# SSH into instance
ssh -i myproject-key.pem ec2-user@<PUBLIC_IP>

# Using AWS Systems Manager Session Manager
aws ssm start-session --target <INSTANCE_ID>
```

### Destroy Infrastructure

```bash
make destroy
# or
ansible-playbook destroy.yml
```

**⚠️ WARNING**: This will permanently delete all resources!

## Architecture

### Network Architecture

```
Internet
   |
   v
Internet Gateway
   |
   v
Application Load Balancer (Public Subnets)
   |
   v
EC2 Instances (Public Subnets)
   |
   v
RDS Database (Private Subnets)
   |
   v
NAT Gateway --> Internet
```

### Components

#### VPC
- CIDR: 10.0.0.0/16
- 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 Private Subnets (10.0.10.0/24, 10.0.20.0/24)
- Internet Gateway
- NAT Gateway
- Route Tables

#### Security Groups
- **Web SG**: HTTP (80), HTTPS (443), SSH (22)
- **App SG**: Port 8080 from Web SG
- **DB SG**: MySQL (3306) from App SG

#### EC2 Instances
- Type: t3.micro (configurable)
- AMI: Amazon Linux 2
- Auto Scaling: 2 instances
- Public IP: Enabled

#### Load Balancer
- Type: Application Load Balancer
- Scheme: Internet-facing
- Health checks: /health endpoint

#### RDS Database
- Engine: MySQL 8.0
- Instance Class: db.t3.micro
- Storage: 20GB encrypted
- Multi-AZ: Optional
- Automated backups: 7 days

#### S3 Bucket
- Encryption: Enabled (KMS)
- Versioning: Enabled
- Public access: Blocked
- Lifecycle policies: Configured

## Configuration

### Environment Variables

Edit `group_vars/all.yml`:

```yaml
# Project settings
project_name: "myproject"
environment: "production"

# AWS settings
aws_region: "us-east-1"

# VPC settings
vpc_cidr_block: "10.0.0.0/16"

# EC2 settings
ec2_instance_type: "t3.micro"
ec2_instance_count: 2

# RDS settings
rds_instance_class: "db.t3.micro"
rds_allocated_storage: 20
rds_multi_az: false
```

### Custom AMI

To use a custom AMI:

```yaml
ec2_ami: "ami-XXXXXXXXX"  # Your custom AMI ID
```

### Instance Types

```yaml
# Development
ec2_instance_type: "t3.micro"

# Production
ec2_instance_type: "t3.medium"

# High performance
ec2_instance_type: "c5.large"
```

## Security Best Practices

1. **IAM Roles**: Use IAM roles instead of access keys
2. **Encryption**: Enable encryption for EBS, RDS, S3
3. **Security Groups**: Follow principle of least privilege
4. **Private Subnets**: Place databases in private subnets
5. **Secrets Management**: Use AWS Secrets Manager
6. **MFA**: Enable MFA for AWS account
7. **CloudTrail**: Enable for audit logging
8. **VPC Flow Logs**: Enable for network monitoring
9. **Regular Backups**: Automated RDS and S3 backups
10. **Patch Management**: Regular OS and application updates

## Monitoring

### CloudWatch Metrics

```bash
# View EC2 metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<INSTANCE_ID> \
  --start-time $(date -u -d "1 hour ago" +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Average
```

### RDS Monitoring

```bash
# View RDS metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=<DB_INSTANCE_ID> \
  --start-time $(date -u -d "1 hour ago" +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Average
```

## Cost Optimization

### Estimated Monthly Costs

| Resource | Type | Estimated Cost |
|----------|------|----------------|
| EC2 (t3.micro x2) | On-Demand | $15/month |
| RDS (db.t3.micro) | Single-AZ | $15/month |
| ALB | Standard | $22/month |
| NAT Gateway | Standard | $45/month |
| S3 | Standard | $1/month |
| **Total** | | **~$98/month** |

### Cost Reduction Tips

1. **Reserved Instances**: Save up to 75%
2. **Spot Instances**: Save up to 90%
3. **Right-sizing**: Use appropriate instance types
4. **Auto Scaling**: Scale based on demand
5. **S3 Lifecycle**: Move old data to
cat >> README.md << 'EOF'
 Glacier
6. **Delete Unused Resources**: Regularly audit and remove
7. **Use AWS Cost Explorer**: Monitor spending
8. **Set Billing Alerts**: Get notified of unexpected charges

## Troubleshooting

### Common Issues

#### Authentication Errors

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Reconfigure AWS CLI
aws configure

# Check environment variables
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

#### Resource Already Exists

```bash
# Check existing resources
aws ec2 describe-vpcs --region us-east-1
aws ec2 describe-instances --region us-east-1

# Clean up manually or use destroy playbook
make destroy
```

#### Insufficient Permissions

```bash
# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name <USERNAME>

# Add required policies to IAM user
```

#### VPC Quota Exceeded

```bash
# Check VPC limits
aws service-quotas get-service-quota \
  --service-code vpc \
  --quota-code L-F678F1CE

# Request quota increase
aws service-quotas request-service-quota-increase \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --desired-value 10
```

### Debug Mode

Run playbook with increased verbosity:

```bash
ansible-playbook site.yml -vvv
```

### Log Files

Check Ansible logs:

```bash
tail -f ansible.log
```

## Advanced Usage

### Multi-Region Deployment

Edit inventory for multiple regions:

```yaml
# group_vars/us_east.yml
aws_region: "us-east-1"

# group_vars/us_west.yml
aws_region: "us-west-2"
```

### Blue-Green Deployment

```bash
# Deploy green environment
ansible-playbook site.yml -e "environment=green"

# Switch traffic
# Update Route53 or ALB target groups

# Destroy blue environment
ansible-playbook destroy.yml -e "environment=blue"
```

### Disaster Recovery

```bash
# Backup current infrastructure state
ansible-playbook backup.yml

# Restore in different region
ansible-playbook restore.yml -e "aws_region=us-west-2"
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy AWS Infrastructure

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Install dependencies
        run: |
          pip install boto3 botocore
          ansible-galaxy collection install -r requirements.yml
      
      - name: Deploy infrastructure
        run: ansible-playbook site.yml
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
    }
    
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'pip install boto3 botocore'
                sh 'ansible-galaxy collection install -r requirements.yml'
            }
        }
        
        stage('Deploy Infrastructure') {
            steps {
                sh 'ansible-playbook site.yml'
            }
        }
        
        stage('Verify Deployment') {
            steps {
                sh 'ansible-playbook verify.yml'
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '*_info.txt', allowEmptyArchive: true
        }
    }
}
```

## Testing

### Infrastructure Tests

Create `verify.yml`:

```yaml
---
- name: Verify AWS Infrastructure
  hosts: localhost
  connection: local
  
  tasks:
    - name: Check VPC exists
      amazon.aws.ec2_vpc_net_info:
        filters:
          "tag:Name": "{{ vpc_name }}"
        region: "{{ aws_region }}"
      register: vpc_check
      failed_when: vpc_check.vpcs | length == 0
    
    - name: Check EC2 instances running
      amazon.aws.ec2_instance_info:
        filters:
          "tag:Project": "{{ project_name }}"
          instance-state-name: running
        region: "{{ aws_region }}"
      register: ec2_check
      failed_when: ec2_check.instances | length < ec2_instance_count
    
    - name: Check RDS instance available
      amazon.aws.rds_instance_info:
        db_instance_identifier: "{{ project_name }}-{{ environment }}-db"
        region: "{{ aws_region }}"
      register: rds_check
      failed_when: rds_check.instances[0].db_instance_status != 'available'
    
    - name: Check Load Balancer active
      amazon.aws.elb_application_lb_info:
        names:
          - "{{ elb_name }}"
        region: "{{ aws_region }}"
      register: alb_check
      failed_when: alb_check.load_balancers[0].state.code != 'active'
```

Run tests:

```bash
ansible-playbook verify.yml
```

## Backup and Recovery

### Manual Backup

```bash
# Backup RDS
aws rds create-db-snapshot \
  --db-instance-identifier myproject-production-db \
  --db-snapshot-identifier myproject-backup-$(date +%Y%m%d)

# Backup S3
aws s3 sync s3://myproject-production-bucket ./backup/
```

### Automated Backups

RDS automated backups are enabled with 7-day retention.

### Recovery

```bash
# Restore RDS from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myproject-restored \
  --db-snapshot-identifier myproject-backup-20240101

# Restore S3
aws s3 sync ./backup/ s3://myproject-production-bucket/
```

## Maintenance

### Update Infrastructure

```bash
# Update configuration
vim group_vars/all.yml

# Apply changes
ansible-playbook site.yml
```

### Scale EC2 Instances

```bash
# Update instance count
ansible-playbook site.yml -e "ec2_instance_count=4"
```

### Upgrade RDS Instance

```bash
# Update instance class
ansible-playbook site.yml -e "rds_instance_class=db.t3.small"
```

## Requirements

### System Requirements
- Ansible 2.9 or higher
- Python 3.6 or higher
- AWS CLI 2.x
- boto3 >= 1.26.0
- botocore >= 1.29.0

### AWS Account Requirements
- Active AWS account
- IAM user with programmatic access
- Required permissions (see IAM policy above)
- Service limits adequate for deployment

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

MIT License - see LICENSE file

## Support

[![GitHub Issues](https://img.shields.io/github/issues/George-Nyamao/ansible-aws-infrastructure?style=flat)](https://github.com/George-Nyamao/ansible-aws-infrastructure/issues)
[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-181717?style=flat&logo=github)](https://github.com/George-Nyamao/ansible-aws-infrastructure/discussions)

- **Issues**: [GitHub Issues](https://github.com/George-Nyamao/ansible-aws-infrastructure/issues)
- **Documentation**: See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guide

[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-181717?style=flat## Supportlogo=github)](https://github.com/George-Nyamao/ansible-aws-infrastructure/discussions)

[![GitHub Issues](https://img.shields.io/github/issues/George-Nyamao/ansible-aws-infrastructure?style=flat)](https://github.com/George-Nyamao/ansible-aws-infrastructure/issues)
[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-181717?style=flat&logo=github)](https://github.com/George-Nyamao/ansible-aws-infrastructure/discussions)

- **Issues**: [GitHub Issues](https://github.com/George-Nyamao/ansible-aws-infrastructure/issues)
- **Documentation**: See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guide

## Changelog

### v1.0.0 (2025-10-23)
- Initial release
- VPC with public/private subnets
- EC2 instances with ALB
- RDS MySQL database
- S3 bucket with encryption
- Security group configuration
- One-command deployment

## Roadmap

- [ ] Auto Scaling Groups
- [ ] CloudFront CDN
- [ ] Route53 DNS configuration
- [ ] AWS Lambda functions
- [ ] ECS/EKS container orchestration
- [ ] CloudFormation export
- [ ] Terraform compatibility
- [ ] Multi-region support
- [ ] Disaster recovery automation

## FAQ

### Q: How much does this infrastructure cost?

A: Approximately $98/month with default settings. Costs vary by region and usage.

### Q: Can I use this in production?

A: Yes, but review security settings and adjust for your requirements.

### Q: How do I change the AWS region?

A: Edit `group_vars/all.yml` and update `aws_region`.

### Q: What if deployment fails?

A: Run `make destroy` to clean up partial deployments, then retry.

### Q: How do I add more EC2 instances?

A: Update `ec2_instance_count` in `group_vars/all.yml` and redeploy.

### Q: Is HTTPS supported?

A: Yes, configure ACM certificate and update ALB listener.

### Q: Can I use existing VPC?

A: Yes, modify the VPC role to use existing VPC ID.

## Author

**George Nyamao**
- GitHub: [@George-Nyamao](https://github.com/George-Nyamao)
- LinkedIn: [George Nyamao](https://www.linkedin.com/in/george-nyamao-842137218/)
- Email: gmnyamao@hotmail.com

## Related Projects

- [Ansible LAMP Stack](git@github.com:George-Nyamao/ansible-lamp-stack.git)
- [Ansible Docker Automation](git@github.com:George-Nyamao/ansible-docker-automation.git)
- [Ansible Jenkins CI/CD](git@github.com:George-Nyamao/ansible-jenkins-cicd.git)
- [Ansible Kubernetes](git@github.com:George-Nyamao/ansible-kubernetes.git)

## Acknowledgments

- AWS for excellent cloud infrastructure
- Ansible community
- Contributors and testers

---

⭐ **Star this repository if you find it helpful!**

## Security Notice

**⚠️ IMPORTANT**: Never commit AWS credentials to version control!

Always use:
- AWS IAM roles
- Environment variables
- AWS Secrets Manager
- Ansible Vault for sensitive data

## Legal

This project is for educational purposes. Review AWS terms of service and ensure compliance with your organization's policies.
