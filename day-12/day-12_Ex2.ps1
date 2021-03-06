Class ShipNavigationInstruction{
    [string] $Navigation
    [int32]  $Force 
}


Function Get-Instructions{
    [CmdletBinding()]
    param(
        [string]
        $Path
    )
    Get-Content -Path $Path | ForEach-Object{
        $matchGroups = ($PSItem | Select-String -Pattern "([A-Z])([0-9]+)").Matches.Groups
        [ShipNavigationInstruction]$i = New-Object -TypeName ShipNavigationInstruction
        $i.Navigation = $matchGroups[1].Value
        $i.Force = $matchGroups[2].Value
        $i
    }
}

Class ShipPosition{
    [int32] $EastWest 
    [int32] $NorthSouth
    [int32] $WaypointEastWest
    [int32] $WaypointNorthSouth
    
    [void] RotateWaypoint( [int32]$Angle ) {

        if( $Angle -lt 0 ){
            $Angle += 360
        }

        switch( $Angle % 360 ){
            90 {
                $newEastWest =  $this.WaypointNorthSouth
                $this.WaypointNorthSouth = -1 * $this.WaypointEastWest
                $this.WaypointEastWest = $newEastWest
            }
            180 {
                $this.WaypointEastWest = $this.WaypointEastWest * -1
                $this.WaypointNorthSouth = $this.WaypointNorthSouth * -1
            }
            270 {
                $newEastWest =  $this.WaypointNorthSouth
                $this.WaypointNorthSouth = $this.WaypointEastWest
                $this.WaypointEastWest = -1 * $newEastWest
                
            }

        }
    }

    [void] NextPosition(
            [ShipNavigationInstruction]
            $Instruction
        ){
        switch($Instruction.Navigation){
            "F" {
                $this.EastWest += ( $Instruction.Force * $this.WaypointEastWest )
                $this.NorthSouth += ( $Instruction.Force * $this.WaypointNorthSouth )
            }
            "E" {
                $this.WaypointEastWest += $Instruction.Force
            }
            "W" {
                $this.WaypointEastWest -= $Instruction.Force 
            }
            "N" {
                $this.WaypointNorthSouth += $Instruction.Force
            }
            "S" {
                $this.WaypointNorthSouth -= $Instruction.Force 
            }
            "R" {
                $this.RotateWaypoint( $Instruction.Force )
            }
            "L" {
                $this.RotateWaypoint( $Instruction.Force * -1 )
            }
        }
    }
}



$instructions = Get-Instructions -Path c:\temp\input12.txt -Verbose
$position = New-Object -TypeName ShipPosition 
$position.WaypointNorthSouth = 1
$position.WaypointEastWest = 10
$position.EastWest = 0
$position.NorthSouth = 0
$instructions | ForEach-Object{
    $position.NextPosition($PSItem)
}
[Math]::Abs($position.NorthSouth) + [Math]::Abs($position.EastWest)
