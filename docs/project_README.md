# Mini Project 1: Deploy a Web App with Full CI/CD Pipeline

## 🎯 Project Overview

This capstone project integrates everything you've learned in the DevOps course so far: **Git source control**, **Terraform**, **GitHub Actions**, and **AWS**. You'll build a complete CI/CD pipeline that automatically tests Python code and deploys it to an AWS EC2 instance.

### What You'll Build:
- 🏗️ **Infrastructure as Code** - Provision AWS EC2 with Terraform
- 🐍 **Python Web Application** - A simple REST API with business logic
- 🧪 **Automated Testing** - Unit tests, linting, and code coverage
- 🚀 **CI/CD Pipeline** - Automated testing on PRs and deployment on merge
- 🔒 **Security Best Practices** - Secrets management and secure deployment

---

## 📁 Project Structure

```
mini-project1/
├── terraform/                     # YOU CREATE THIS - Terraform infrastructure code
│   ├── main.tf                    # Main infrastructure configuration
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values (EC2 IP, etc.)
│   ├── terraform.tfvars.example   # Example variables file
│   └── modules/                   # Terraform modules (VPC, Security Group, EC2)
│       ├── vpc/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── security_group/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── ec2/
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── user_data.sh       # EC2 bootstrap script
├── app/                           # PROVIDED - Python application
│   ├── main.py                    # Flask REST API
│   ├── business_logic.py          # Core business logic functions
│   ├── requirements.txt           # Python dependencies
│   └── tests/
│       ├── test_logic.py          # Unit tests for business logic
│       └── test_api.py            # API endpoint tests
├── .github/                       # YOU CREATE THIS - GitHub Actions workflows
│   └── workflows/
│       ├── test.yml               # Run tests on pull requests
│       └── deploy.yml             # Deploy to EC2 on merge to main
├── .gitignore                     # Ignore sensitive files
└── README.md                      # This file
```

**Note:** The Python application code is provided. You need to create:
- ✅ Terraform infrastructure using modules
- ✅ GitHub Actions workflows
- ✅ Deployment scripts (optional)

---

## 🏗️ Part 1: Infrastructure (Terraform) - **YOU CREATE THIS**

### ⚠️ Important: Use Terraform Modules!

Your Terraform code **MUST** be organized into reusable modules. Create separate modules for:

1. **VPC Module** (`modules/vpc/`)
   - VPC with proper CIDR
   - Internet Gateway
   - Public subnet
   - Route table and associations

2. **Security Group Module** (`modules/security_group/`)
   - Security group with proper rules
   - Configurable ports and CIDR blocks

3. **EC2 Module** (`modules/ec2/`)
   - EC2 instance
   - User data script
   - Optional Elastic IP

### Resources to Create:

#### Module 1: VPC
- **VPC**: CIDR 10.0.0.0/16
- **Internet Gateway**: For internet access
- **Public Subnet**: CIDR 10.0.1.0/24
- **Route Table**: Route to internet gateway

#### Module 2: Security Group
Configure inbound rules:
- **SSH** (port 22) - Your IP only (for security)
- **HTTP** (port 80) - 0.0.0.0/0 (optional)
- **HTTPS** (port 443) - 0.0.0.0/0 (optional)
- **App Port** (port 5000) - 0.0.0.0/0 (for Flask API)

Outbound rules:
- Allow all outbound traffic

#### Module 3: EC2
- **Instance Type**: `t3.micro` (free tier eligible)
- **AMI**: Ubuntu 22.04 LTS
- **Storage**: 8GB root volume
- **Key Pair**: Your SSH key pair name
- **Tags**: Environment, Project name

#### User Data Script
Create a bash script in `modules/ec2/user_data.sh` to:
- Update system packages (`apt-get update && apt-get upgrade`)
- Install Python 3.11+ (`apt-get install python3.11 python3-pip git`)
- Create app user and directory
- Clone your GitHub repository
- Create Python virtual environment
- Install dependencies from requirements.txt
- Install gunicorn (production WSGI server)
- Create systemd service file
- Start the application service

**Tip:** Use `templatefile()` function to pass variables to user_data.sh

### Main Configuration Files:

#### `main.tf`
- Call all three modules
- Pass outputs between modules
- Configure AWS provider


#### `terraform.tfvars.example`
Provide example values for all variables

### Module Structure Example:

Each module should have:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values

