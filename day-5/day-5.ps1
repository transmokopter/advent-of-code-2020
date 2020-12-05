Function Get-Boardingpasses {
    [CmdletBinding()]
    param(
        [string]
        $Path 
    )
    Get-Content $Path 
}

Function Get-SeatID{
    [CmdletBinding()]
    param(
        [string]
        $BoardingPassNumber
    )
    $rowBinaryString = ""
    $colBinaryString = ""
    $ctr   = 0

    $BoardingPassNumber.ToCharArray() |
     ForEach-Object {
            switch ($PSItem) {
                "F" { $rowBinaryString = $rowBinaryString + "0" }
                "B" { $rowBinaryString = $rowBinaryString + "1" }
                "R" { $colBinaryString = $colBinaryString + "1"}
                "L" { $colBinaryString = $colBinaryString + "0"}
            }
    }
    $rowID = ([Convert]::ToInt32( $rowBinaryString, 2 ))
    $colID = ([Convert]::ToInt32( $colBinaryString, 2 ))
    $rowID * 8 + $colID 
}
Function Get-MaxSeatID{
    [CmdletBinding()]
    param(
        [string[]]
        $BoardingPasses
    )
    $BoardingPasses | 
    ForEach-Object {
        Get-SeatID $PSItem
    } | 
    Sort-Object -Descending |
    Select-Object -First 1
}

Function Get-MinSeatID{
    [CmdletBinding()]
    param(
        [string[]]
        $BoardingPasses
    )
    $BoardingPasses | 
    ForEach-Object {
        Get-SeatID $PSItem
    } | 
    Sort-Object |
    Select-Object -First 1
}


Function Get-MissingSeatID {
    [CmdletBinding()]
    param(
        [string[]]
        $BoardingPasses
    )
    $ctr = -1
    $BoardingPasses |
     ForEach-Object {
        Get-SeatID $PSItem
     } | 
     Sort-Object | 
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

$allBoardingPasses = Get-Boardingpasses -Path c:\temp\input5.txt 

# Excercise 1
Get-MaxSeatID -BoardingPasses $allBoardingPasses

# Excercise 2
Get-MissingSeatID -BoardingPasses $allBoardingPasses
