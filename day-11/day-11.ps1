
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
#    $x = ($seatNumber-1), $seatNumber, ($seatNumber+1) | Where-Object { $PSItem -gt 0 -and $PSItem -le $RowLength }
#    $y = ($rowNumber-1), $rowNumber, ($rowNumber+1) | Where-Object { $PSItem -ge 0 -and $PSItem -lt $RowCount }
    switch ( $seatNumber ){
        1 {
            $startX = 1
        } 
        default {
            $startX = $seatNumber - 1
        }
    }
    switch ( $rowNumber ){
        0 {
            $startY = 0
        }
        default {
            $startY = $rowNumber - 1
        }
    }

    for( $i = $startX; $i -le $seatNumber + 1 -and $i -le $RowLength; $i++ ){
        for( $j = $startY; $j -le ($rowNumber + 1) -and $j -lt $RowCount; $j++ ){
            $xy = Get-SeatFromXY -RowLength $RowLength -SeatNumber $i -RowNumber $j
            if( $xy -ne $Seat ){
                $xy
            }
        }
    } 
}

Function Get-OccupiedAdjacentSeatCount{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $RowCount,
        [int32]
        $Seat,
        [char[]]
        $Seats 
    )
    $occupiedCount = 0
    $rowNumber = Get-Rownumber -RowLength $RowLength -Seat $Seat
    $seatNumber = Get-Seatnumber -RowLength $RowLength -Seat $Seat
#    $x = ($seatNumber-1), $seatNumber, ($seatNumber+1) | Where-Object { $PSItem -gt 0 -and $PSItem -le $RowLength }
#    $y = ($rowNumber-1), $rowNumber, ($rowNumber+1) | Where-Object { $PSItem -ge 0 -and $PSItem -lt $RowCount }
    switch ( $seatNumber ){
        1 {
            $startX = 1
        } 
        default {
            $startX = $seatNumber - 1
        }
    }
    switch ( $rowNumber ){
        0 {
            $startY = 0
        }
        default {
            $startY = $rowNumber - 1
        }
    }

    for( $i = $startX; $i -le $seatNumber + 1 -and $i -le $RowLength; $i++ ){
        for( $j = $startY; $j -le ($rowNumber + 1) -and $j -lt $RowCount; $j++ ){
            $xy = Get-SeatFromXY -RowLength $RowLength -SeatNumber $i -RowNumber $j
            if( $xy -ne $Seat -and $Seats[$xy] -eq "#" ){
                $occupiedCount++
            }
        }
    } 
    $occupiedCount
}


Function Get-OccupiedVisibleSeatCount{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $RowCount,
        [int32]
        $Seat,
        [char[]]
        $Seats 
    )
    $occupiedCount = 0
    $rowNumber = Get-Rownumber -RowLength $RowLength -Seat $Seat
    $seatNumber = Get-Seatnumber -RowLength $RowLength -Seat $Seat
#    Write-Verbose "SeatNumber: $seatNumber - RowNumber: $rowNumber"
    #North
    $x = $seatNumber 
    $y = $rowNumber - 1
    while( $y -ge 0 ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
                $occupiedCount++;
#                Write-Verbose "North: Found occupied seat at $x $y"
            }
            break 
        }
        $y--
    }

    #South
    $x = $seatNumber 
    $y = $rowNumber + 1
    while( $y -lt $RowCount ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
                $occupiedCount++;
#                Write-Verbose "South: Found occupied seat at $x $y"
            }
            break 
        }
        $y++
    }
    #East
    $x = $seatNumber + 1
    $y = $rowNumber
    while( $x -le $RowLength ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
                $occupiedCount++;
#                Write-Verbose "East: Found occupied seat at $x $y"
            }
            break 
        }
        $x++
    }
    #West
    $x = $seatNumber - 1
    $y = $rowNumber
    while( $x -gt 0 ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
#                Write-Verbose "West: Found occupied seat at $x $y"
                $occupiedCount++;
            }
            break 
        }
        $x--
    }
    #NorthWest
    $x = $seatNumber - 1
    $y = $rowNumber - 1
    while( $x -gt 0 -and $y -ge 0 ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
#                Write-Verbose "NorthWest: Found occupied seat at $x $y"
                $occupiedCount++;
            }
            break 
        }
        $x--
        $y--
    }
    #NorthEast
    $x = $seatNumber + 1
    $y = $rowNumber - 1
    while( $x -le $RowLength -and $y -ge 0 ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
#                Write-Verbose "NorthEast: Found occupied seat at $x $y"
                $occupiedCount++;
            }
            break 
        }
        $x++
        $y--
    }
    #SouthEast
    $x = $seatNumber + 1
    $y = $rowNumber + 1
    while( $x -le $RowLength -and $y -lt $RowCount ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
#                Write-Verbose "SouthEast: Found occupied seat at $x $y"
                $occupiedCount++;
            }
            break 
        }
        $x++
        $y++
    }
    #SouthWest
    $x = $seatNumber - 1
    $y = $rowNumber + 1
    while( $x -gt 0 -and $y -lt $RowCount ){
        $seatValue = Get-SeatValueFromXY -RowLength $RowLength -SeatNumber $x -RowNumber $y -Seats $Seats 
        if ( $seatValue -ne "."){
            if ( $seatValue -eq "#" ){
#                Write-Verbose "SouthWest: Found occupied seat at $x $y"
                $occupiedCount++;
            }
            break 
        }
        $x--
        $y++
    }

    $occupiedCount
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
    $RowLength * $RowNumber + $SeatNumber -1  
}

