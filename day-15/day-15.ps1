
Function Get-NthRound{
    [CmdletBinding()]
    param(
        [int32[]]
        $InitialNumbers,
        [int32]
        $N
    )
    $resultTable = @{}
    for ( $i = 1; $i -le $InitialNumbers.Length; $i++){
        $resultTable[$InitialNumbers[$i-1].ToString()] = $i 
    }

    $lastUsedNumber = $numbers[$numbers.Length-1]
    for ( $i = $numbers.Length  ;  $i -lt $N; $i++ ){
        $pos = $i
        if( $resultTable.ContainsKey("$lastUsedNumber") -and $resultTable["$lastUsedNumber"] -ne $i ){
            $pos = $resultTable["$lastUsedNumber"]
        }
        $resultTable["$lastUsedNumber"] = $i
        $lastUsedNumber = $i - $pos
    }
    $lastUsedNumber 
}

$numbers = 20,9,11,0,1,2

Get-NthRound -InitialNumbers $numbers -N 2020
Get-NthRound -InitialNumbers $numbers -N 30000000
