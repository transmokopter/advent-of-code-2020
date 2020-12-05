Function Get-SlopeHitCount {
    [CmdletBinding()]
    param (
        [int32]
        $Right,
        [int32]
        $Down
    )

    $row = 0
    $trees = @{ }
    $treeHitCount = 0

    Get-Content C:\temp\input3.txt |
    ForEach-Object{
        $col = 0
        $rowContent = $PSItem
        $row++
        $rowContent.ToCharArray() | ForEach-Object{
            if($PSItem -eq '#'){
                $trees.Add("$row-$col","#");
            }
            $col++
        }
    }
    $colCount = $col;
    $rowCount = $row;

    $currentRow=1
    $currentCol=0
    while($currentRow -le $rowCount ){
        $currentCol = ($currentCol + $Right) % $colCount
        $currentRow += $Down
        if( $trees.ContainsKey("$currentRow-$currentCol") ){
            Write-Verbose "Hit tree at $currentRow $currentCol" 
            $treeHitCount++
        }
    }
    $treeHitCount
}
# Excercise 1
$treesHit = Get-SlopeHitCount -Right 3 -Down 1 -verbose
Write-Host "We hit $treesHit trees on our way down." -ForegroundColor Cyan

# Excercise 2

$multiPlier =   (Get-SlopeHitCount -Right 1 -Down 1) * (Get-SlopeHitCount -Right 3 -Down 1) * (Get-SlopeHitCount -Right 5 -Down 1) * (Get-SlopeHitCount -Right 7 -Down 1) * (Get-SlopeHitCount -Right 1 -Down 2)
$multiPlier
