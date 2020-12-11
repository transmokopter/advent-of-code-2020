
Function Get-Rows{
    [CmdletBinding()]
    param(
        [string]
        $Path
    )
    Get-Content -Path $Path
}

Function Get-RowLength{
    [CmdletBinding()]
    param(
        [string[]]
        $Rows
    )
    ($Rows | Select-Object -First 1).Length
}

Function Get-RowCount{
    [CmdletBinding()]
    param(
        [string[]]
        $Rows
    )
    $Rows.Length
}

Function Get-AllSeats{
    [CmdletBinding()]
    param(
        [string[]]
        $Rows
    )
    $Rows | ForEach-Object{
        $PSItem.ToCharArray()
    }
}

Function Get-AdjacentSeats{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $RowCount,
        [int32]
        $Seat
    )
    $rowNumber = Get-Rownumber -RowLength $RowLength -Seat $Seat
    $seatNumber = Get-Seatnumber -RowLength $RowLength -Seat $Seat
    $x = ($seatNumber-1), $seatNumber, ($seatNumber+1) | Where-Object { $PSItem -gt 0 -and $PSItem -le $RowLength }
    $y = ($rowNumber-1), $rowNumber, ($rowNumber+1) | Where-Object { $PSItem -ge 0 -and $PSItem -le $RowLength }
    ($x | ForEach-Object {
        $seatNumber = $PSItem
        $y | ForEach-Object {
            Get-SeatFromXY -RowLength $RowLength -SeatNumber $seatNumber -RowNumber $PSItem
        }
    }) | Where-Object { $PSItem -ne $Seat }
}

Function Get-SeatFromXY{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $RowNumber,
        [int32]
        $SeatNumber
    )
    $RowLength * $RowNumber + $SeatNumber
}

Function Get-RowNumber{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $Seat
    )
    [int32][Math]::Floor( $Seat / $RowLength )
}

Function Get-SeatNumber{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $Seat
    )
    $Seat % $RowLength
}

Function Get-NextSeatingRound{
    [CmdletBinding()]
    param(
        [char[]]
        $Seats,
        [int32]
        $RowLength,
        [int32]
        $RowCount,
        [ref]
        $ChangeCount
    )
    $ChangeCount.Value=0
    $nextSeats = $Seats.Clone()
    for( $i = 0; $i -lt $Seats.Length; $i++ ){
        $seatValue = $Seats[$i]
        $adjacentSeats = 
            (
                Get-AdjacentSeats -RowLength $RowLength -RowCount $RowCount -Seat $i |
                ForEach-Object {
                    $Seats[$PSItem]
                }
            )
        if ( $seatValue -eq "L" ){
            if( ( $adjacentSeats | Where-Object { $PSItem -eq "#" } ).Count -eq 0 ){
                $nextSeats[$i] = "#"
                $ChangeCount.value = $ChangeCount.value + 1
            }
        }
        if ($seatValue -eq "#"){
            if( ( $adjacentSeats | Where-Object { $PSItem -eq "#" } ).Count -ge 4 ){
                $nextSeats[$i] = "L"
                $ChangeCount.value = $ChangeCount.value +1
            }

        }
    }
    Write-Verbose ("" + $ChangeCount.Value + " changes were made. " + ($nextSeats | Where-Object {$PSItem -eq "#"}).Count + " seats are now occupied.")
    $nextSeats
    
}

$rows = Get-Rows -Path c:\temp\input11.txt
$length = Get-RowLength -Rows $rows
$count = Get-RowCount -Rows $rows
[char[]]$seats = Get-AllSeats -Rows $rows
$changeCount=0
do{
    $seats = (Get-NextSeatingRound -Seats $seats -RowLength $length -RowCount $count -ChangeCount ([ref]$changeCount) -Verbose ) 
}while( $changeCount -gt 0 )

($seats | Where-Object {$PSItem -eq "#"}).Count
