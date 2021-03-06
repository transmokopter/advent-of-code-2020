Function Get-UniqueAnswerCount{
    [CmdletBinding()]
    param(
        [string]
        $Answers
    )
    ( $Answers.ToCharArray() | Sort-Object -Unique ).Count
}

Function Get-AnswersUnion{
    [CmdletBinding()]
    param(
        [string]
        $Path
    )
    $currentGroupAnswers = ""
    $distinctAnswerCount = 0
    Get-Content $Path |
     Foreach-Object {
         if( $PSItem -eq "" ) {
            $distinctAnswerCount = $distinctAnswerCount + ( Get-UniqueAnswerCount -Answers $currentGroupAnswers )
            $currentGroupAnswers = ""
         } else {
            $currentGroupAnswers = $currentGroupAnswers + $PSItem 
         }
     }
     if( $currentGroupAnswers -ne "" ) {
        $distinctAnswerCount = $distinctAnswerCount + ( Get-UniqueAnswerCount -Answers $currentGroupAnswers )
     }
     $distinctAnswerCount
}

Function Get-AnswersIntersect{
    [CmdletBinding()]
    param(
        [string]
        $Path
    )
    $isNewGroup = $true 
    [char[]] $currentGroupAnswers = @()
    $distinctAnswerCount = 0
    Get-Content $Path |
     Foreach-Object {
         if( $PSItem -eq "" ) {
            Write-Verbose ("Group separator found. $currentGroupAnswers count is " + $currentGroupAnswers.Count)
            $distinctAnswerCount = $distinctAnswerCount + $currentGroupAnswers.Count
            [char[]]$currentGroupAnswers = @()
            $isNewGroup = $true 
         } else {
            if( $isNewGroup ){ 
                Write-Verbose "Found first in group $PSItem"
                $currentGroupAnswers = [char[]]$PSItem.ToCharArray()
                $isNewGroup = $false  
            } 
            [string]$currentAnswer = $PSItem 
            $currentGroupAnswers = ([char[]]( $currentGroupAnswers | Where-Object {
                $currentAnswer.ToCharArray() -Contains $PSItem 
            } ))
         }
     }
     if( $currentGroupAnswers.Count -gt 0 ) {
         Write-Verbose ("Supposedly last group in file, $currentgroupanswers count is " + $currentGroupAnswers.Count)
        $distinctAnswerCount = $distinctAnswerCount + $currentGroupAnswers.Count
     }
     $distinctAnswerCount
}


Get-AnswersUnion -Path C:\temp\input6.txt
Get-AnswersIntersect -Path C:\temp\input6.txt