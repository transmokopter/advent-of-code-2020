Function Get-IsValidPassport{
    [CmdletBinding()]
    param (
        [hashtable]
        $Passport,
        [string[]]
        $RequiredKeys
    )
    $b = $true
    $RequiredKeys | ForEach-Object{
        $b = $b -and $Passport.ContainsKey($PSItem)
        Write-Verbose "Key $PSItem is in passport: $b"
    }
    $b
}

Function Get-IsValidKeyValue{
    [CmdletBinding()]
    param(
        [string]
        $Key,
        [string]
        $Value
    )
    switch ($Key) {
        "byr" { 
            [int32]$Value -ge 1920 -and [int32]$Value -le 2002
         }
         "iyr" { 
            [int32]$Value -ge 2010 -and [int32]$Value -le 2020
         }
         "eyr" { 
            [int32]$Value -ge 2020 -and [int32]$Value -le 2030
         }
         "hgt" { 
            $matchGroups = ($Value | Select-String -Pattern "([0-9]+)([a-zA-Z]*)").Matches.Groups
            $matchGroups.Count -eq 3 -and 
                (
                    (
                        $matchGroups[2].Value -eq "cm" -and 
                        [int32]$matchGroups[1].value -ge 150 -and 
                        [int32]$matchGroups[1].Value -le 193
                    ) -or 
                    (
                        $matchGroups[2].Value -eq "in" -and 
                        [int32]$matchGroups[1].value -ge 59 -and 
                        [int32]$matchGroups[1].Value -le 76
                    )
                )
         }
         "hcl" { 
            $matchGroups = ($Value | Select-String -Pattern "(#)([0-9a-fA-F]+)" -AllMatches).Matches.Groups
            $matchGroups.Count -eq 3 -and $matchGroups[2].Value.Length -eq 6
         }
         "ecl" { 
            [string[]]$approvedColors = "amb","blu","brn","gry","grn","hzl","oth"
            $approvedColors.Contains($Value)
         }
         "pid" { 
            $Value.Length -eq 9 -and ($Value | Select-String -Pattern "([0-9]+)").Matches.Groups[1].Value.Length -eq 9
         }

        Default { $true }
    }
}

Function Load-Passports{
    [CmdletBinding()]
    param(
        [string]
        $Path,
        [string[]]
        $RequiredKeys
    )
    $passports = @{ }
    $currentPassportNumber = 0
    $currentPassport = @{ }
    Get-Content $Path | ForEach-Object{
        if ($PSItem -eq ""){
            if( Get-IsValidPassport -Passport $currentPassport -RequiredKeys $RequiredKeys ){
                $currentPassportNumber++
                $passports.Add( "$currentPassportNumber", $currentPassport )
            }
            $currentPassport = @{ }
        } else {
            $rowFields = $PSItem.Split(" ")
            $rowFields | ForEach-Object{
                Write-Verbose $PSItem 
                $keyValue = $PSItem.Split(":")
                if( Get-IsValidKeyValue -Key $KeyValue[0] -Value $KeyValue[1]){
                    $currentPassport.Add($keyValue[0],$keyValue[1])
                }
            }
        }
    }
    if($currentPassport.Keys.Count -ge 1){
        if( Get-IsValidPassport -Passport $currentPassport -RequiredKeys $RequiredKeys ) {
            $currentPassportNumber++
            $passports.Add("$currentPassportNumber",$currentPassport)
        }
    }
    $passports
}

[string[]]$allRequiredKeys = "byr","iyr","eyr","hgt","hcl","ecl","pid"

$allPassports = Load-Passports -Path C:\temp\input4.txt -RequiredKeys $allRequiredKeys

$validPassportCount = $allPassports.Values.Count

Write-Host "We have $validPassportCount valid passports" -ForegroundColor Green 

