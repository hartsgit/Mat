Install-Module -Name Az.DesktopVirtualization
Connect-AzAccount
Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription

$resourceGroupName = "rg-p-tel-avd01"
$location = "australiaeast"
$parameters = @{
        ResourceGroup = $resourceGroupName
        Location = $location
                }
New-AzResourceGroup @parameters -Tag @{"Product Name"="TEL";"Environment"="Prod";"Cost Center"="1030150.83013";"Product Owner"="NTT";"Contact"="Mathew.hartendorp@global.ntt"}

$location = "WestUS"
$hostpoolParameters = @{
    Name = "hppavdtel01"
    Description = "Telnet Production AVD"
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
    Name = "vdagpavdtel01"
    Location = $location
    FriendlyName = "Telnet Application Group"
    Description = "Telnet Application Group"
    HostPoolArmPath =  $avdHostpool.Id
    ApplicationGroupType = "RemoteApp"
}
$applicationGroup = New-AzWvdApplicationGroup @applicationGroupParameters


$workSpaceParameters = @{
    ResourceGroupName = $ResourceGroupName
    Name = "wspavdtel01"
    Location = $location
    FriendlyName = "Telnet Workspace"
    ApplicationGroupReference = $applicationGroup.Id
    Description = "Telnet Workspace"
}
$workSpace = New-AzWvdWorkspace @workSpaceParameters


New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "campsite" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 0 -CommandLineSetting "Require" -CommandLineArgument "https://apply.z.co.nz/camp/applications" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "Declined Transactions" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 1 -CommandLineSetting "Require" -CommandLineArgument "https://cardonline.co.nz/" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "JDE 9.2 IA" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 2 -CommandLineSetting "Require" -CommandLineArgument "http://swlgljdet01:8083/jde/E1Menu.maf" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "JDE 9.2 Production" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 3 -CommandLineSetting "Require" -CommandLineArgument "https://swlgljdep01.gel.local:8091/jde/E1Menu.maf" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "User Acceptance QA - Training TR" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 4 -CommandLineSetting "Require" -CommandLineArgument "http://swlgljdet01.gel.local:8084/jde/E1Menu.maf" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "V3 Ajax" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 5 -CommandLineSetting "Require" -CommandLineArgument "https://zenergy-ifcs-ajaxswing.prod.emea.wexinc.co.uk/ajaxswing/apps/swingclient" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "Z App" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 6 -CommandLineSetting "Require" -CommandLineArgument "https://zapp.z.co.nz/admin/security" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "Z Energy Intranet" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 7 -CommandLineSetting "Require" -CommandLineArgument "http://matters.gel.local/pages/home.aspx" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "Infinity Cloud" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 8 -CommandLineSetting "Require" -CommandLineArgument "https://swlgwrdsp05.gel.local/CloudHub/Account/Logon" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name "MiniTankersDocumentViewer" -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\DocumentViewer\MiniTankersDocumentViewer.External.exe" -IconPath "C:\DocumentViewer\MiniTankersDocumentViewer.External.exe" -IconIndex 9 -CommandLineSetting "DoNotAllow" -ShowInPortal:$true
New-AzWvdApplication -GroupName "vdagpavdtel01" -Name WordPad -ResourceGroupName "rg-p-tel-avd01" -Filepath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -IconPath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -IconIndex 10 -CommandLineSetting "DoNotAllow" -ShowInPortal:$true


New-AzRoleAssignment -groupName "telnet users" -RoleDefinitionName "Desktop Virtualization User" -ResourceName vdagpavdtel01 -ResourceGroupName $ResourceGroupName -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups'

#Access to Application Group
Get-AzADGroup -SearchString "Telnet" 
New-AzRoleAssignment -ObjectId 75a86ccc-1222-441a-ac8e-c473a075aae9 -RoleDefinitionName "Desktop Virtualization User" -ResourceName vdagpavdtel01 -ResourceGroupName $ResourceGroupName -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups'

Register-AzWvdApplicationGroup -ResourceGroupName rg-p-tel-avd01 `
                                    -WorkspaceName wspavdtel01 `
                                    -ApplicationGroupPath '/subscriptions/9e19dd2c-ea16-454e-a51a-5195bae6cadb/resourceGroups/rg-p-tel-avd01/providers/Microsoft.DesktopVirtualization/applicationGroups/vdagpavdtel01'
