
[int32[]]$a = Get-Content c:\temp\input10.txt
$a = $a | Sort-Object

# Excercise 1
$results = @{ 
    1 = 0
    2 = 0
    3 = 0
 }
# Get the first adapter score
$results[$a[0]]++

# For the rest, compare with previous number and update results hash accordingly
for( $i = 1; $i -lt $a.Length; $i++){
    $results[($a[$i]-$a[$i-1])]++
}
# Get the built in
$results[3]++
$results[3] * $results[1]

# Excercise 2
[int32[]]$a = Get-Content c:\temp\input10.txt
$a = $a | Sort-Object
$noll = @(0)
$a = $noll + $a
Function Get-AdapterCombinationCount{
    [CmdletBinding()]
    param(
        [int32[]] 
        $Array,
        [int32]
        $Joltage,
        [hashtable]
        $History
    )
    if($History.ContainsKey(("" + $Array.Length + "-" + $Joltage))){
        $combinationCount = $History["" + $Array.Length + "-" + $Joltage]
    } else {
        $combinationCount = 0
        $Array | Where-Object { $PSItem -ge ($Joltage - 3) } | Foreach-Object{
            $newJoltage = $PSItem
            $newArray = $Array | Where-Object { $PSItem -lt $newJoltage }
            $combinationCount++
            if($newArray){
                $combinationCount = $combinationCount + (
                    Get-AdapterCombinationCount -Array $newArray -Joltage $newJoltage -History $History
                ) -1 
            }
        }
        $History.Add("" + $Array.Length + "-" + $Joltage,$combinationCount)
        Write-Verbose( "$Array - " + $Array.Length + " - " + $Joltage + " - " + $combinationCount )
    }
    
    $combinationCount
}

# For each position, which possible matches?
Get-AdapterCombinationCount -Array $a -Joltage (($a | Select-Object -Last 1) + 3) -Verbose -History @{}

