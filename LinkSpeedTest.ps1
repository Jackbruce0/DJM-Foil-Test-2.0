# Get the network adapter named "Ethernet 2"
$adapter = Get-NetAdapter | Where-Object { $_.Name -eq "Ethernet 2" }

# Check if the adapter exists
if ($adapter) {
    # Extract the numeric part of the LinkSpeed and remove any units like "Gbps" or "Mbps"
    $rawSpeed = $adapter.LinkSpeed
    $numericSpeed = [regex]::Match($rawSpeed, '\d+').Value

    # Determine the unit (Gbps or Mbps) and convert to Mbps if necessary
    if ($rawSpeed -like "*Gbps") {
        $speedInMbps = [int]$numericSpeed * 1000
    } elseif ($rawSpeed -like "*Mbps") {
        $speedInMbps = [int]$numericSpeed
    } else {
        $speedInMbps = "Unknown"
    }

    # Output the link speed
    Write-Output "The link speed of '$($adapter.Name)' is $speedInMbps Mbps."
} else {
    Write-Output "The network adapter 'Ethernet 2' was not found."
}
