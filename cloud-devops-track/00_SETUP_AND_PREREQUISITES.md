# Think Polaris Cloud & DevOps Engineer 30-Day Mastery Track
## Module 00: Workstation Setup, Toolchain Installation & The Zero-Dollar Shield

> **Objective**: Prepare your local development environment with all required cloud and DevOps utilities, and implement strict AWS billing guardrails to guarantee 100% zero out-of-pocket costs.

---

## 1. System Requirements & Architecture Selection

Students have two supported execution paths:

| Requirement | Path A: Local Laptop (WSL2) | Path B: PowerEdge Lab Server VM |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 (Build 19041+) or Windows 11 | Proxmox VE Ubuntu 22.04 Cloud VM |
| **Processor & Virtualization** | Intel Core i5/Ryzen 5 (VT-x/AMD-V enabled in BIOS) | Dual Xeon Platinum 8163 compute pool |
| **Memory (RAM)** | 8 GB minimum (16 GB recommended) | 4 GB allocated per student VM |
| **Free Disk Space** | 40 GB free SSD storage | 30 GB ZFS SCSI storage pool |
| **Primary Terminal** | Windows Terminal + Ubuntu 22.04 LTS (WSL2) | OpenSSH / VS Code Remote-SSH |

---

## 2. Path A: Windows Subsystem for Linux (WSL2) Setup

### Step 1: Enable WSL2 & Install Ubuntu 22.04 LTS
Open **PowerShell as Administrator** on your Windows laptop and execute:

```powershell
# Enable WSL and install Ubuntu 22.04 LTS
wsl --install -d Ubuntu-22.04

# Verify WSL version is 2
wsl -l -v
```

*Reboot your laptop when prompted by Windows. Upon reboot, launch Ubuntu from the Start Menu, create your Unix username (e.g. `polaris`) and set a secure password.*

---

### Step 2: Install Essential Windows Utilities
Download and install the following native tools on Windows:
1. **Windows Terminal**: Install from the Microsoft Store or via winget:
   ```powershell
   winget install Microsoft.WindowsTerminal
   ```
2. **Visual Studio Code**:
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```
3. **VS Code Extensions**: Open VS Code, press `Ctrl+Shift+X`, and install:
   - `ms-vscode-remote.remote-wsl` (WSL extension for editing code directly inside Ubuntu)
   - `hashicorp.terraform` (Syntax highlighting and auto-completion for HCL)
   - `ms-azuretools.vscode-docker` (Docker management interface)
   - `ms-kubernetes-tools.vscode-kubernetes-tools` (Kubernetes manifests and pod views)
   - `redhat.vscode-yaml` (YAML schema validation)

---

### Step 3: Configure Ubuntu 22.04 Inside WSL2
Launch your **Ubuntu 22.04** terminal and run the following command block to update packages and install core CLI tools:

```bash
# 1. Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# 2. Install core networking and system utilities
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    tree \
    dnsutils \
    net-tools \
    traceroute \
    tcpdump \
    htop \
    software-properties-common \
    gnupg \
    apt-transport-https \
    ca-certificates

# 3. Configure Git Global Identity
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf input
```

---

### Step 4: Install Cloud & DevOps Toolchain Inside WSL2

Execute the following commands sequentially inside your Ubuntu terminal:

#### 1. AWS CLI Version 2 (Official 64-bit Linux Binary)
```bash
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x Linux/...
```

#### 2. HashiCorp Terraform
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform -version
# Expected: Terraform v1.x.x
```

#### 3. Docker Engine (Inside WSL2 without bloated VM overhead)
```bash
# Set up Docker official repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable docker group for non-root execution
sudo usermod -aG docker $USER
sudo service docker start
```
*(Alternatively, install **Docker Desktop for Windows** and enable the "Use WSL 2 based engine" checkbox in Settings).*

#### 4. Kubernetes CLI (`kubectl`) & Local Cluster Engine (`kind` / `k3d`)
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client

