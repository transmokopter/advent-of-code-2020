Class TicketFieldRule{
    [string] $FieldName
    [int32] $Low1
    [int32] $High1
    [int32] $Low2
    [int32] $High2

    [bool]ValidateNumber( [int32]$number ){
        return ( ( $number -ge $this.Low1 -and $number -le $this.High1 ) -or ( $number -ge $this.Low2 -and $number -le $this.High2 ) )
    }
}

Function Get-TicketFieldRule{
    [CmdletBinding()]
    param(
        [string]
        $RuleString
    )
    $rule = New-Object -TypeName TicketFieldRule
    $matchGroups = ($RuleString | Select-String -Pattern "([a-z ]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)").Matches.Groups
    if( $matchGroups.Count -eq 6){
        $rule.FieldName = $matchGroups[1].Value
        $rule.Low1 = $matchGroups[2].Value 
        $rule.High1 = $matchGroups[3].Value
        $rule.Low2 = $matchGroups[4].Value 
        $rule.High2 = $matchGroups[5].Value
    }
    $rule 
}

Function Get-IsValidForAnyRule{
    [CmdletBinding()]
    param(
        [TicketFieldRule[]] $Rules,
        [int32] $Number 
    )
    
    $isValid=$false 
    for( $i = 0; $i -lt $Rules.Length; $i++ ){
        if( ($Rules[$i].ValidateNumber($Number)) ){
            $isValid = $true
            break 
        }
    }
    $isValid 
}

Function Get-InputSection{
    [CmdletBinding()]
    param(
        [string]
        $Path,
        [string]
        $Section 
    )
    [string[]] $inputFile = Get-Content -Path $Path 
    $result = @()
    $foundSection = $false 
    foreach($key in $inputFile){
        if( $key -eq "" -and $section -eq "rules"){
            break
        }
        if ( $section -eq "rules" ){
            Write-Verbose "Found rule: $key"
            $result += ( Get-TicketFieldRule -RuleString $key )
            continue 
        }
        if ( $section -eq "ticket" -and $key -eq "your ticket:" ){
            $foundSection = $true 
            continue
        }
        if ( $section -eq "ticket" -and $foundSection ){
            $result = [int32[]]( $key.Split(",") )
            break 
        }
        if ($section -eq "nearby" -and $foundSection ){
            $result += $key 
        }
        if ( $section -eq "nearby" -and $key -eq "nearby tickets:" ){
            $foundSection = $true
            continue 
        }
    }
    $result 
}

Function Get-InvalidNearbySum{
    [CmdletBinding()]
    param(
        [string[]]
        $NearbyTickets,
        [TicketFieldRule[]]
        $Rules
    )
    [int64] $invalidCount = 0
    for ( $i = 0; $i -lt $NearbyTickets.Length; $i++ ){
        [int32[]]$ticket = $NearbyTickets[$i].Split(",")
        for( $j = 0; $j -lt $ticket.Length; $j++ ){
            if ( -not ( Get-IsValidForAnyRule -Rules $Rules -Number $ticket[$j] ) ){
                Write-Verbose ("Invalid value found " + $ticket[$j])
                $invalidCount += $ticket[$j]
            }
        }
    }
    $invalidCount 
}

Function Get-IsValidTicket{
    [CmdletBinding()]
    param(
        [string]$Ticket,
        [TicketFieldRule[]]$Rules
    )
    $errorRate = Get-InvalidNearbySum -NearbyTickets $Ticket -Rules $Rules 
    ( $errorRate -eq 0 )
}


[int32[]] $myTicket = Get-InputSection -Path c:\temp\input16.txt -Section "ticket"
[string[]] $nearbyTickets = Get-InputSection -Path c:\temp\input16.txt -Section "nearby"
[TicketFieldRule[]] $rules = Get-InputSection -Path c:\temp\input16.txt -Section "rules"
Get-InvalidNearbySum -Rules $rules -NearbyTickets $nearbyTickets 

$validTickets = ($nearbyTickets | Where-Object {
    Get-IsValidTicket -Ticket $PSItem -Rules $Rules 
})

$ruleBreakers = @{}

for( $i = 0; $i -lt $validTickets.Length; $i++ ){
    [int32[]]$ticket = $validTickets[$i].Split(",")
    for( $j = 0; $j -lt $ticket.Length; $j++ ){
        foreach($rule in $rules){
            if( -not $rule.ValidateNumber($ticket[$j]) ){
#                Write-Host ("" + $ticket[$j] + "is valid number for rule " + $rule.FieldName) 
                if( $ruleBreakers.ContainsKey($rule.FieldName) -and -not ($ruleBreakers[$rule.FieldName]).Contains($j) ){
                    $ruleBreakers[$rule.FieldName] += $j
                }
                if( -not $ruleBreakers.ContainsKey( $rule.FieldName) ){
                    $ruleBreakers[$rule.FieldName] = @()
                    $ruleBreakers[$rule.FieldName] += $j
                }
            }
        }
    }
}
$fieldPositions = @{}

while($ruleBreakers.Keys.Count -ne 0){
    $mostBrokenRule = (
        $ruleBreakers.Keys | ForEach-Object{
        $ruleBreakers[$PSItem].Length.ToString() + "-" + $PSItem 
        }| Select-Object @{ Name = "Hits"; Expression = { [int32]( $PSItem.Split("-")[0]) }}, @{ Name = "Field"; Expression = { ($PSItem.Split("-")[1]) }} |
        Sort-Object -Property Hits -Descending | Select-Object -First 1
    )

    [int32]$possiblePositions = (0..($myTicket.Length-1)|
    Where-Object {
    -not $ruleBreakers[$mostBrokenRule.Field].Contains($PSItem)    
    } )

    $fieldPositions[$mostBrokenRule.Field] = [int32]$possiblePositions 
    $ruleBreakers.Remove($mostBrokenRule.Field)
    $temp = $ruleBreakers.Clone()
    foreach($key in $temp.Keys){
        if(-not $ruleBreakers[$key].Contains($possiblePositions)){
            $ruleBreakers[$key]  += $possiblePositions
        }
    }
}
$result = 1
foreach($key in ($fieldPositions.Keys|where-object{$psitem -like "departure*"})){
    $result *= $myTicket[$fieldPositions[$key]]
}
$result 
