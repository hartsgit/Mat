Connect-AzAccount
Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription
#Create Storage account and fileshare for FSLogix
$ResourceGroupName = "rg-p-tel-avd01"
$storageaccountname = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sapavdtelfslgx -Location australiaeast -SkuName Premium_LRS -Kind FileStorage
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccountname.ResourceGroupName -Name $storageAccountname.StorageAccountName | select -first 1).Value
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountname.StorageAccountName -StorageAccountKey $storageKey
$Fileshare = New-AzStorageShare -Name fslogix -Context $storageContext

        #Give access to the fileshare
#Gather required information for Fileshare Access
Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription
Get-AzADGroup -SearchString "Telnet"
#Get the name of the custom role
$FileShareContributorRole = Get-AzRoleDefinition "Storage File Data SMB Share Contributor" 
#Constrain the scope to the target file share
$scope = "/subscriptions/9e19dd2c-ea16-454e-a51a-5195bae6cadb/resourceGroups/rg-p-tel-avd01/providers/Microsoft.Storage/storageAccounts/sapavdtelfslgx/fileServices/default/fileshares/fslogix"
#Assign the custom role to the target identity with the specified scope.
New-AzRoleAssignment -ObjectId 75a86ccc-1222-441a-ac8e-c473a075aae9 -RoleDefinitionName $FileShareContributorRole.Name -Scope $scope

#----------------------------------------------------------------------------------------------------------------------------------
# Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Download and extract AzFilesHybrid 
$Url = 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.4/AzFilesHybrid.zip'
Invoke-WebRequest -Uri $Url -OutFile "C:\Temp\AzFilesHybrid.zip"
Md C:\Temp\AZFilesHybrid\

Expand-Archive -Path C:\Temp\AZFilesHybrid.zip -DestinationPath C:\Temp\

#CD C:\Temp in Powershell window

cd -Path C:\temp\AZFilesHybrid -PassThru
.\CopyToPSPath.ps1

# Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

# Login with an Azure AD credential that has either storage account owner or contributer Azure role assignment
# If you are logging into an Azure environment other than Public (ex. AzureUSGovernment) you will need to specify that.
# See https://docs.microsoft.com/azure/azure-government/documentation-government-get-started-connect-with-ps
# for more information.
Install-Module -Name Az -AllowClobber
Connect-AzAccount

#Find your subscription
$SubscriptionId = Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription
$storageaccountname = "sapavdtelfslgx"
$ResourceGroupName = "rg-p-tel-avd01"
# Define parameters, $StorageAccountName currently has a maximum limit of 15 characters
$DomainAccountType = "ServiceLogonAccount" # Default is set as ComputerAccount
# If you don't provide the OU name as an input parameter, the AD identity that represents the storage account is created under the root directory.
$OuDistinguishedName = "OU=ServiceAccounts,OU=TEL,OU=Production,OU=MHIS,DC=gel,DC=local"
# Specify the encryption agorithm used for Kerberos authentication. Default is configured as "'RC4','AES256'" which supports both 'RC4' and 'AES256' encryption.
$EncryptionType = "AES256,RC4"

# Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM"). 
# You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
# You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference. 
# Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.

Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName `
        -EncryptionType $EncryptionType



$storageKey
$storageContext

#To be done in CMD as Admin - Edits rights to allow users to create fslogix folders and not see others

#net use T: \\sapavdtelfslgx.file.core.windows.net\fslogix jpo0AjpYLT2yJDjDBGItkXyzf1GdKUt6P5lsy/nDwJyBus4ZUmSQXHaAs6oF3jgiuaGZJ8tBMVn0ZJy5Gg4M3w== /user:Azure\sapavdtelfslgx

#
#icacls S:
#icacls S: /grant "adm_mathew.hartendorp@z.co.nz":(M)
#icacls S: /grant "Creator Owner":(OI)(CI)(IO)(M)
#icacls S: /remove "Authenticated Users"
#icacls S: /remove "Builtin\Users


