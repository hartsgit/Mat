Install-Module -Name Az.DesktopVirtualization
Connect-AzAccount
Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription

$resourceGroupName = "RG-ROZ-COCONUTBEACH-COCKTAIL"
$location = "southeastasia"
$parameters = @{
        ResourceGroup = $resourceGroupName
        Location = $location
}
New-AzResourceGroup @parameters


$hostpoolParameters = @{
    Name = "CoconutBeach-Hostpool"
    Description = "A nice coconut on a sunny beach"
    ResourceGroupName = $resourceGroupName
    Location = $location
    HostpoolType = "Pooled"
    LoadBalancerType = "BreadthFirst"
    preferredAppGroupType = "Desktop"
    ValidationEnvironment = $False
    StartVMOnConnect = $true
}
$avdHostpool = New-AzWvdHostPool @hostpoolParameters

$applicationGroupParameters = @{
    ResourceGroupName = $ResourceGroupName
    Name = "CoconutBeachApplications"
    Location = $location
    FriendlyName = "Applications on the beach"
    Description = "From the CoconutBeach-deployment"
    HostPoolArmPath =  $avdHostpool.Id
    ApplicationGroupType = "Desktop"
}
$applicationGroup = New-AzWvdApplicationGroup @applicationGroupParameters


$workSpaceParameters = @{
    ResourceGroupName = $ResourceGroupName
    Name = "Party-Workspace"
    Location = $location
    FriendlyName = "The party workspace"
    ApplicationGroupReference = $applicationGroup.Id
    Description = "This is the place to party"
}
$workSpace = New-AzWvdWorkspace @workSpaceParameters




$keyVaultParameters = @{
    Name = "CoconutKeyVault"
    ResourceGroupName = $resourceGroupName
    Location = $location
}
$keyVault = New-AzKeyVault @keyVaultParameters

$secretString = "V3ryS3cretP4sswOrd!"
$secretParameters = @{
    VaultName = $keyVault.VaultName
    Name= "vmjoinerPassword"
    SecretValue = ConvertTo-SecureString -String $secretString -AsPlainText -Force
}
$secret = Set-AzKeyVaultSecret @secretParameters




$sessionHostCount = 1
$initialNumber = 1
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = "Password"
$avdPrefix = "avd-"
$VMSize = "Standard_D2s_v3"
$DiskSizeGB = 256
$domainUser = "@gel.local"
$domain = gel.local
$ouPath = "OU=Computers,OU=AVD,DC=domain,DC=local"

$registrationToken = Update-AvdRegistrationToken -HostpoolName $avdHostpool.name $resourceGroupName
$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"




Do {
    $VMName = $avdPrefix+"$initialNumber"
    $ComputerName = $VMName
    $nicName = "nic-$vmName"
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId ($virtualNetwork.Subnets | Where { $_.Name -eq "avdSubnet" }).Id
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -Id $imageVersion.id

    $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

    $initialNumber++
    $sessionHostCount--
    Write-Output "$VMName deployed"
}
while ($sessionHostCount -ne 0) {
    Write-Verbose "Session hosts are created"