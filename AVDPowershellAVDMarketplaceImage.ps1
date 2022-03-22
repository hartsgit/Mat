$keyVaultParameters = @{
    Name = "AVDKeyVault"
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


#$virtualNetwork = need to work best way out for this

$sessionHostCount = 1
$initialNumber = 1
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name ) -AsPlainText -Force
$avdPrefix = "VMPTELAPP01"
$VMSize = "Standard_D2s_v3"
$DiskSizeGB = 256
$domainUser = "adm_mathew.hartendorp@z.co.nz"
$domain = gel.local
$ouPath = "OU=Computers,OU=AVD,DC=domain,DC=local"

$registrationToken = Update-AvdRegistrationToken -HostpoolName $avdHostpool.name $resourceGroupName


#need to test
#Get-AzVmImageSku -Location '$location' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' 
#Get-AzVmImageSku -Location '$location' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' | Out-GridView -PassThru | Select-ImageSku
#Get-AzVmImageSku -Location '$location' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' | Out-GridView -PassThru | Select-ImageOffer
#Get-AzVmImageSku -Location '$location' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' | Out-GridView -PassThru | Select-ImagePublisher


Do {
    $VMName = $avdPrefix+"$initialNumber"
    $ComputerName = $VMName
    $nicName = "nic-$vmName"
    location = $location
$VMSize = "Standard_D2s_v3"
$ImageSku = ""
$ImageOffer = ""
$ImagePublisher = ""
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId ($virtualNetwork.Subnets | Where { $_.Name -eq "avdSubnet" }).Id
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $ImagePublisher -Offer $ImageOffer -Skus $ImageSku -Version latest


    $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

    $initialNumber++
    $sessionHostCount--
    Write-Output "$VMName deployed"
}
while ($sessionHostCount -ne 0) {
    Write-Verbose "Session hosts are created"

            $domainJoinSettings = @{
        Name                   = "joindomain"
        Type                   = "JsonADDomainExtension" 
        Publisher              = "Microsoft.Compute"
        typeHandlerVersion     = "1.3"
        SettingString          = '{
            "name": "'+ $($domain) + '",
            "ouPath": "'+ $($ouPath) + '",
            "user": "'+ $($domainUser) + '",
            "restart": "'+ $true + '",
            "options": 3
        }'
        ProtectedSettingString = '{
            "password":"' + $(Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name $secret.Name -AsPlainText) + '"}'
        VMName                 = $VMName
        ResourceGroupName      = $resourceGroupName
        location               = $Location
    }
    Set-AzVMExtension @domainJoinSettings

    $avdDscSettings = @{
        Name               = "Microsoft.PowerShell.DSC"
        Type               = "DSC" 
        Publisher          = "Microsoft.Powershell"
        typeHandlerVersion = "2.73"
        SettingString      = "{
            ""modulesUrl"":'$avdModuleLocation',
            ""ConfigurationFunction"":""Configuration.ps1\\AddSessionHost"",
            ""Properties"": {
                ""hostPoolName"": ""$($fileParameters.avdSettings.avdHostpool.Name)"",
                ""registrationInfoToken"": ""$($registrationToken.token)"",
                ""aadJoin"": false
            }
        }"
        VMName             = $VMName
        ResourceGroupName  = $resourceGroupName
        location           = $Location
    }
    Set-AzVMExtension @avdDscSettings   