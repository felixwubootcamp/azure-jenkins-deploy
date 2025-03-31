param (
    [string]$Environment
)

# Shared values
$rgName = "winserver"

# Different config based on environment
switch ($Environment.ToLower()) {
    "dev" {
        $location = "australiaeast"
        $vmSize   = "Standard_B1s"
    }
    "prod" {
        $location = "westus"
        $vmSize   = "Standard_B2s"
    }
    default {
        throw "Unknown environment: $Environment"
    }
}

# Dynamic names
$vmName      = "vm-$Environment"
$storageName = "stg$Environment" + (Get-Random -Maximum 9999)
$nsgName     = "nsg-$Environment"
$vnetName    = "vnet-$Environment"
$subnetName  = "subnet-$Environment"
$ipName      = "ip-$Environment"
$nicName     = "nic-$Environment"

Write-Output "Logging in to Azure..."

# Login
$securePassword = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
$credential     = New-Object System.Management.Automation.PSCredential($env:AZURE_CLIENT_ID, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $env:AZURE_TENANT_ID

Write-Output "Deploying '$Environment' environment to '$location' using size '$vmSize'..."

# The rest of your script continues as before...
# (create storage, NSG, VNet, subnet, IP, NIC...)

# VM credentials
$password = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $password)

# Deploy VM
New-AzVM -ResourceGroupName $rgName -Name $vmName -Location $location `
    -VirtualNetworkName $vnetName -SubnetName $subnetName `
    -SecurityGroupName $nsgName -PublicIpAddressName $ipName `
    -Credential $cred -ImageName "Win2019Datacenter" `
    -Size $vmSize -OpenPorts 3389

Write-Output "Deployment for '$Environment' completed."
