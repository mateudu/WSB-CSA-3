SET STUDENT_ID = "@@@@@"

## Azure Account
SET StudentId=xxxxx
SET LocationName=westeurope
SET ResourceGroupName=lab11-rg-cli
az group create -n %ResourceGroupName% -l %LocationName%

## VM Account
SET VMLocalAdminUser=LocalAdminUser
SET VMLocalAdminPassword=Passw00rd!Passw00rd!

## VM
SET VMSize=Standard_B2ms
SET VMName=vm%StudentId%cli
SET VMOsDiskName=%VMName%-disk-os

## Networking
SET NetworkName=lab11-vnet-cli
SET NICName=%VMName%-nic-01
SET PublicIPAddressName=%VMName%-nic-01-pip
SET SubnetName=subnet01
SET SubnetAddressPrefix=10.0.0.0/24
SET VnetAddressPrefix=10.0.0.0/16

az network vnet create ^
    -g %ResourceGroupName% ^
    -n %NetworkName% ^
    --address-prefix %VnetAddressPrefix% ^
    --subnet-name %SubnetName% ^
    --subnet-prefix %VnetAddressPrefix%

az network public-ip create ^
    -g %ResourceGroupName% ^
    -n %PublicIPAddressName% ^
    --allocation-method Dynamic

az network nic create ^
    -g %ResourceGroupName% ^
    -n %NICName% ^
    --vnet-name %NetworkName% ^
    --subnet %SubnetName% ^
    --public-ip-address %PublicIPAddressName%

az vm create ^
    -g %ResourceGroupName% ^
    -n %VMName% ^
    --computer-name %VMName% ^
    --enable-agent true ^
    --enable-auto-update true ^
    --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest ^
    --admin-username %VMLocalAdminUser% ^
    --admin-password %VMLocalAdminPassword% ^
    --nics %NICName% ^
    --os-disk-name %VMOsDiskName% ^
    --os-disk-size-gb 256 ^
    --size %VMSize%

## Operations
az vm get-instance-view -n %VMName% -g %ResourceGroupName%
az vm stop -n %VMName% -g %ResourceGroupName%
az vm deallocate -n %VMName% -g %ResourceGroupName%
az vm start -n %VMName% -g %ResourceGroupName%