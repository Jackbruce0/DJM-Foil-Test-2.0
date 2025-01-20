# Display Splash Screen
if (Test-Path ./Splash.txt) {
    Get-Content ./Splash.txt | ForEach-Object { $_.PadLeft(($_.Length + 50) / 2) }
} else {
    Write-Host "Splash screen file 'Splash.txt' not found. Skipping splash screen." -ForegroundColor Yellow
}


# Function to convert link speed and determine unit
function Convert-LinkSpeed {
    param (
        [string]$RawSpeed
    )
    # Match numeric parts including decimals
    $numericSpeed = [regex]::Match($RawSpeed, '\d+(\.\d+)?').Value

    if ($RawSpeed -like "*Gbps") {
        return @{
            Value = [double]$numericSpeed
            Unit = "Gbps"
        }
    } elseif ($RawSpeed -like "*Mbps") {
        return @{
            Value = [int]$numericSpeed
            Unit = "Mbps"
        }
    } else {
        return @{
            Value = "Unknown"
            Unit = ""
        }
    }
}


# Get all available network adapters
$adapters = Get-NetAdapter | Select-Object Name, Status

# Display a numbered list of network adapters
Write-Host "Available Network Adapters:" -ForegroundColor Cyan
for ($i = 0; $i -lt $adapters.Count; $i++) {
    $adapter = $adapters[$i]
    Write-Host "$($i + 1). Name: $($adapter.Name) | Status: $($adapter.Status)"
}
Write-Host ""

# Prompt the user to select an adapter
Write-Host "Select the adapter associated with DJM ACTIV filter connection" -ForegroundColor Cyan
$selectedIndex = Read-Host "Enter the number corresponding to the desired adapter"

# Explicitly convert input to an integer and validate
if ($selectedIndex -as [int]) {
    $selectedIndex = [int]$selectedIndex
    if ($selectedIndex -ge 1 -and $selectedIndex -le $adapters.Count) {
        # Debug: Valid selection
        # Write-Host "DEBUG: Valid selection is '$selectedIndex'" -ForegroundColor Yellow
    } else {
        Write-Host "Invalid selection. Please enter a valid number between 1 and $($adapters.Count)." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Invalid input. Please enter a number." -ForegroundColor Red
    exit
}

# Get the selected adapter based on user input
$selectedAdapter = $adapters[$selectedIndex - 1]
Write-Host "You selected adapter: $($selectedAdapter.Name)" -ForegroundColor Green

# Proceed with further processing for the selected adapter
$adapter = Get-NetAdapter | Where-Object { $_.Name -eq $selectedAdapter.Name }

if ($adapter) {
    $rawSpeed = $adapter.LinkSpeed
    $convertedSpeed = Convert-LinkSpeed -RawSpeed $rawSpeed

    # Output the link speed in the updated format
    Write-Host ""
    Write-Host ("=" * 50) -ForegroundColor Green
    Write-Host "Displaying results for '$($adapter.Name)':" -ForegroundColor Green
    Write-Host ("=" * 50) -ForegroundColor Green

    if ($convertedSpeed.Value -ne "Unknown") {
        Write-Host "Link Speed: $($convertedSpeed.Value) $($convertedSpeed.Unit)" -ForegroundColor Green
    } else {
        Write-Host "Unable to determine the link speed of '$($adapter.Name)'." -ForegroundColor Red
    }
} else {
    Write-Host "The adapter '$($selectedAdapter.Name)' was not found." -ForegroundColor Red
}
