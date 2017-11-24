###########################################################################
#
# Script Name: TTTvsComp.ps1
# Version:     3.0
# Author:      Jason Radebaugh
# Date:        February 12, 2016
# 
# Description: This PowerShell script is a single player Tic-Tac-Toe game.
#              Good luck beating it!!
# 
###########################################################################

############################ Begin Object - Board #####################################################
#Create an object which is the TicTacToe game board, asign it 9 properties representing the squares
$board = New-Object -TypeName PSObject
foreach ($square in "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9") {
    $board | Add-Member -NotePropertyName $square -NotePropertyValue " "
}
$board | Add-Member -NotePropertyName moveCount -NotePropertyValue 0 

#Create and add methods to the board object
#This method allows players to make moves.. Call with $board.MakeMove(player, move)
$makeMove = {
    param([string]$curPlayer, [string]$theMove)
    if (($board.($theMove) -ne "X") -and ($board.($theMove) -ne "O")) {
        $board.($theMove) = $curPlayer
        return $true
    }
    else { return $false }
}
$board | Add-Member -MemberType ScriptMethod -Name MakeMove -Value $makeMove

#This method checks for a winner.. Call after every play with $board.CheckWin(player)
$checkWin = {
    param([string]$curPlayer)
    $winCondition = @(    #Create an array of the 8 possible win combinations
    @($board.b7, $board.b8, $board.b9),
    @($board.b4, $board.b5, $board.b6),
    @($board.b1, $board.b2, $board.b3),
    @($board.b7, $board.b4, $board.b1),
    @($board.b8, $board.b5, $board.b2),
    @($board.b9, $board.b6, $board.b3),
    @($board.b7, $board.b5, $board.b3),
    @($board.b9, $board.b5, $board.b1))
    $i = 0
    foreach($win in $winCondition) {
        if (($winCondition[$i][0] -eq $curPlayer) -and ($winCondition[$i][1] -eq $curPlayer)`
         -and ($winCondition[$i][2] -eq $curPlayer)) {
            return $true
        }
        $i++
}}
$board | Add-Member -MemberType ScriptMethod -Name CheckWin -Value $checkWin

#This method checks for a tie Call after every play with $board.CheckTie()
$checkTie = {
    $board.moveCount += 1
    if ($board.moveCount -eq 9) { return $true }
}
$board | Add-Member -MemberType ScriptMethod -Name CheckTie -Value $checkTie

#This method clears the board for the next game.. Call with $board.ClearBoard()
$clearBoard = {
    $placeHold = 0
    foreach ($square in "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9") {
        $placeHold++
        $board.$square = $placeHold
    }
    $board.moveCount = 0
}
$board | Add-Member -MemberType ScriptMethod -Name ClearBoard -Value $clearBoard

#This method displays the board.. Call with $board.DisplayBoard()
$displayBoard = {
    Write-Host "`n`n                          T I C  -  T A C  - T O E`n`n"
    Write-Host ""  
    Write-Host "                                 |       |"
    Write-Host "                            "$board.b7"  |  "$board.b8"  |  "$board.b9
    write-Host "                                 |       |"
    Write-Host "                           ------|-------|------"
    Write-Host "                                 |       |"   
    Write-Host "                            "$board.b4"  |  "$board.b5"  |  "$board.b6 
    Write-Host "                                 |       |" 
    Write-Host "                           ------|-------|------" 
    Write-Host "                                 |       |" 
    Write-Host "                            "$board.b1"  |  "$board.b2"  |  "$board.b3
    Write-Host "                                 |       |"
}
$board |Add-Member -MemberType ScriptMethod -Name DisplayBoard -Value $displayBoard

#This method is used by the computer when deciding on a move
 $counterMove = {
    param([string]$player, [string]$oponent)
    $winState = @(    #Create an array of the 8 possible win combinations
    @(@("b7", $board.b7), @("b8", $board.b8), @("b9", $board.b9)),
    @(@("b4", $board.b4), @("b5", $board.b5), @("b6", $board.b6)),
    @(@("b1", $board.b1), @("b2", $board.b2), @("b3", $board.b3)),
    @(@("b7", $board.b7), @("b4", $board.b4), @("b1", $board.b1)),
    @(@("b8", $board.b8), @("b5", $board.b5), @("b2", $board.b2)),
    @(@("b9", $board.b9), @("b6", $board.b6), @("b3", $board.b3)),
    @(@("b7", $board.b7), @("b5", $board.b5), @("b3", $board.b3)),
    @(@("b9", $board.b9), @("b5", $board.b5), @("b1", $board.b1)))
    $winNumber = 0
    foreach ($win in $winState) {
            $winNumber++
            $blockNum = 0
            $value = 0
            foreach ($block in $win) {
                $blockNum++
		        if ($block[1] -eq $player) {
                    $value = $value + 1
                }
                elseif ($block[1] -eq $oponent) {
                    $value = $value - 1
                }
                else { $value = $value }
	        }
            if ($value -eq 2) {
                foreach ($block in $win) {
                    if ($block[1] -ne "X" -and $block[1] -ne "O") {
                        return $block[0]
}}}}}
$board | Add-Member -MemberType ScriptMethod -Name CounterMove -Value $counterMove
############################ End of Object - Board ####################################################

############################ Begin Object - Human Player ##############################################
#Create an Object which is the Human Player
$player1 = New-Object -TypeName PSObject
$player1 | Add-Member -NotePropertyName name -NotePropertyValue "Player 1"
$player1 | Add-Member -NotePropertyName marker -NotePropertyValue "X"

#This method sets the name of the player.. Call with $player1.SetName()
$setName = {
    $name = Read-Host $this.name" enter your name"
    
    if ($name -ne "") {
        $this.name = $name
}}
$player1 | Add-Member -MemberType ScriptMethod -Name SetName -Value $setName

#This method sets the players marker.. Call with $player1.SetMarker(X or O)
$setMarker = {
     param([string]$marker)
    $marker = $marker.ToUpper()
    if (($marker -eq "X") -or ($marker -eq "O")) {
        $this.marker = $marker }
    else { $this.marker = "X" }
}
$player1 | Add-Member -MemberType ScriptMethod -Name SetMarker -Value $setMarker

#This method allows the player to choose a move
$chooseMove = {
    $move = " "
    do {
        Write-Host "`nPress the key that corresponds to the square you want to play."
        $key = [Console]::ReadKey("NoEcho")
        Switch ($key.KeyChar) {
            1 { $move = "b1"; break }
            2 { $move = "b2"; break }
            3 { $move = "b3"; break }
            4 { $move = "b4"; break }
            5 { $move = "b5"; break }
            6 { $move = "b6"; break }
            7 { $move = "b7"; break }
            8 { $move = "b8"; break }
            9 { $move = "b9"; break }
        }
    } until ($move -match "b[1-9]")
    return $move
}
$player1 | Add-Member -MemberType ScriptMethod -Name ChooseMove -Value $chooseMove
############################ End of Object - Human Player #############################################

############################ Begin Object - Computer Player ###########################################
#Create an Object which is the Computer Player
$computer = New-Object -TypeName PSObject
$computer | Add-Member -NotePropertyName name -NotePropertyValue "Skynet"
$computer | Add-Member -NotePropertyName marker -NotePropertyValue ""
   
#This sets the marker for the computer player.. Call with $computer.SetMarker()   
$setMarker = {
    if ($player1.marker -eq "X") {
        $computer.marker = "O"
    }
    else { $computer.marker = "X" }
}
$computer | Add-Member -MemberType ScriptMethod -Name SetMarker -Value $setMarker

#This method chooses the computers move.. Call with $computer.ChooseMove($computer.name, $player1.name)
$chooseMove = {
    param([string]$comp, [string]$person)
    $move = ""
    $plays = @("b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9")
    $move = $board.CounterMove($comp, $person)
    if ($plays -notcontains $move) {
        $move = $board.CounterMove($person, $comp) }
    if (($plays -notcontains $move) -and ($board.b7 -eq $person -and $board.b3 -eq $person) -and ($board.b2 -ne "X" -and $board.b2 -ne "O")) {
        $move = "b2" }
    if (($plays -notcontains $move) -and ($board.b9 -eq $person -and $board.b1 -eq $person) -and ($board.b6 -ne "X" -and $board.b6 -ne "O")) {
        $move = "b6" }
    if (($plays -notcontains $move) -and ($board.b2 -eq $person -and $board.b6 -eq $person) -and ($board.b9 -ne "X" -and $board.b9 -ne "O")) {
        $move = "b9" }
    if (($plays -notcontains $move) -and ($board.b5 -ne "X" -and $board.b5 -ne "O")) {
        $move = "b5" }
    if (($plays -notcontains $move) -and ($board.b7 -ne "X" -and $board.b7 -ne "O")){
        $move = "b7" }
    if (($plays -notcontains $move) -and ($board.b3 -ne "X" -and $board.b3 -ne "O")){
        $move = "b3" }
    if (($plays -notcontains $move) -and ($board.b9 -ne "X" -and $board.b9 -ne "O")){
        $move = "b9" }
    if (($plays -notcontains $move) -and ($board.b1 -ne "X" -and $board.b1 -ne "O")){
        $move = "b1" }
    if (($plays -notcontains $move) -and ($board.b8 -ne "X" -and $board.b8 -ne "O")){
        $move = "b8" }
    if (($plays -notcontains $move) -and ($board.b6 -ne "X" -and $board.b6 -ne "O")){
        $move = "b6" }
    if (($plays -notcontains $move) -and ($board.b2 -ne "X" -and $board.b2 -ne "O")){
        $move = "b2" }
    if (($plays -notcontains $move) -and ($board.b4 -ne "X" -and $board.b4 -ne "O")){
        $move = "b4" }
    return $move
}
$computer | Add-Member -MemberType ScriptMethod -Name ChooseMove -Value $chooseMove

######################### End of Object - Computer Player #############################################

############################ Functions for game play ##################################################
function Open-Screen {  #Displays the opening screen
    Write-Host "`n                                Welcome to`n"
    $board.DisplayBoard()
    Write-Host "`n`n Let's get started. First, we'll set up the players."
    Read-Host "`n`nPress Enter to continue."
}

function Create-Player2 {  #This function creates Player 2 and sets default properties...NOT USED IN THIS VERSION
        $script:player2 = $player1.PSObject.copy()
        $script:player2.name = "Player 2"
    if ($player1.marker -eq "X") {
        $script:player2.SetMarker("O")
    }
    else { $script:player2.SetMarker("X") }
}

function Next-Turn {   #This function alternates turns
    if ($currentPlayer -eq $player1.name) {
        $script:currentPlayer = $computer.name
        $script:currentMarker = $computer.marker
    }
    elseif ($currentPlayer -eq $computer.name) {
        $script:currentPlayer = $player1.name
        $script:currentMarker = $player1.marker
}}
########################### End of Functions #########################################################


########################### Play the game ############################################################

#Set up for the first game
Clear-Host
Open-Screen
$keepPlaying = $true #declare/initialize variable that keeps game going until players decide to quit
$player1.SetName()
$tempMarker = Read-Host $player1.name ", do you want to play as X or O?" 
$player1.SetMarker($tempMarker)
$computer.SetMarker()
$currentPlayer = $player1.name
$currentMarker = $player1.marker

 do { #Loop the game until players decide to quit
    $board.ClearBoard()
    $gameOver = $false

    while ($gameOver -ne $true) { #loop play until the game is won or tied
    if ($currentPlayer -eq $player1.name) {
        do {
            Clear-Host
            $board.DisplayBoard()
            Write-Host "`n $currentPlayer, it's your turn"
            $nextMove = $board.MakeMove($currentMarker, $player1.ChooseMove())
        } while ($nextMove -ne $true)
     }
     elseif ($currentPlayer -eq $computer.name) {
        do {
            Clear-Host
            $board.DisplayBoard()
            $nextMove = $board.MakeMove($currentMarker, $computer.ChooseMove($computer.marker, $player1.marker))
        } while ($nextMove -ne $true)
     }
        Clear-Host
        $board.DisplayBoard()
        $gameOver = $board.CheckWin($currentMarker)
        if ($gameOver -eq $true) {
            Write-Host $currentPlayer" is the WINNER!!"
            Read-Host "`n`nPress Enter to continue."
        }
        else {
            $gameOver = $board.CheckTie()
            if ($gameOver -eq $true) {
                Write-Host "The game is a Draw."
                Read-Host "`n`nPress Enter to continue"
            }
    }
    Next-Turn
} 
   do {     #Give players the option to play again or quit after each game
        Clear-Host
        $playAgain = Read-Host "`n`nDo you want to play again? Enter Y or N."
        $playAgain = $playAgain.ToUpper()
        if ($playAgain -eq "Y") {
            $keepPlaying = $true}
        elseif ($playAgain -eq "N") {
            $keepPlaying = $false}
    } while ($playAgain -ne "Y" -and $playAgain -ne "N")
	
} while ($keepPlaying -eq $true)