```
modules/
├── vpc/
│   ├── main.tf          # VPC, IGW, Subnet, Route Table
│   ├── variables.tf     # project_name, environment
│   └── outputs.tf       # vpc_id, subnet_id
├── security_group/
│   ├── main.tf          # Security group rules
│   ├── variables.tf     # vpc_id, allowed_cidr, ports
│   └── outputs.tf       # security_group_id
└── ec2/
    ├── main.tf          # EC2 instance
    ├── variables.tf     # All EC2 configs
    ├── outputs.tf       # instance_id, public_ip
    └── user_data.sh     # Bootstrap script
```

---

## 🐍 Part 2: Python Application - **PROVIDED**

The Python application is **already provided** in the `app/` folder!

### What's Included:

#### **Todo API** - A simple task management REST API

**Files:**
- `main.py` - Flask REST API with 7 endpoints
- `business_logic.py` - TodoManager class with all CRUD operations
- `requirements.txt` - All dependencies
- `tests/test_logic.py` - 20+ unit tests for business logic
- `tests/test_api.py` - 15+ integration tests for API endpoints

**Endpoints:**
```
GET    /api/todos          - List all todos
POST   /api/todos          - Create a new todo
GET    /api/todos/{id}     - Get specific todo
PUT    /api/todos/{id}     - Update todo
DELETE /api/todos/{id}     - Delete todo
GET    /health             - Health check endpoint
GET    /                   - Welcome page
```

**Data Model:**
```python
{
    "id": 1,
    "title": "Learn DevOps",
    "description": "Complete mini project",
    "completed": false,
    "created_at": "2025-12-20T10:00:00Z"
}
```

**Features:**
- In-memory storage
- CRUD operations
- Input validation
- Proper error handling
- RESTful API design

### Running the Application Locally:

```bash
# Navigate to the app directory
cd app/

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python main.py

# Visit http://localhost:5000
```

### Running Tests:

```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=. --cov-report=term-missing

# Run specific test file
pytest tests/test_logic.py -v
```

### Test Coverage:

The provided tests achieve **>90% code coverage**:
- ✅ 20+ unit tests for business logic
- ✅ 15+ integration tests for API endpoints
- ✅ Edge cases and error scenarios
- ✅ Input validation tests

---

## 🔄 Part 3: GitHub Actions Workflows - **YOU CREATE THIS**

### Workflow 1: Test on Pull Request (`test.yml`)

**Triggers:** When a PR is opened or updated

**Steps:**
1. **Checkout code**
2. **Set up Python 3.11**
3. **Install dependencies**
4. **Lint code** with flake8
   - Check for syntax errors
   - Check code style (PEP 8)
5. **Security scan** with bandit
   - Check for common security issues
6. **Run unit tests**
   - Execute all tests with pytest
   - Generate coverage report
7. **Check coverage**
   - Fail if coverage < 80%
8. **Comment results on PR** (optional)

**Success Criteria:**
- ✅ All tests pass
- ✅ No linting errors
- ✅ No security issues
- ✅ Code coverage ≥ 80%

---

### Workflow 2: Deploy to EC2 (`deploy.yml`)

**Triggers:** Push to `main` branch (after PR merge)

**Steps:**
1. **Checkout code**
2. **Run tests** (same as test workflow)
3. **Configure AWS credentials** (optional - if using AWS CLI)
4. **SSH into EC2 instance**
   - Use GitHub Secrets for SSH key
5. **Deploy application**
   - Pull latest code from GitHub
   - Install/update dependencies
   - Restart application service
6. **Health check**
   - Wait for app to start
   - Test `/health` endpoint
   - Verify app is responding
7. **Notify deployment status**
   - Success or failure message

**Deployment Methods:**

**Method A: Direct Deployment (Simpler)**
```bash
# SSH to EC2
# Pull code: git pull origin main
# Install deps: pip install -r requirements.txt
# Restart: systemctl restart myapp (or use screen/tmux)
```

**Method B: Systemd Service (Recommended)**
```bash
# Create systemd service file
# Enable and start service
# Automatic restart on failure
```

---

## 🔒 Part 4: Security & Secrets Management

### GitHub Secrets to Configure:

1. **AWS_ACCESS_KEY_ID** - AWS credentials (if using AWS CLI)
2. **AWS_SECRET_ACCESS_KEY** - AWS secret key
3. **EC2_SSH_PRIVATE_KEY** - Private key for SSH access
4. **EC2_HOST** - Public IP of EC2 instance
5. **EC2_USER** - Username (ubuntu/ec2-user)

### Security Best Practices:

