.PHONY: help install check deploy destroy status clean

help:
	@echo "AWS Infrastructure Automation"
	@echo "============================="
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make check      - Run syntax check"
	@echo "  make deploy     - Deploy AWS infrastructure"
	@echo "  make status     - Show infrastructure status"
	@echo "  make destroy    - Destroy all AWS resources"
	@echo "  make clean      - Clean temporary files"

install:
	@echo "Installing dependencies..."
	pip3 install boto3 botocore
	ansible-galaxy collection install amazon.aws
	ansible-galaxy collection install community.aws

check:
	@echo "Checking syntax..."
	ansible-playbook site.yml --syntax-check
	@echo "Running dry-run..."
	ansible-playbook site.yml --check

deploy:
	@echo "Deploying AWS infrastructure..."
	ansible-playbook site.yml

status:
	@echo "Checking AWS infrastructure status..."
	@echo ""
	@echo "=== VPC Information ==="
	@cat vpc_info.txt 2>/dev/null || echo "VPC not deployed"
	@echo ""
	@echo "=== EC2 Instances ==="
	@cat ec2_instances.txt 2>/dev/null || echo "EC2 instances not deployed"
	@echo ""
	@echo "=== Load Balancer ==="
	@cat elb_info.txt 2>/dev/null || echo "Load balancer not deployed"

destroy:
	@echo "⚠️  WARNING: This will destroy ALL AWS resources!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	ansible-playbook destroy.yml

clean:
	@echo "Cleaning up..."
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete
	rm -f *_info.txt
