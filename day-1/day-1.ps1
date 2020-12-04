# Setup
# Download day 1 input to c:\temp\input1.txt

# Excercise 1
$s = @{}
Get-Content C:\Temp\input1.txt | 
 Where-Object { [int32]$PSItem -le 2020 } |
 Sort-Object -Descending |
 ForEach-Object {
    $val=$psitem
    if( $s.ContainsKey( [string] (2020 - [int32]$val) )){
        $val2 = [string] (2020 - [int32]$val)
        "$val2 plus $val = 2020" 
        [int32]$val * [int32]$val2
        break;
    }
    $s.add($val,$val)
}


# Excercise 2
$s = @{}
Get-Content C:\Temp\input1.txt | 
 Where-Object { [int32]$PSItem -le 2020 } | 
 Sort-Object -Descending |
 ForEach-Object {
    $val=$psitem
    $s.keys | ForEach-Object {
        $val2 = $PSItem
        if($s.ContainsKey( [string](2020 - [int32]$val - [int32]$val2 ))){
            $val3 = [string]( 2020 - [int32]$val - [int32]$val2 )
            "$val3 plus $val plus $val2 = 2020"
            [int32]$val3 * [int32]$val * [int32]$val2
            break
        }
    }
$s.add($val,$val)
}

