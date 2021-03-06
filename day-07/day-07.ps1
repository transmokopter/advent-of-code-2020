Class BagRule{
    [string] $ContainerBagColor
    [string] $CanHoldBagColor
    [int32]  $CanHoldBagCount
}

Function Get-BagFromString{
    [CmdletBinding()]
    param(
        [string]
        $BagDefinition
    )
    $matchGroups = (
        $BagDefinition | 
         Select-String -Pattern "([a-zA-Z]+ [a-zA-Z]+) bags contain"
    ).Matches.Groups
    if( $matchGroups.Count -eq 2 ) {
        $b = $matchGroups[1].Value
    }
    $b
}

Function Get-BagRulesFromString{
    [CmdletBinding()]
    param(
        [string]
        $BagDefinition
    )
    if((
        $BagDefinition | 
         Select-String -Pattern "[a-zA-Z]+ [a-zA-Z]+ bags contain no other bags."
    ).Matches){
        [string[]]@()
    } else {
        (($BagDefinition | 
        Select-String -Pattern "([0-9]+ [a-zA-Z]+ [a-zA-Z]+) bag" -AllMatches
        ).Matches.Groups | Where-Object { $PSItem.Name -eq "1" }).Value
    }
}

Function Get-BagRulesFromFile{
    [CmdletBinding()]
    param(
        [string]
        $Path
    )
    Get-Content -Path $Path | ForEach-Object {
        $b = Get-BagFromString $PSItem
        Get-BagRulesFromString $PSItem | ForEach-Object {
            $bagRule = New-Object BagRule
            $r = $PSItem.Split(" ")
            Write-Verbose $PSItem 
            $bagRule.CanHoldBagCount = [int32] $r[0]
            $bagRule.CanHoldBagColor = [string] $r[1] + " " + $r[2]
            $bagRule.ContainerBagColor = $b
            $bagRule
        } | Select-Object ContainerBagColor, CanHoldBagColor, CanHoldBagCount
    } 
}

Function Get-ContainerBagColorCount{
    [CmdletBinding()]
    param(
        [string]
        $BagColor,
        [BagRule[]]
        $BagRules,
        [hashtable]
        $CurrentCollection
    )
    $bagCount = 1
    $BagRules | Where-Object {
        $PSItem.CanHoldBagColor -eq $BagColor -and -not $CurrentCollection.ContainsKey($PSItem.ContainerBagColor)
    } | ForEach-Object {
        Write-Verbose "Adding rule $PSItem"
        $CurrentCollection.Add( $PSItem.ContainerBagColor,$PSItem.ContainerBagColor )
        $bagCount = $bagCount + (Get-ContainerBagColorCount -BagColor $PSItem.ContainerBagColor -BagRules $BagRules -CurrentCollection $CurrentCollection) 
    }
    $bagCount 
}
Function Get-BagCount{
    [CmdletBinding()]
    param(
        [string]
        $BagColor,
        [BagRule[]]
        $BagRules
    )
    $bagCount = 1
    $BagRules | Where-Object {
        $PSItem.ContainerBagColor -eq $BagColor
    } | ForEach-Object {
        $bagCount = $bagCount +  $PSItem.CanHoldBagCount * ( Get-BagCount -BagColor $PSItem.CanHoldBagColor -BagRules $BagRules )
    }
    Write-Verbose "Done with color $BagColor, current count is $bagCount"
    $bagCount 
}


$r = @{}
$rules = Get-BagRulesFromFile -Path c:\temp\input7.txt 

# Excercise 1
(Get-ContainerBagColorCount -BagColor "shiny gold" -BagRules $rules -CurrentCollection $r) - 1 # Must remove starting color

# Excercise 2
(Get-BagCount -BagColor "shiny gold" -BagRules $rules) -1 # Must remove the outermost bag bag