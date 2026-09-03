# 02_create_sample_users.ps1
# Creates enterprise demo users and intern accounts in Think Polaris Active Directory

Import-Module ActiveDirectory

$domainDN = (Get-ADDomain).DistinguishedName
$topOU = "OU=ThinkPolaris,$domainDN"
$pwd = ConvertTo-SecureString "PolarisPass@2026!" -AsPlainText -Force

# Create Sample Department Users
$users = @(
    @{First="John"; Last="Doe"; User="jdoe"; Dept="Information Technology"; Group="SG-IT-Admins"; Title="Lead Systems Administrator"},
    @{First="Sarah"; Last="Connor"; User="sconnor"; Dept="Finance"; Group="SG-Finance-Staff"; Title="Senior Financial Analyst"},
    @{First="Alex"; Last="Mercer"; User="amercer"; Dept="Human Resources"; Group="SG-HR-Staff"; Title="HR Coordinator"},
    @{First="Intern"; Last="One"; User="intern01"; Dept="Interns"; Group="SG-Interns"; Title="IT Support Intern"}
)

foreach ($u in $users) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.User)'" -ErrorAction SilentlyContinue)) {
        if ($u.Dept -eq "Interns") {
            $ouPath = "OU=Interns,$topOU"
        } else {
            $ouPath = "OU=$($u.Dept),OU=Departments,$topOU"
        }
        
        New-ADUser -Name "$($u.First) $($u.Last)" `
                   -GivenName $u.First `
                   -Surname $u.Last `
                   -SamAccountName $u.User `
                   -UserPrincipalName "$($u.User)@thinkpolaris.local" `
                   -Path $ouPath `
                   -AccountPassword $pwd `
                   -Enabled $true `
                   -Title $u.Title `
                   -Department $u.Dept `
                   -ChangePasswordAtLogon $false

        Add-ADGroupMember -Identity $u.Group -Members $u.User
        Write-Host "Created User: $($u.User) in $ouPath (Group: $($u.Group))" -ForegroundColor Green
    }
}
