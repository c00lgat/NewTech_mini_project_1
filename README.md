Project Overview: https://vimeo.com/1152552572?share=copy&fl=cl&fe=ci

### Provisioning the AWS Infrastructure (Terraform)

To provision the AWS environment shown in the diagram:
- Clone the repository
- Navigate into the Terraform directory:
  ```bash
  cd terraform
  ```
  
  Run a Terraform plan:
  ```bash
  terraform plan -var-file="dev.tfvars" #to launch the dev environment
  terraform plan -var-file="prod.tfvars" #to launch the prod environment
  ```
During the plan/apply stage, Terraform may prompt you for input variables if a tfvars file was not selected. Such as:

project → Project name (used for naming/tagging resources)

environment → Environment name (e.g. dev / prod)

instance_type → EC2 instance type to launch (e.g. t3.micro)

asg_max_size → Maximum number of EC2 instances the ASG can scale up to

asg_min_size → Minimum number of EC2 instances the ASG must keep running

asg_desired_capacity → Default number of EC2 instances the ASG should launch initially


  



## Architecture

This project provisions a highly-available AWS deployment in `us-east-1` using Terraform modules.

![Architecture diagram](docs/aws_architecture.svg)

**Networking**
- VPC: `10.0.0.0/16`
- Two public subnets across two AZs:
  - `us-east-1a`: `10.0.1.0/24`
  - `us-east-1b`: `10.0.2.0/24`
- Internet Gateway + public route table for internet connectivity

**Compute & Scaling**
- An Auto Scaling Group (ASG) manages EC2 instances.
- Instances are created using an EC2 Launch Template to ensure consistent configuration.

**Load Balancing**
- An Application Load Balancer (ALB) provides a stable DNS endpoint for end users.
- The ALB forwards traffic to the ASG instances (app listens on port `5000`) and performs health checks via `/health`.

**Security**
- Security groups separate public ingress (ALB) from application ingress (EC2).
- EC2 instances accept app traffic only from the ALB security group.


## CI Workflow 1: Test on Pull Request (`Test_on_Pull_Request`)

This workflow is responsible for validating the application code **before it gets merged into `main`**.
It runs automatically on every Pull Request that modifies files under `app/**`, and can also be triggered manually.

### Trigger Conditions
- ✅ Runs on **Pull Requests** when changes are made in:
  - `app/**`
- ✅ Can also be triggered manually using:
  - `workflow_dispatch`

### What the workflow does
The workflow runs a single job (`first-job`) on an Ubuntu runner and executes the following steps:

- **Checkout Repository**
  - Pulls the repository content into the GitHub runner
  - This allows the runner to access the source code and tests

- **Set up Python 3.11**
  - Installs and configures Python `3.11` on the runner environment
  - Ensures the workflow uses the same Python version expected by the project

- **Install Dependencies**
  - Installs the Python requirements from `app/requirements.txt`
  - Uses `pip` to prepare the environment for linting and testing

- **Linting (flake8)**
  - Runs `flake8` against the main application modules:
    - `main.py`
    - `business_logic.py`
  - Focuses on catching **syntax errors and common code quality issues**
  - Enabled lint checks:
    - `E` (PEP8 formatting-related checks)
    - `F` (flake8/pyflakes checks)
  - Ignores:
    - `E128`

- **Security Scan (bandit)**
  - Uses `bandit` to detect common Python security risks
  - Enforces scanning at:
    - `--severity-level high`
  - Scans:
    - `main.py`
    - `business_logic.py`

- **Run Tests (pytest)**
  - Executes the full test suite under:
    - `app/tests/`
  - Ensures API + logic tests are working correctly

- **Code Coverage Enforcement**
  - Generates a coverage report in JSON format
  - Enforces a minimum coverage threshold:
    - ✅ must be **≥ 80%**
  - If coverage is below 80%, the workflow fails (blocking merge)

### Why this workflow matters
This CI pipeline ensures that:
- ✅ every PR is validated before merging
- ✅ code follows consistent style and avoids obvious errors
- ✅ security risks are detected early
- ✅ tests must pass before deployment is possible
- ✅ coverage standards are enforced for reliability and maintainability


