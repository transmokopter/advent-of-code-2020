Function Get-SeatID{
    [CmdletBinding()]
    param(
        [string]
        $BoardingPassNumber
    )
    $binaryString = $BoardingPassNumber.Replace("F","0").Replace("B","1").Replace("R","1").Replace("L","0")
    ([Convert]::ToInt32( $BinaryString, 2 ))
}
Function Get-Boardingpasses {
    [CmdletBinding()]
    param(
        [string]
        $Path 
    )
    Get-Content $Path | Foreach-Object { Get-SeatID -BoardingPassNumber $PSItem } | Sort-Object
}


Function Get-MissingSeatID {
    [CmdletBinding()]
    param(
        [int32[]]
        $SeatIds
    )
    $ctr = -1
    $SeatIds |
     ForEach-Object {
         if( $ctr -eq -1 ) {
             $ctr = $PSItem 
         }
         Write-Verbose "Comparing Seatid $PSItem with Counter value $ctr" 
         if( $PSItem -ne $ctr ){
             $ctr
             break 
         }
         $ctr++ 
     }
}

[int32[]]$allSeatIds = Get-Boardingpasses -Path c:\temp\input5.txt  

# Excercise 1
$allSeatIds | Select-Object -Last 1

# Excercise 2
Get-MissingSeatID -SeatIds $allSeatIds 
