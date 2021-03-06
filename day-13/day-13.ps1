$fileContent = Get-Content C:\temp\input13.txt
[int64]$timestamp = $fileContent[0]
[int32[]]$schedule = ( $fileContent[1].Split(",") | Where-Object{ 
    $PSItem -ne "x"
} )

Class BusWait{
    [int32] $busID
    [int32] $WaitTime
}

$bus = ($schedule | ForEach-Object {
    $bus = New-Object -TypeName BusWait
    $bus.BusID = $PSItem 
    $bus.WaitTime = $PSItem - ($timestamp % $PSItem)
    $bus  
} | Sort-Object WaitTime | Select-Object -First 1 )
$bus.busID * $bus.WaitTime


Class BusRule{
    [int32]$BusId
    [int32]$RelativeTime 
}
Function Get-BusRules{
    [CmdletBinding()]
    param(
        [string[]]
        $Schedule
    )
    for( $i=0; $i -lt $Schedule.Length; $i++ ){
        if(
            $newSchedule[$i] -ne "x"
        ){
            $busRule = New-Object -TypeName BusRule 
            $busRule.BusId = $newSchedule[$i]
            $busRule.RelativeTime = $i
            $busRule 
        }
    }
}

$newSchedule = (Get-Content -Path c:\temp\input13.txt)[1].Split(",")
$busRules = Get-BusRules -Schedule $newSchedule 

$maxBusId = ($busRules | Sort-Object BusID | Select-Object -Last 1).BusID 

$maxBusIdRelativeTime = ( $busRules | Where-Object { $PSItem.BusID -eq $maxBusId } ).RelativeTime 

# Counter for loop
[decimal]$i = $maxBusId  
$foundit = $false 

# So far, no rules were validated
$maxRuleHitCount=0
$maxRuleHitFoundFirstAt = 0
$maxRuleHitCountFoundTimes = 0 

[int64]$iterationCount = 0

[decimal]$iterator=$maxBusId 

while( -not $foundit ){
    $iterationCount++
    $i += $iterator 
    $ruleHitCount=0
    $foundit = $true 
    for ( $j = 0; $j -lt $busRules.Length; $j++ ){
        if ( ( $i - $maxBusIdRelativeTime + $busRules[$j].RelativeTime ) % $busRules[$j].BusId -ne 0 ){
            $foundit = $false 
            break;
        }
        $ruleHitCount++
        if($ruleHitCount -eq $maxRuleHitCount -and $maxRuleHitCountFoundTimes -eq 1){
            $iterator = $i - $maxRuleHitFoundFirstAt
            $maxRuleHitCountFoundTimes = 0
            Write-Host "Hitcount $ruleHitCount found twice. Resetting iterator value to $iterator"
        }
        if($ruleHitCount -gt $maxRuleHitCount){
            $maxRuleHitCount = $ruleHitCount 
            $maxRuleHitCountFoundTimes = 1
            $maxRuleHitFoundFirstAt = $i 
            Write-Host "ruleHitCount is now $ruleHitCount, found at $i"
        }
    }
}
Write-Host ("First valid timestamp is: " + ($i - $maxBusIdRelativeTime) + ". Finding this timestamp required $iterationCount iterations.")