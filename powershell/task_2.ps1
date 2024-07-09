function Validate-WindowsFeatureName {
    param (
        [string]$FeatureName
    )
    
    $features = Get-WindowsFeature | Select-Object -ExpandProperty Name
    return ($features -contains $FeatureName) 
}

function Check-WindowsFeatureIfInstalled {
    param (
        [string]$FeatureName
    )
    
    return ((Get-WindowsFeature $Feature).installstate -eq "Installed")

}

function Validate-ComputerName {
    param (
        [string]$ComputerName
    )

    $regex = "^[a-zA-Z0-9\-]{1,15}$"

    return ($ComputerName -match $regex) 
}

# Prompt the user for input
$FeaturesToInstall = Read-Host "Enter the Windows Features to be installed separated by space"
$ComputerName =  Read-Host "Enter a valid computer name"
$FeaturesToInstall = $FeaturesToInstall.split(" ")

ForEach ($Feature in $FeaturesToInstall) {

    if (-not (Validate-WindowsFeatureName -FeatureName $Feature)) {
        Write-Host "$Feature is not a valid Windows Feature name, it can't be installed"
    } 
    elseif (Check-WindowsFeatureIfInstalled -FeatureName $Feature) {
        Write-Host "$Feature is already installed"
    } 
    else {
        Write-Host "$Feature is going to be installed"
        Install-WindowsFeature -Name $Feature -IncludeAllSubFeature -IncludeManagementTools -Verbose:$false > $null 2>&1
        if ($?) {
            Write-Host "$Feature has been successfully installed"
        } else {
            Write-Host "Failed to install $Feature"
        }
    }
}

if (Validate-ComputerName -ComputerName $ComputerName) {
     Write-Output "Valid computer name. The computer name will be changed to $ComputerName after restart."
     try {
     
       Rename-Computer -NewName $ComputerName -Force -PassThru
       Write-Output "Computer name successfully changed to $ComputerName."
       Restart-Computer -Force
     } 
     catch {
       Write-Output "An error occurred: $_"
     }

   } else {
        
     Write-Output "Invalid computer name. A valid computer name can contain only letters, numbers, and hyphens, and must be between 1 and 15 characters long."
   }

for ($i = 10; $i -ge 0; $i--) {
        Write-Host "Closing in $i seconds..."
        Start-Sleep -Seconds 1
    }