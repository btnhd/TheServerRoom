Mount-VHD .\VHDFile.vhdx

Copy-Item .\unattend.xml -destination D:\Windows\Panther\

Dismount-VHD .\VHDFile.vhdx

=====================================================================

#add hyper-v feature 
install-windowsfeature -name Hyper-v -includemanagementtools -restart

#verify hyper-v is installed
get-windowsfeature -name "Hyper-v"

#make a directory to store VMs
md E:\VMs 

#get name of adapter 
get-netadapter

#create virtual switch with (InterfaceAlias)
new-vmswitch -name private -netadaptername Ethernet0 -allowmanagementos $true

#create a VM 
new-vm -name vDC `
	   -path E:\ `
	   -newvhdpath E:\VMs\vDC\DC_OS.vhdx `
	   -newvhdsizebytes 60GB `
	   -generation 1 `
	   -memorystartupbytes 4GB `
	   -switchname Internal
	   
set-vmprocessor vDC -count 2

=====================================================================

$vSwitch = "Private"
$VHDXPath = "E:\VMs"
$DCVMName = "vDC"
$FSVMName = "vFileShare"

#Create DC VM
Write-Verbose "Copying Master VHDX and Deploying new VM with name [$DCVMName]" -Verbose 
Copy-Item "$VHDXPath\MASTER.vhdx" "$VHDXPath\$DCVMNAME.vhdx"
Write-Verbose "VHDX Copied, Building VM...." -Verbose
New-VM -Name $DCVMName -MemoryStartupBytes 8GB -VHDPath "$VHDXPath\$DCVMName.vhdx" -Generation 1 -SwitchName $vSwitch
set-vmprocessor $DCVMName -count 2
Write-Verbose "VM Creation Completed. Starting VM [$DCVMName]" -Verbose
Start-VM -Name $DCVMName

#Create Fileshare VM 
Write-Verbose "Copying Master VHDX and Deploying new VM with name [$FSVMName]" -Verbose 
Copy-Item "$VHDXPath\MASTER.vhdx" "$VHDXPath\$FSVMNAME.vhdx"
Write-Verbose "VHDX Copied, Building VM...." -Verbose
New-VM -Name $FSVMName -MemoryStartupBytes 8GB -VHDPath "$VHDXPath\$FSVMName.vhdx" -Generation 1 -SwitchName $vSwitch
set-vmprocessor $FSVMName -count 2
Write-Verbose "VM Creation Completed. Starting VM [$FSVMName]" -Verbose
Start-VM -Name $FSVMName
	   




