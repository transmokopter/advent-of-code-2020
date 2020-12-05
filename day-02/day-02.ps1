# Excercise 1
$goodPasswordCount = 0
$badPasswordCount = 0
Get-Content C:\Temp\input2.txt | 
 ForEach-Object {
     $matchGroups = ($PSItem | Select-String -Pattern "([0-9]+)-([0-9]+) ([a-zA-Z]): ([a-zA-Z]+)").Matches.Groups
     $low = [int32] $matchGroups[1].Value 
     $high = [int32] $matchGroups[2].Value 
     $char = $matchGroups[3].Value 
     $password = $matchGroups[4].Value 
     $matchCount = ($password | Select-String -Pattern "[$char]" -AllMatches).Matches.Count
     
     if( $matchCount -ge $low -and $matchCount -le $high ){
        Write-Host "Good password '$password'. Match count $matchCount. Required: $char matched $low - $high times" -ForegroundColor Green
        $goodPassWordCount++
    } else {
        Write-Host "Bad password '$password'. Match count $matchCount. Required: $char matched $low - $high times" -ForegroundColor Red
        $badPasswordCount++
    }
}
Write-Host "
Number of good passwords: $goodPasswordCount
Number of bad passwords: $badPasswordCount
"


# Excercise 2
$goodPasswordCount = 0
$badPasswordCount = 0
Get-Content C:\Temp\input2.txt | 
 ForEach-Object {
    $matchGroups = ($PSItem | Select-String -Pattern "([0-9]+)-([0-9]+) ([a-zA-Z]): ([a-zA-Z]+)").Matches.Groups
    $first = [int32] $matchGroups[1].Value 
    $second = [int32] $matchGroups[2].Value 
    $char = $matchGroups[3].Value 
    $password = $matchGroups[4].Value 
    $matchCount = 0
    if( $password.Length -ge $first -and $password.Substring($first - 1,1) -eq $char ){
        $matchCount++
    }
    if( $password.Length -ge $second -and $password.Substring($second - 1,1) -eq $char ){
        $matchCount++
    }
     
    if( $matchCount -eq 1 ){
        Write-Host "Good password '$password'. Required $char at positions $first or $second matched exactly once" -ForegroundColor Green
        $goodPassWordCount++
    } else {
        Write-Host "Bad password '$password'. Required $char at positions $first or $second not matched exactly once ($matchCount) " -ForegroundColor Red
        $badPasswordCount++
    }
}
Write-Host "
Number of good passwords: $goodPasswordCount
Number of bad passwords: $badPasswordCount
"
