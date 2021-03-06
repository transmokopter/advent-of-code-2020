
Function Get-XMASInput{
    [CmdletBinding()]
    param(
        [string]
        $Path 
    )
    [int64[]]$r = Get-Content -Path $Path
    $r 
}
Function Get-PreviousN{
    [CmdletBinding()]
    param(
        [object[]]
        $Array,
        [int32]
        $CurrentPosition,
        [int32]
        $N
    )
    $Array[($CurrentPosition-$N)..($CurrentPosition-1)]
}

Function Get-IsValidXMASCode{
    [CmdletBinding()]
    param(
        [int64[]]
        $PreviousN,
        [int64]
        $CurrentNumber
    )
    $isValid = $false 
    for( $i = 0; $i -lt $PreviousN.Length-1 -and -not $isValid; $i++ ){
        for( $j = $i + 1; $j -lt $PreviousN.Length -and -not $isValid; $j++ ){
            $isValid = ( $PreviousN[$j] + $PreviousN[$i] -eq $CurrentNumber )
        }
    }
    $isValid 
}

Function Get-InvalidXMASCode{
    [CmdletBinding()]
    param(
        [int64[]]
        $Array
    )
    $isValid = $true 
    for( $i = 25; $i -lt $Array.Length -and $isValid; $i++){
        $isValid = ( Get-IsValidXMASCode -PreviousN ( Get-PreviousN -Array $Array -CurrentPosition $i -N 25 ) -CurrentNumber $Array[$i] )
    }
    if( $i -eq $Array.Length ){
        $null
    } else {
        $Array[$i-1]
    }
}

Function Get-IsXMASRangeForCode{
    [CmdletBinding()]
    param(
        [int64[]]
        $Array,
        [int32]
        $Start,
        [int32]
        $End,
        [int64]
        $XMASCode 
    )
    [int64]$sum=0
    $Array[$Start..$End] | ForEach-Object {
        $sum += $PSItem
        if ($sum -gt $XMASCode){
            break 
        }
    }

    if( $XMASCode -eq $sum ){
        $true 
        Write-Verbose ("" + $Array[$Start..$End])
    }
}


Function Get-XMASRangeForCode{
    [CmdletBinding()]
    param(
        [int64[]]
        $Array,
        [int64]
        $XMASCode 
    )
    $foundRange = $false
    for( $i = 0; $i -lt $Array.Length -1 -and -not $foundRange; $i++ ){
        for( $j = $i + 1; $j -lt $Array.Length -and -not $foundRange; $j++ ){
            if( (Get-IsXMASRangeForCode -Array $Array -Start $i -End $j -XMASCode $XMASCode) ){
                $Array[$i..$j]
                $foundRange = $true 
            }
        }
    }

}

[int64[]]$numbers = Get-XMASInput -Path C:\temp\input9.txt

# Excercise 1
$invalidCode = Get-InvalidXMASCode -Array $numbers 
$invalidCode 

# Excercise 2
$r = Get-XMASRangeForCode -Array $numbers -XMASCode $invalidCode 
$sortedRange = $r | Sort-Object
$smallest = $sortedRange | Select-Object -First 1
$largest = $sortedRange | Select-Object -Last 1
$smallest + $largest 