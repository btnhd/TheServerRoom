#First, create a resource group. 
New-AzureRmResourceGroup -Name "BTNHD" -Location "EastUS"

#Define two virtual network subnets with New-AzureRmVirtualNetworkSubnetConfig
$mySubnetFrontEnd = New-AzureRmVirtualNetworkSubnetConfig -Name "mySubnetFrontEnd" `
    -AddressPrefix "192.168.1.0/24"
$mySubnetBackEnd = New-AzureRmVirtualNetworkSubnetConfig -Name "mySubnetBackEnd" `
    -AddressPrefix "192.168.2.0/24"
	
#Create your virtual network and subnets with New-AzureRmVirtualNetwork
$myVnet = New-AzureRmVirtualNetwork -ResourceGroupName "BTNHD" `
    -Location "EastUs" `
    -Name "myVnet" `
    -AddressPrefix "192.168.0.0/16" `
    -Subnet $mySubnetFrontEnd,$mySubnetBackEnd
	
#Create two NICs with New-AzureRmNetworkInterface
$frontEnd = $myVnet.Subnets|?{$_.Name -eq 'mySubnetFrontEnd'}
$myNic1 = New-AzureRmNetworkInterface -ResourceGroupName "BTNHD" `
    -Name "myNic1" `
    -Location "EastUs" `
    -SubnetId $frontEnd.Id

$backEnd = $myVnet.Subnets|?{$_.Name -eq 'mySubnetBackEnd'}
$myNic2 = New-AzureRmNetworkInterface -ResourceGroupName "BTNHD" `
    -Name "myNic2" `
    -Location "EastUs" `
    -SubnetId $backEnd.Id
	
#Set your VM credentials
$cred = Get-Credential

#Define your VM with New-AzureRmVMConfig
$vmConfig = New-AzureRmVMConfig -VMName "myVM" -VMSize "Standard_D1"

#Create the rest of your VM configuration with Set-AzureRmVMOperatingSystem and Set-AzureRmVMSourceImage
$vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig `
    -Windows `
    -ComputerName "myVM" `
    -Credential $cred `
    -ProvisionVMAgent `
    -EnableAutoUpdate
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2016-Datacenter" `
    -Version "latest"

#Attach the two NICs that you previously created with Add-AzureRmVMNetworkInterface:
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $myNic1.Id -Primary
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $myNic2.Id

#Finally, create your VM with New-AzureRmVM:
New-AzureRmVM -VM $vmConfig -ResourceGroupName "BTNHD" -Location "EastUs"