# Install kind (Kubernetes in Docker)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version
```

---

## 3. Path B: Proxmox Lab Server VM (Classroom Setup)

For classroom sessions at the Think Polaris Technical Center in Alwaye:
1. Connect your laptop to the lab Wi-Fi or Ethernet network (`10.10.10.0/24` on internal bridge `vmbr1`).
2. Obtain your pre-provisioned VM IP (e.g. `10.10.10.101` for Student 01) from the instructor.
3. Connect directly from PowerShell or Windows Terminal:
   ```powershell
   ssh polaris@10.10.10.101
   ```
4. Connect via **VS Code**: Press `F1` → `Remote-SSH: Connect to Host...` → enter `polaris@10.10.10.101`.

---

## 4. The Zero-Dollar Shield: AWS Free Tier & Billing Guardrails

> [!CAUTION]
> **Cloud Provider Billing Rule**: Public cloud providers (AWS, Azure, GCP) bill for provisioned capacity by the second. An unmonitored NAT Gateway or multi-node Kubernetes cluster running continuously for 30 days can generate a **\$120–\$200 charge**. Follow the steps below immediately after creating your AWS account.

### Step 1: Create AWS Account
1. Visit [https://aws.amazon.com/free/](https://aws.amazon.com/free/) and register a free 12-month tier account.
2. Complete identity and payment card verification (a temporary \$1 authorization charge is made and immediately refunded).

---

### Step 2: Lock Down Root & Provision Dedicated IAM Admin
**Never use the AWS Root Account for daily labs or Terraform commands.**

1. Log into the AWS Management Console as **Root**.
2. Navigate to **IAM (Identity and Access Management)**.
3. Under **Security recommendations**, click **Add MFA** to enable an authenticator app (Google Authenticator, Microsoft Authenticator) on your smartphone for the root account.
4. Click **Users** → **Create user**:
   - Username: `polaris-cloud-admin`
   - Select: **Provide user access to the AWS Management Console**
   - Console password: Set custom password
   - Permissions: Attach policies directly → Select **`AdministratorAccess`**
5. Create user, then log out of Root.
6. Log into the AWS Console using your new `polaris-cloud-admin` credentials.

---

### Step 3: Create AWS Access Keys for Local CLI & Terraform
1. Under `polaris-cloud-admin`, click **Security credentials** tab.
2. Scroll to **Access keys** → **Create access key**.
3. Select **Command Line Interface (CLI)**, check the confirmation box, and click **Next**.
4. Download or securely record the **Access Key ID** and **Secret Access Key**.
5. In your Ubuntu/WSL terminal, configure the AWS CLI:
   ```bash
   aws configure
   ```
   Provide the following parameters:
   - **AWS Access Key ID**: `AKIAIOSFODNN7EXAMPLE` (Your Access Key)
   - **AWS Secret Access Key**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` (Your Secret Key)
   - **Default region name**: `us-east-1` (US East N. Virginia has the highest free tier availability)
   - **Default output format**: `json`

6. Verify authentication:
   ```bash
   aws sts get-caller-identity
   ```
   *Expected output: JSON showing your Account ID and `polaris-cloud-admin` ARN.*

---

### Step 4: Configure CloudWatch $1.00 & $5.00 Billing Alarms
1. In the AWS Console search bar, type **Billing and Cost Management**.
2. Under **Billing preferences**, check **Receive CloudWatch Billing Alerts** and **Receive Free Tier Usage Alerts** → click **Save preferences**.
3. Navigate to **CloudWatch** service → click **Alarms** in the left menu → **All alarms** → **Create alarm**.
4. Click **Select metric** → **Billing** → **Total Estimated Charge** → select **USD** currency.
5. Configure threshold:
   - Statistic: **Maximum**
   - Period: **6 hours**
   - Threshold type: **Static**
   - Whenever `EstimatedCharges` is **Greater than `1.00` USD**
6. Configure action:
   - Alarm state trigger: **In alarm**
   - Create a new SNS topic: `polaris-billing-alarm-topic`
   - Enter your personal email address.
   - Click **Create topic** (Check your inbox and click **Confirm subscription** in the AWS confirmation email).
7. Alarm name: `AWS-Billing-Alert-1USD`. Click **Create alarm**.
8. Repeat the process to create a second alarm for **`5.00` USD** named `AWS-Billing-Emergency-5USD`.

---

### Step 5: Configure AWS Budgets ($5.00 Hard Stop Notice)
1. In the AWS Console, search for **AWS Budgets**.
2. Click **Create budget** → select **Cost budget (Recommended)**.
3. Budget name: `Polaris-Intern-Monthly-Budget`.
4. Period: **Monthly** | Budgeted amount: **$5.00 USD**.
5. Set alert thresholds:
   - Alert 1: **50% of budgeted amount ($2.50)** → Enter student email.
   - Alert 2: **80% of budgeted amount ($4.00)** → Enter student email.
   - Alert 3: **100% of budgeted amount ($5.00)** → Enter student email.
6. Click **Confirm budget**.

---

### Step 6: The Free-Tier Golden Rules (Strictly Enforced)

| Forbidden Action (High-Cost Trap) | Required Practice |
| :--- | :--- |
| **Do NOT provision AWS NAT Gateways** | Use dual public subnets or free `t2.micro` NAT instances. |
| **Do NOT leave EKS clusters running** | Run Kubernetes on local `kind`/`k3s`; only provision ephemeral test clusters. |
| **Do NOT keep unattached Elastic IPs** | AWS charges \$0.005/hr for unassociated public IPs. Release them immediately. |
| **Do NOT choose non-free-tier instance sizes** | Always use `t2.micro` (or `t3.micro` where eligible). |
| **Do NOT leave lab resources running overnight** | Always run `terraform destroy` or terminate EC2 instances after class. |

---

## 5. Automated Environment Verification

To verify that your workstation is 100% ready for Day 1, run our automated verification script:

```bash
# Navigate to the Day 1 lab folder
cd ~/optimistic-meitner/cloud-devops-track/labs/day-01-linux-foundations/

# Make the verification script executable and run it
chmod +x verify_environment.sh
./verify_environment.sh
```

If all indicators show green `[PASS]`, your workstation is fully verified and ready for Day 1.
