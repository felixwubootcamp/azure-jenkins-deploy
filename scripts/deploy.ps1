param (
    [string]$Environment
)

$rgName = "winserver"
$location = "australiaeast"
$vmName = "vm-$Environment"
$storageName = "stg$Environment" + (Get-Random -Maximum 9999)
$nsgName = "nsg-$Environment"
$vnetName = "vnet-$Environment"
$subnetName = "subnet-$Environment"
$ipName = "ip-$Environment"
$nicName = "nic-$Environment"

Write-Output "Logging in to Azure..."

$securePassword = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($env:AZURE_CLIENT_ID, $securePassword)

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $env:AZURE_TENANT_ID

Write-Output "Azure login successful. Starting deployment..."

# Create Storage Account
New-AzStorageAccount -ResourceGroupName $rgName `
    -Name $storageName `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2

# Create NSG with RDP rule
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location
Add-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -NetworkSecurityGroup $nsg `
    -Protocol Tcp -Direction Inbound -Priority 1000 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

# Create Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet @(@{Name=$subnetName;AddressPrefix="10.0.1.0/24"})

# Attach NSG to Subnet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet `
    -Name $subnetName -AddressPrefix "10.0.1.0/24" -NetworkSecurityGroup $nsg
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Create Public IP
$pip = New-AzPublicIpAddress -Name $ipName -ResourceGroupName $rgName `
    -Location $location -AllocationMethod Dynamic

# Create NIC
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName `
    -Location $location -SubnetId $subnet.Id -PublicIpAddressId $pip.Id

# Create low-cost Windows VM
$password = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $password)

New-AzVM -ResourceGroupName $rgName -Name $vmName -Location $location `
    -VirtualNetworkName $vnetName -SubnetName $subnetName `
    -SecurityGroupName $nsgName -PublicIpAddressName $ipName `
    -Credential $cred -ImageName "Win2019Datacenter" `
    -Size "Standard_B1s" -OpenPorts 3389

Write-Output "Deployment completed."
