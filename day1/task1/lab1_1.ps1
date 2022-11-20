## Azure Account
$StudentId = "@@@@@@@@" ## TODO: Update this value
$LocationName = "westeurope"
$ResourceGroupName = "lab11-rg-ps"
New-AzResourceGroup -Name $ResourceGroupName -Location $LocationName -Force

## VM Account
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "Passw00rd!Passw00rd!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

## VM
$VMSize = "Standard_B2ms"
$VMName = "vm$($StudentId)ps"
$VMOsDiskName = "$($VMName)-disk-os"
$VMOsDiskSize = 256

## Networking
$NetworkName = "lab11-vnet-ps"
$NICName = "$($VMName)-nic-01"
$PublicIPAddressName = "$($VMName)-nic-01-pip"
$SubnetName = "subnet01"
$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

## VM
$VirtualMachineConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachineConfig = Set-AzVMOperatingSystem -VM $VirtualMachineConfig `
    -Windows `
    -ComputerName $VMName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate
$VirtualMachineConfig = Add-AzVMNetworkInterface -VM $VirtualMachineConfig `
    -Id $NIC.Id
$VirtualMachineConfig = Set-AzVMSourceImage -VM $VirtualMachineConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2019-Datacenter" `
    -Version "latest"
$VirtualMachineConfig = Set-AzVMOSDisk -VM $VirtualMachineConfig `
    -Name $VMOsDiskName `
    -DiskSizeInGB $VMOsDiskSize `
    -CreateOption "FromImage"
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachineConfig -Verbose

## Operations
Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Status
Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force
Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force