$acc = 0
$instruction = 0
$program = Get-Content c:\temp\input8.txt 
$executionHistory = @{}

# Excercise 1
while(-not $executionHistory.ContainsKey($instruction)){
    $executionHistory.Add($instruction,$instruction)
    $currentCommand = $program[$instruction].Split(" ")[0]
    $currentArgument = $program[$instruction].Split(" ")[1]
    switch($currentCommand){
        "jmp"{
            $instruction += $currentArgument
        }
        "nop"{
            $instruction++
        }
        "acc"{
            $acc += $currentArgument
            $instruction++
        }
    }
}
$acc


# Excercise 2
$acc = 0
$instruction = 0
$program = Get-Content c:\temp\input8.txt 
$executionHistory = @{}

while(-not $executionHistory.ContainsKey($instruction) -and $program[$instruction] ){
    $executionHistory.Add($instruction,$instruction)
    $currentCommand = $program[$instruction].Split(" ")[0]
    $currentArgument = $program[$instruction].Split(" ")[1]
    switch($currentCommand){
        "jmp"{
            if( $executionHistory.ContainsKey($instruction+$currentArgument)){
                Write-Host "Changing jmp at instruction $instruction to nop"
                $instruction++;
            }else{
                $instruction += $currentArgument
            }
        }
        "nop"{
            $instruction++
        }
        "acc"{
            $acc += $currentArgument
            $instruction++
        }
    }
}
$acc