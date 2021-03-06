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
    [int32] hidden $_direction
    [string] $Direction
    [void] SetNewDirection( [int32]$Angle ) {
        $this._direction = ( $this._direction + $Angle ) % 360
        if($this._direction -lt 0){
            $this._direction = 360 + $this._direction
        }
        switch($this._direction % 360 ){
            0 {
                $this.Direction = "E"
            }
            90 {
                $this.Direction = "S"
            }
            180 {
                $this.Direction = "W"
            }
            270 {
                $this.Direction = "N"
            }

        }
    }

    [void] NextPosition(
            [ShipNavigationInstruction]
            $Instruction
        ){
        switch($Instruction.Navigation){
            "F" {
                $newInstruction = New-Object -TypeName ShipNavigationInstruction
                $newInstruction.Navigation = $this.Direction
                $newInstruction.Force = $Instruction.Force
                $this.NextPosition($newInstruction)
            }
            "E" {
                $this.EastWest += $Instruction.Force
            }
            "W" {
                $this.EastWest -= $Instruction.Force 
            }
            "N" {
                $this.NorthSouth += $Instruction.Force
            }
            "S" {
                $this.NorthSouth -= $Instruction.Force 
            }
            "R" {
                $this.SetNewDirection( $Instruction.Force )
            }
            "L" {
                $this.SetNewDirection( $Instruction.Force * -1 )
            }
        }
    }
}



$instructions = Get-Instructions -Path c:\temp\input12.txt -Verbose
$position = New-Object -TypeName ShipPosition 
$position.EastWest = 0
$position.NorthSouth = 0
$position.Direction = "E"
$instructions | ForEach-Object{
    $position.NextPosition($PSItem)
}
[Math]::Abs($position.NorthSouth) + [Math]::Abs($position.EastWest)