- ✅ Never commit credentials to Git
- ✅ Use `.gitignore` for sensitive files
- ✅ Restrict Security Group access
- ✅ Use IAM roles instead of access keys (advanced)
- ✅ Rotate credentials regularly
- ✅ Use HTTPS in production (Let's Encrypt)
- ✅ Keep dependencies updated

### Files to Ignore (`.gitignore`):
```
# Python
__pycache__/
*.py[cod]
*.so
.Python
*.egg-info/
venv/
.pytest_cache/
.coverage
htmlcov/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
*.tfvars
!terraform.tfvars.example

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Secrets
*.pem
*.key
.env
```

---

## 📋 Implementation Steps

### Phase 1: Infrastructure Setup

1. **Set up AWS Account**
   - Create/use existing AWS account
   - Configure AWS CLI (optional)

2. **Write Terraform Code**
   - Define EC2 instance
   - Create security group
   - Write user data script
   - Test with `terraform plan`

3. **Provision Infrastructure**
   - Run `terraform apply`
   - Save outputs (IP address)
   - Test SSH access

### Phase 2: Application Development (provided)

4. **Create Python Application**
   - Choose application type
   - Implement business logic
   - Create API endpoints
   - Add configuration management

5. **Write Tests**
   - Unit tests for logic
   - Integration tests for API
   - Aim for >80% coverage

6. **Test Locally**
   - Run application locally
   - Test all endpoints
   - Verify tests pass

### Phase 3: CI/CD Setup

7. **Configure GitHub Secrets**
   - Add AWS credentials
   - Add SSH private key
   - Add EC2 host information

8. **Create Test Workflow**
   - Write `.github/workflows/test.yml`
   - Test on a feature branch
   - Verify workflow runs

9. **Create Deployment Workflow**
   - Write `.github/workflows/deploy.yml`
   - Create deployment script
   - Test deployment manually first

10. **Test Full Pipeline**
    - Create feature branch
    - Make a change
    - Open PR → verify tests run
    - Merge PR → verify deployment
    - Check app is live

### Phase 4: Documentation & Polish

11. **Document Everything**
    - Setup instructions
    - How to run locally
    - How to deploy
    - Troubleshooting guide

12. **Create Demo**
    - Record video or take screenshots
    - Show PR → test → merge → deploy flow
    - Demonstrate live application

---

## 🎓 Learning Objectives

By completing this project, you will demonstrate:

### 1. **Terraform Skills**
- ✅ Provision cloud infrastructure using modules
- ✅ Manage security groups and networking
- ✅ Use variables and outputs effectively
- ✅ Infrastructure as code best practices
- ✅ Create reusable Terraform modules

### 2. **GitHub Actions / CI/CD**
- ✅ Create automated testing pipeline
- ✅ Implement automated deployment
- ✅ Configure workflow triggers
- ✅ Manage secrets securely
- ✅ Integrate multiple jobs and steps

### 3. **Testing & Quality Assurance**
- ✅ Run automated tests in CI
- ✅ Implement code coverage checks
- ✅ Set up linting and security scanning
- ✅ Understand test-driven workflows

### 4. **Git Source Control**
- ✅ Branch-based workflow
- ✅ Pull request process
- ✅ Code review practices
- ✅ Merge strategies

### 5. **DevOps Practices**
- ✅ Continuous Integration
- ✅ Continuous Deployment
- ✅ Infrastructure automation
- ✅ Configuration management

### 6. **AWS/Cloud**
- ✅ EC2 instance management
- ✅ VPC and networking
- ✅ Security groups configuration
- ✅ SSH access and remote deployment
- ✅ User data scripts for bootstrapping

---

## 📊 Grading Rubric (100 points)

### Infrastructure - Terraform Modules (30 points)
- [ ] VPC module created correctly (8 pts)
- [ ] Security Group module with proper rules (7 pts)
- [ ] EC2 module with user_data script (10 pts)
- [ ] Main configuration uses modules correctly (5 pts)

### CI/CD Pipeline (35 points)
- [ ] Test workflow triggers on PR (8 pts)
- [ ] Test workflow runs all quality checks (linting, security, tests) (10 pts)
- [ ] Deploy workflow triggers on merge to main (7 pts)
- [ ] Deployment succeeds automatically (8 pts)
- [ ] Post-deployment health check works (2 pts)

### Git Workflow (15 points)
- [ ] Proper branch strategy used (5 pts)
- [ ] Pull request created and merged (5 pts)
- [ ] Commit messages are clear (3 pts)
- [ ] .gitignore properly configured (2 pts)

### Deployment & Integration (15 points)
- [ ] Application deployed successfully to EC2 (5 pts)
- [ ] Application is accessible via public IP (5 pts)
- [ ] All API endpoints work on deployed instance (3 pts)
- [ ] GitHub Secrets configured correctly (2 pts)

### Documentation (5 points)
- [ ] Setup instructions are clear and accurate (3 pts)
- [ ] Terraform usage documented (2 pts)

---

**Note:** Application code is provided, so grading focuses on infrastructure, CI/CD, and deployment!

---

## 🚀 Bonus Challenges (+20 points)

Want to go further? Try these advanced features:

### 1. **Elastic IP** (+3 pts)
- Add Elastic IP to EC2 module
- Persist IP address across instance restarts
- Update outputs accordingly

### 2. **Multiple Environments** (+5 pts)
- Create separate workspaces for dev/staging/prod
- Environment-specific variable files
- Deploy to staging first, then production

### 3. **Blue-Green Deployment** (+5 pts)
- Deploy to new EC2 instance
- Switch traffic after health check passes
- Keep old instance for quick rollback

### 4. **Monitoring & Logging** (+3 pts)
- Add CloudWatch logs integration
- Set up basic CloudWatch metrics
- Create alarms for application health

### 5. **Auto Scaling** (+5 pts)
- Add Application Load Balancer
- Create Auto Scaling Group
- Deploy to multiple instances

### 6. **Rollback Capability** (+3 pts)
- Keep previous deployment
- Automatic rollback on failed health check
- Manual rollback GitHub Action

### 7. **Docker Containerization** (+5 pts)
- Create Dockerfile for application
- Deploy as container instead of direct Python
- Use docker-compose for local development

### 8. **HTTPS/SSL** (+3 pts)
- Configure SSL certificate (Let's Encrypt)
- Add Route53 for custom domain
- Redirect HTTP to HTTPS

### 9. **Notifications** (+2 pts)
- Slack/Discord notifications on deployment
- Email notifications on failures
- Status badges in README

### 10. **Terraform Remote State** (+3 pts)
- Configure S3 backend for state
- Enable state locking with DynamoDB
- Share state across team
- Keep previous version
- Automatic rollback on failure
- Manual rollback option

### 7. **Load Balancer** (+5 pts)
- Add Application Load Balancer
- Multiple EC2 instances
- Health check integration

### 8. **HTTPS/SSL** (+3 pts)
- Configure SSL certificate
- Use Let's Encrypt
- Redirect HTTP to HTTPS

### 9. **Notifications** (+2 pts)
- Slack/Discord notifications
- Email on deployment
- Status badges in README

### 10. **Performance Tests** (+3 pts)
- Add load testing
- Benchmark endpoints
- Response time checks

---

## 🛠️ Tools & Technologies

### Required:
- **AWS Account** (Free tier sufficient)
- **Terraform** (v1.5+)
- **Python** (3.11+)
- **Git & GitHub**
- **Code Editor** (VS Code recommended)

### Python Frameworks (choose one):
- **Flask** - Simpler, great for learning
- **FastAPI** - Modern, faster, automatic docs

### Testing:
- **pytest** - Testing framework
- **pytest-cov** - Coverage reporting
- **flake8** - Linting
- **bandit** - Security scanning

---

## 📚 Resources

### Terraform:
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform EC2 Example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

### Python/Flask:
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask REST API Tutorial](https://flask.palletsprojects.com/en/latest/quickstart/)
- [pytest Documentation](https://docs.pytest.org/)

### FastAPI (alternative):
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)

### GitHub Actions:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SSH Action](https://github.com/marketplace/actions/ssh-remote-commands)
- [Using Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

### AWS:
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [EC2 Security Groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html)

---

## ⚠️ Common Issues & Troubleshooting

### Issue 1: SSH Connection Failed
**Symptoms:** Can't connect to EC2 instance
**Solutions:**
- Check security group allows your IP on port 22
- Verify private key permissions: `chmod 400 key.pem`
- Use correct username (ubuntu/ec2-user)
- Check EC2 instance is running

### Issue 2: Application Not Accessible
**Symptoms:** Can't access app via browser
**Solutions:**
- Check security group allows port 5000/8000
- Verify app is running: `ps aux | grep python`
- Check app logs for errors
- Ensure app binds to 0.0.0.0, not 127.0.0.1

### Issue 3: GitHub Actions Deployment Fails
**Symptoms:** Deploy workflow fails at SSH step
**Solutions:**
- Verify GitHub Secrets are set correctly
- Check SSH key format (no extra spaces/newlines)
- Ensure EC2_HOST has correct IP address
- Test SSH manually first

### Issue 4: Tests Pass Locally, Fail in CI
**Symptoms:** Tests work on your machine, fail in GitHub Actions
**Solutions:**
- Check Python version matches
- Verify all dependencies in requirements.txt
- Check for hardcoded paths
- Review test output logs in Actions

### Issue 5: Terraform Apply Fails
**Symptoms:** Can't provision infrastructure
**Solutions:**
- Check AWS credentials are configured
- Verify region is correct
- Check AWS service limits
- Review terraform error messages

---

## 🎯 Success Criteria

Your project is successful when:

### ✅ Infrastructure
- Terraform modules are well-organized
- EC2 instance provisions successfully
- VPC and networking configured correctly
- Security groups have proper rules
- Can SSH into the instance

### ✅ Application Deployment
- Application runs without errors on EC2
- All endpoints respond correctly
- Health check returns 200 OK
- Accessible via public IP

### ✅ CI/CD Pipeline
- Test workflow runs on every PR
- All tests pass in CI environment
- No linting or security issues
- Deploy workflow runs on merge to main
- Deployment completes successfully automatically

### ✅ Git Workflow
- Feature branches used properly
- Pull requests created and reviewed
- Clean commit history
- Proper .gitignore configuration

### ✅ Documentation
- README explains setup process
- Terraform usage documented
- All steps are clear

---

## 📅 Recommended Timeline

### Week 1:
- **Days 1-3:** Terraform modules (VPC, Security Group, EC2)
- **Days 4-5:** Test application locally, understand the code
- **Days 6-7:** Initial deployment and troubleshooting

### Week 2:
- **Days 1-2:** CI workflow setup (test on PR)
- **Days 3-4:** CD workflow (deploy on merge)
- **Days 5-6:** Testing full pipeline, bug fixes
- **Day 7:** Documentation and demo prep

**Total Time:** ~2 weeks (15-25 hours)

---

## 🎬 Demo Day Checklist

Prepare to demonstrate:

- [ ] Show GitHub repository structure
- [ ] Show Terraform code and AWS resources
- [ ] Run application locally
- [ ] Show test execution and coverage
- [ ] Create a feature branch and make a change
- [ ] Open PR and show test workflow running
- [ ] Merge PR and show deployment workflow
- [ ] Access live application in browser
- [ ] Show application functionality
- [ ] Explain architecture and decisions

---

## 💡 Tips for Success

1. **Start Simple** - Get basic version working first, then add features
2. **Test Frequently** - Don't wait until the end to test
3. **Commit Often** - Small, frequent commits with clear messages
4. **Document As You Go** - Don't leave documentation for the end
5. **Ask for Help** - Use office hours, Slack, or discussion forums
6. **Budget Time** - Infrastructure issues can take time to debug
7. **Use .gitignore** - Never commit secrets or sensitive data
8. **Test Manually First** - Before automating, do it manually
9. **Read Error Messages** - They usually tell you what's wrong
10. **Have Fun!** - This is a realistic project you can showcase

---

## 🏆 Showcase Your Work

After completing the project:

### Portfolio:
- Add to your GitHub profile
- Include in your resume
- Write a blog post about it

### LinkedIn Post:
Share your achievement with:
- Link to GitHub repo
- Screenshots/demo
- Key learnings
- Technologies used

### Continue Learning:
- Try bonus challenges
- Explore other AWS services
- Learn Kubernetes
- Try other CI/CD tools

---

## 📧 Submission

### What to Submit:

1. **GitHub Repository URL**
   - Must be public or accessible to instructor
   - All code committed and pushed

2. **Live Application URL**
   - EC2 public IP or domain
   - Application must be running

3. **Documentation**
   - Complete README in repository
   - Any additional notes or learnings

4. **Demo Video** (Optional but recommended)
   - 5-10 minute walkthrough
   - Show PR → test → merge → deploy
   - Demonstrate live application

### Submission Deadline:
**[To be announced by instructor]**

---

## 🤝 Getting Help

### Resources:
- **Office Hours:** [Schedule TBD]
- **Discussion Forum:** [Platform TBD]
- **Slack Channel:** #mini-project-help

### Before Asking for Help:
1. Check the troubleshooting section
2. Search error messages online
3. Review relevant documentation
4. Try to solve for 15-30 minutes

### When Asking for Help:
- Describe what you're trying to do
- Share the error message
- Explain what you've already tried
- Provide relevant code snippets

---

## 🎉 Ready to Start?

This is your chance to bring together everything you've learned and build something real. Take it step by step, don't rush, and enjoy the process of building a complete DevOps pipeline from scratch!

**Good luck, and happy coding! 🚀**

---

*Last updated: December 20, 2025*
