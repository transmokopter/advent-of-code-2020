
Function Set-MemoryValue{
    [CmdletBinding()]
    param(
        [hashtable]
        $Memory,
        [string]
        $MemoryAddress,
        [int64]
        $MemoryValue,
        [string]
        $Bitmask 
    )
    $binaryString = [Convert]::ToString($MemoryValue,2)
    $binaryString = $binaryString.PadLeft(36).Replace(" ","0")
    $binaryStringCharArray = $binaryString.ToCharArray()
    $bitmaskCharArray = $Bitmask.ToChararray()
    for($i=0; $i -lt $Bitmask.Length; $i++){
        if($bitmaskCharArray[$i] -ne "x"){
            $binaryStringCharArray[$i] = $bitmaskCharArray[$i]
        }
    }
    $binaryString = -join $binaryStringCharArray
    $adjustedMemoryValue = [Convert]::ToInt64($binaryString,2)
    $Memory[$MemoryAddress]=$adjustedMemoryValue
}
Function Invoke-DockingProgram{
    [CmdletBinding()]
    param(
        [string[]]
        $Program,
        [hashtable]
        $Memory 
    )
    $Program | ForEach-Object{
        if ( $PSItem -like "mask*"){
            $bitmask = $PSItem.Replace("mask = ","")
        }else {
            $matchGroups = ( $PSItem | Select-String -Pattern "mem\[([0-9]+)\] = ([0-9]+)").Matches.Groups 
            [string]$memoryAddress = $matchGroups[1].Value
            [int64]$memoryValue = $matchGroups[2].Value
            Set-MemoryValue -Memory $Memory -MemoryAddress $memoryAddress -MemoryValue $memoryValue -Bitmask $bitmask  
        }
    }
}

Function Get-BitmapCombinations{
    [CmdletBinding()]
    param(
        [string] $Prefix,
        [string] $Suffix,
        [hashtable] $MemoryAddresses
    )
    if($Suffix.Length -eq 0  ){
        $MemoryAddresses[([Convert]::ToInt64($Prefix,2)).ToString()]=""
    }else{
        $CurrentChar = $Suffix.SubString(0,1)
        $newSuffix = $Suffix.Substring(1,$Suffix.Length-1)
        if($CurrentChar -eq "x" ){
            Get-BitmapCombinations -Prefix "" -Suffix ($Prefix + "1" + $newSuffix) -MemoryAddresses $MemoryAddresses
            Get-BitmapCombinations -Prefix "" -Suffix ($Prefix + "0" + $newSuffix) -MemoryAddresses $MemoryAddresses
        }else{
            Get-BitmapCombinations -Prefix ($Prefix + $CurrentChar) -Suffix $newSuffix -MemoryAddresses $MemoryAddresses 
        }
    }
}

Function Set-MemoryValue2{
    [CmdletBinding()]
    param(
        [hashtable]
        $Memory,
        [string]
        $MemoryAddress,
        [int64]
        $MemoryValue,
        [string]
        $Bitmask 
    )
    $binaryString = [Convert]::ToString($MemoryAddress,2)
    $binaryString = $binaryString.PadLeft(36).Replace(" ","0")
    $binaryStringCharArray = $binaryString.ToCharArray()
    $bitmaskCharArray = $Bitmask.ToChararray()
    for($i=0; $i -lt $Bitmask.Length; $i++){
        if( $bitmaskCharArray[$i] -eq "1" ){
            $binaryStringCharArray[$i] = "1"
        }
        if( $bitmaskCharArray[$i] -eq "X" ){
            $binaryStringCharArray[$i] = "X"
        }
    }
    $binaryString = -join $binaryStringCharArray
    $memoryAddresses = @{}
    Get-BitmapCombinations -Prefix "" -Suffix $binaryString -MemoryAddresses $memoryAddresses
    foreach($memoryKey in $memoryAddresses.Keys){
        $Memory[$memoryKey]=$MemoryValue
    }
}


Function Invoke-DockingProgram2{
    [CmdletBinding()]
    param(
        [string[]]
        $Program,
        [hashtable]
        $Memory 
    )
    $Program | ForEach-Object{
        if ( $PSItem -like "mask*"){
            $bitmask = $PSItem.Replace("mask = ","")
        }else {
            $matchGroups = ( $PSItem | Select-String -Pattern "mem\[([0-9]+)\] = ([0-9]+)").Matches.Groups 
            [string]$memoryAddress = $matchGroups[1].Value
            [int64]$memoryValue = $matchGroups[2].Value
            Set-MemoryValue2 -Memory $Memory -MemoryAddress $memoryAddress -MemoryValue $memoryValue -Bitmask $bitmask  
            Write-Verbose ("Memory address $memoryAddress set. Memory now has " + $memory.Keys.Count.ToString() + " addresses set.")
        }
    }
}


# Ex 1
[string[]]$program = Get-Content C:\temp\input14.txt 
$memory = @{}
Invoke-DockingProgram -Program $program -Memory $memory
$result = 0
foreach($i in $memory.Values){
    $result += $i
}
$result 

# Ex 2
[int64]$result=0
[string[]]$program = Get-Content C:\temp\input14.txt
$memory = @{}
Invoke-DockingProgram2 -Program $program -Memory $memory -Verbose
foreach($i in $memory.Values){
    $result += $i
}
$result 
