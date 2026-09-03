# 01_setup_ad_structure.ps1
# Configures Think Polaris Enterprise Organizational Units, Security Groups, and DNS Forwarders

Import-Module ActiveDirectory
Import-Module DnsServer

$domainDN = (Get-ADDomain).DistinguishedName # "DC=thinkpolaris,DC=local"
Write-Host "==> Configuring Active Directory Structure for Domain: $domainDN" -ForegroundColor Cyan

# 1. Create Top-Level & Departmental OUs
$topOU = "OU=ThinkPolaris,$domainDN"
if (-not [adsi]::Exists("LDAP://$topOU")) {
    New-ADOrganizationalUnit -Name "ThinkPolaris" -Path "$domainDN" -Description "Think Polaris Corporate Root OU"
}

$subOUs = @("Departments", "Groups", "Service Accounts", "Workstations", "Servers", "Interns")
foreach ($ou in $subOUs) {
    $path = "OU=$ou,$topOU"
    if (-not [adsi]::Exists("LDAP://$path")) {
        New-ADOrganizationalUnit -Name $ou -Path "$topOU"
    }
}

$depts = @("Executive", "Finance", "Human Resources", "Information Technology", "Operations")
foreach ($dept in $depts) {
    $deptPath = "OU=$dept,OU=Departments,$topOU"
    if (-not [adsi]::Exists("LDAP://$deptPath")) {
        New-ADOrganizationalUnit -Name $dept -Path "OU=Departments,$topOU"
    }
}

# 2. Create Core Security Groups
$groups = @(
    @{Name="SG-IT-Admins"; Desc="Information Technology Administrators"},
    @{Name="SG-Finance-Staff"; Desc="Finance Department Members"},
    @{Name="SG-HR-Staff"; Desc="Human Resources Department Members"},
    @{Name="SG-Interns"; Desc="IT Internship Training Program Participants"}
)

foreach ($g in $groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$($g.Name)'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $g.Name -GroupScope Global -GroupCategory Security -Path "OU=Groups,$topOU" -Description $g.Desc
    }
}

# 3. Configure DNS Upstream Forwarders (Cloudflare & Google)
Write-Host "==> Configuring DNS Forwarders..." -ForegroundColor Cyan
Set-DnsServerForwarder -IPAddress @("1.1.1.1", "8.8.8.8") -UseRootHint $true

# 4. Create Reverse Lookup Zone for 10.10.10.0/24 Subnet
Write-Host "==> Creating Reverse Lookup Zone (10.10.10.in-addr.arpa)..." -ForegroundColor Cyan
if (-not (Get-DnsServerZone -Name "10.10.10.in-addr.arpa" -ErrorAction SilentlyContinue)) {
    Add-DnsServerPrimaryZone -NetworkId "10.10.10.0/24" -ReplicationScope Forest
}

Write-Host "`n[SUCCESS] Think Polaris Active Directory & DNS Infrastructure Configured!" -ForegroundColor Green