Function Get-SeatValueFromXY{
    [CmdletBinding()]
    param(
        [int32]
        $RowLength,
        [int32]
        $RowNumber,
        [int32]
        $SeatNumber,
        [char[]]
        $Seats
    )
    $Seats[($RowLength * $RowNumber + $SeatNumber -1)]  
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
    ($Seat) % $RowLength + 1
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
    $ChangeCount.Value = 0
    $nextSeats = $Seats.Clone()
    for( $i = 0; $i -lt $Seats.Length; $i++ ){
        $seatValue = $Seats[$i]
        if( $seatValue -eq "." ){
            continue 
        }
        $occupiedCount = Get-OccupiedAdjacentSeatCount -Seats $Seats -RowLength $RowLength -RowCount $RowCount -Seat $i
        if( $occupiedCount -gt 0 -and $occupiedCount -lt 4 ){
            continue 
        }
        if ( $seatValue -eq "L" -and $occupiedCount -eq 0 ){
            $nextSeats[$i] = "#"
            $ChangeCount.value = $ChangeCount.value + 1
        }
        if ($seatValue -eq "#" -and $occupiedCount -ge 4){
            $nextSeats[$i] = "L"
            $ChangeCount.value = $ChangeCount.value +1
        }
    }
    Write-Verbose ("" + $ChangeCount.Value + " changes were made. " + ($nextSeats | Where-Object {$PSItem -eq "#"}).Count + " seats are now occupied.")
    #DrawGame -Seats $nextSeats -RowLength $RowLength -RowCount $RowCount
    $nextSeats
    
}

Function Get-NextSeatingRound2{
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
    $ChangeCount.Value = 0
    $nextSeats = $Seats.Clone()
    for( $i = 0; $i -lt $Seats.Length; $i++ ){
        $seatValue = $Seats[$i]
        if( $seatValue -eq "." ){
            continue 
        }
        $occupiedCount = Get-OccupiedVisibleSeatCount -Seats $Seats -RowLength $RowLength -RowCount $RowCount -Seat $i
        if( $occupiedCount -gt 0 -and $occupiedCount -lt 5 ){
            continue 
        }
        if ( $seatValue -eq "L" -and $occupiedCount -eq 0 ){
            $nextSeats[$i] = "#"
            $ChangeCount.value = $ChangeCount.value + 1
        }
        if ($seatValue -eq "#" -and $occupiedCount -ge 5){
            $nextSeats[$i] = "L"
            $ChangeCount.value = $ChangeCount.value +1
        }
    }
    Write-Verbose ("" + $ChangeCount.Value + " changes were made. " + ($nextSeats | Where-Object {$PSItem -eq "#"}).Count + " seats are now occupied.")
    #DrawGame -Seats $nextSeats -RowLength $RowLength -RowCount $RowCount
    $nextSeats
    
}


Function DrawGame{
    [CmdletBinding()]
    param(
        [char[]]
        $Seats,
        [int32]
        $RowLength,
        [int32]
        $RowCount
    )
    for( $i = 0; $i -lt $RowCount; $i++ ){
        Write-Verbose (-join $Seats[($RowCount*$i)..($RowCount*$i+$RowLength-1)])
    }
}

$ex = 2

if( $ex -eq 1 ){
    # Excercise 1
    $rows = Get-Rows -Path c:\temp\input11.txt
    $length = Get-RowLength -Rows $rows
    $count = Get-RowCount -Rows $rows
    [char[]]$seats = Get-AllSeats -Rows $rows
    $changeCount=0
    do{
        $seats = (Get-NextSeatingRound -Seats $seats -RowLength $length -RowCount $count -ChangeCount ([ref]$changeCount) -Verbose ) 
    }while( $changeCount -gt 0 )

    ($seats | Where-Object {$PSItem -eq "#"}).Count
}

if( $ex -eq 2 ){
    # Excercise 2
    $rows = Get-Rows -Path c:\temp\input11.txt
    $length = Get-RowLength -Rows $rows
    $count = Get-RowCount -Rows $rows
    [char[]]$seats = Get-AllSeats -Rows $rows
    $changeCount=0
    do{
        $seats = (Get-NextSeatingRound2 -Seats $seats -RowLength $length -RowCount $count -ChangeCount ([ref]$changeCount) -Verbose ) 
    }while( $changeCount -gt 0 )

    ($seats | Where-Object {$PSItem -eq "#"}).Count
}