## CI/CD Workflow 2: Deploy on Push (`Deploy_on_push`)

This workflow is responsible for **building, scanning, publishing, and deploying** the application whenever new code is pushed.

It follows a full CI/CD pipeline structure:

✅ **Test the code → Build container → Scan image → Push to registry → Deploy to EC2**

---

### Trigger Conditions
- ✅ Runs on every **push** that modifies files under:
  - `app/**`
- ✅ Can also be triggered manually using:
  - `workflow_dispatch`

---

## Workflow Breakdown (3 Jobs)

### Job 1 — Application Validation (`first-job`)
This job runs the same quality gates as the Pull Request workflow, ensuring code quality and correctness before building the image.

Steps performed:

- **Checkout Repository**
  - Pulls source code into the runner environment

- **Set up Python 3.11**
  - Ensures the pipeline uses the same runtime version as the app

- **Install Dependencies**
  - Installs Python dependencies from `requirements.txt`

- **Linting (flake8)**
  - Checks syntax and code style problems in:
    - `main.py`
    - `business_logic.py`

- **Security Scan (bandit)**
  - Scans Python code for high-severity security issues

- **Run Unit + Integration Tests (pytest)**
  - Runs tests under `tests/`

- **Coverage Report**
  - Enforces **≥ 80% code coverage**

> ⚠️ Note: In this workflow, `pytest` and coverage steps are currently using `|| true`,
> meaning failures will not stop the pipeline. In production pipelines, these would usually block deployment.

---

### Job 2 — Build, Scan, and Publish Docker Image (`second-job`)
This job runs **only after Job 1 succeeds**, and it handles Docker image creation and security scanning.

Steps performed:

- **Checkout Repository**
  - Required because the Docker build needs the source code

- **Login to Docker Hub**
  - Uses credentials stored as GitHub Secrets / Variables:
    - `DOCKERHUB_USERNAME` (variable)
    - `DOCKERHUB_TOKEN` (secret)

- **Build Image (without pushing yet)**
  - Builds the image from:
    - `./app/Dockerfile`
  - Uses:
    - `push: false`
    - `load: true`
  - Tags the image as:
    - `<username>/app:${{ github.sha }}`

✅ This design ensures the image is built locally first, allowing scanning before publishing.

- **Trivy Image Vulnerability Scan**
  - Scans the built image for known vulnerabilities
  - Fails the job if **HIGH** or **CRITICAL** vulnerabilities are found:
    - `exit-code: 1`
    - `severity: CRITICAL,HIGH`
  - Scans both:
    - OS packages
    - application libraries

- **Push Image to Docker Hub**
  - Only runs if Trivy passes
  - Pushes the image with two tags:
    - `${{ github.sha }}` → immutable deploy version
    - `latest` → convenience tag for manual pulls/testing

---

### Job 3 — Deploy to EC2 (`third-job`)
This job runs **only after the Docker image is successfully pushed**, and deploys the new version to the EC2 instance.

Steps performed:

- **SSH into the EC2 instance**
  - Uses secrets:
    - `EC2_PRIVATE_KEY`
    - `EC2_HOST`
    - `EC2_USER`

- **Update the deployment `.env` file**
  - Writes the new image tag into:
    - `/flask-app/.env`
  - This ensures Docker Compose pulls the correct version

- **Pull latest image and restart containers**
  - Runs on the EC2 instance:
    - `docker compose pull`
    - `docker compose up -d --remove-orphans`

✅ This results in:
- pulling the newly built image from Docker Hub
- recreating the container with the updated tag
- restarting the app with minimal downtime

---

## Why this workflow structure is useful
This pipeline mimics real-world DevOps best practices:

- ✅ Deployments happen only after code validation + image security scanning
- ✅ Docker images are versioned using immutable commit hashes
- ✅ "latest" is also available for convenience
- ✅ EC2 always runs the exact version built by the CI run
- ✅ Deployment is fully automated end-to-end


