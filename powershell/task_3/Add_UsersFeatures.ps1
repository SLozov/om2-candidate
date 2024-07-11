function Confirm-WindowsFeatureName {
    param (
        [string]$FeatureName
    )
    
    try {
        $features = Get-WindowsFeature | Select-Object -ExpandProperty Name
        if ($features -contains $FeatureName) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $_
    }
}

function Search-WindowsFeatureIfInstalled {
    param (
        [string]$FeatureName
    )

    try {
        $feature = Get-WindowsFeature -Name $FeatureName -ErrorAction Stop
        if ($feature.InstallState -eq 'Installed') {
            return $true
        } else {
            return $false
        }
    } catch {
        return $_
    }
}

function Install-WindowsFeatureCustom {
    param (
        [string]$FeatureName
    )

    try {
        Write-Output "$_ is going to be installed ..."
        Install-WindowsFeature -Name $FeatureName -IncludeAllSubFeature -IncludeManagementTools -Verbose:$false > $null
        Write-Output "Installation of feature '$FeatureName' completed successfully!"
    } catch {
        Write-Output "Error installing feature '$FeatureName': $_"
        return $_
    }
}

function Test-Username {
    param (
        [string]$Username
    )
    
    if (-not $Username -or
        $Username.Length -lt 1 -or $Username.Length -gt 20 -or
        $Username -match '^\s|\s$' -or
        $Username -notmatch '^[a-zA-Z0-9_-]+$') {
        
        return $false
    }

    return $true
}

function Test-Password {
    param (
        [System.Security.SecureString]$SecureString
    )

    try {
        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    
        if ($plain.Length -ge 8    -and
            $plain -cmatch '[A-Z]' -and
            $plain -cmatch '[a-z]' -and
            $plain -cmatch '\d'    -and
            $plain -cmatch '[^a-zA-Z0-9]') {
           return $true
        } else {
           return $false
        }
    }catch{
        return $_
    }
}

function Find-UserIfExists {
    param (
        [string]$Username
    )

    try {
        $user = Get-LocalUser -Name $Username -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function New-LocalUserAccount {
    param (
        [string]$Username,
        [System.Security.SecureString]$Password
    )

    try {
        New-LocalUser "$username" -Password $password -ErrorAction stop -Verbose:$false > $null
        Write-Output "Local accout $username successfully created!"
    }catch{
        Write-Output "Creating local account failed. $_"
    }      
}


do {
    $InitialData = Get-Content -Path "..\initial_data.json" -Raw -ErrorAction Stop | ConvertFrom-Json
    
    Write-Host "1.Checking if there are Windows features to install ... "
    
    if (-not $InitialData.Features -or $InitialData.Features.Trim() -eq "") {
        Write-Host "No Windows Features listed in the file, nothing to install! "
    } else {
        $InitialData.Features | ForEach-Object {
    
        $valid = Confirm-WindowsFeatureName -FeatureName $_ 
        $installed = Search-WindowsFeatureIfInstalled -FeatureName $_ 
    
        if ($valid -isnot [bool]) {
            Write-Host "An error occurred while retrieving the list of Windows Features."
            Write-Host "Error: $($valid.Exception.Message)"
        }
        elseif (-not $valid) {
            Write-Host "The feature name $_ is not valid Windows Feature."
        }  
        else{
            if ($installed -isnot [bool]) {
                Write-Host "The feature '$_' could not be found or there was an error retrieving the feature state."
                Write-Host "Error: $($installed.Exception.Message)"
            }
            elseif ($installed) {
                Write-Host "The feature '$_' is already installed."
            }else{
                Install-WindowsFeatureCustom -FeatureName $_
            }
            
        }
       }
      }
    
    Write-Host "`n2.Checking if there are users to create ... "
    
    if (-not $InitialData.Users -or $InitialData.Users.Trim() -eq "") {
        Write-Host "No users listed in the file, no users will be created! "
    } else {
        $InitialData.Users | ForEach-Object {
    
        $validUsername = Test-Username -Username $_ 
        $existUsername = Find-UserIfExists -Username $_ 
    
        if (-not $validUsername) {
            Write-Host "$_ is not a valid username, user can't be created."
        }
        elseif ($existUsername) {
            Write-Host "User with name $_ already exists on local machine."
        }  
        else{
            Write-Host "User $_ is going to be created."
            Write-Host "Enter a password for user $_. The password must be at least 8 characters long, contain uppercase, lowercase, digits and special characters."
            
            $validPassword = $false
            while (-not $validPassword ){
    
               $securePassword = Read-Host -Prompt "Enter password for user $_ : " -AsSecureString
               if (Test-Password -secureString $securePassword) {
                   Write-Host "Password is valid, creating local account ..."
                   New-LocalUserAccount -Username $_ -Password $securePassword
                   $validPassword = $true
               }else{
                   Write-Host "Password doesn't meet the requirements. Try again."
               }
            }
        }           
      }
    }
    $continue = Read-Host -Prompt "Do you want to re-run the script? (y/n)"
} while ($continue -eq 'y')