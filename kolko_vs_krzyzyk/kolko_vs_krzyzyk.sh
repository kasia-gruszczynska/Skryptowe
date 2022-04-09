#!/bin/bash
#
# 04/2022
# Katarzyna Gruszczynska
# UJ FAIS IGK
#
# Kolko vs Krzyzyk
#

gracz_O="o"
gracz_X="x"
game_terminate=false
game_mode="t"
pola=()
turn=1

chooseGameMode(){
    echo -e 'Wybierz tryb gry: \n\tt -> turowy dla 2 graczy \n\tk -> graj z komputerem'
    read mode
    if [ "$mode" == 't' ]
    then
        echo 'Tryb gry: turowy' $mode
    else
        if [ "$mode" == 'k' ]
        then
            echo 'Tryb gry: z komputerem' $mode
            game_mode="k"
        else
            echo 'Defaultowy tryb gry: turowy dla 2 graczy' $mode
        fi
    fi
}

launchGame(){
    echo 'xo-xo-xo-xo-xo-xo-xo-xo-xo-xo'
    echo 'O - Kolko vs Krzyzyk - X'
    echo -e 'Wybierz opcje: \n\tn -> rozpocznij nowa gre \n\tr -> wczytaj stan gry z pliku o podanej nazwie (resume) \n\tq -> zapisz stan gry do pliku o podanej nazwie i wyjdz (w kazdym momencie gry nacisnij "q")'

    read line

    if [ "$line" == 'q' ]
    then
        echo 'Nie mozna zapisac stanu, gra nie rozpoczeta'
        exit 0
    fi

    if [ "$line" == 'r' ]
    then
        echo 'Loading... Podaj nazwe pliku:'
        read file_name
        resumeFromFile $file_name
    fi

    if [ "$line" == 'n' ]
    then
        echo 'Nowa gra...'
        pola=( 1 2 3 4 5 6 7 8 9 )
        chooseGameMode
        printBoard
        if [ "$game_mode" == 't' ]
        then
            gameLoopTurn
        fi
        if [ "$game_mode" == 'k' ]
        then
            gameLoopAI
        fi
    fi
    echo -e '\nxo-xo-xo-xo-xo-xo-xo-xo-xo-xo'
}

printBoard(){
    echo -e '\n'
    echo -e "\t${pola[0]} | ${pola[1]} | ${pola[2]} "
    echo -e "\t-----------"
    echo -e "\t${pola[3]} | ${pola[4]} | ${pola[5]} "
    echo -e "\t-----------"
    echo -e "\t${pola[6]} | ${pola[7]} | ${pola[8]} "
    echo -e '\n'
}

playerInputTurn(){

    if [[ $(($turn % 2)) == 0 ]]
    then
        echo -n "Gracz o - wybierz pole: "
        play=$gracz_O
    else
        echo -n "Gracz x - wybierz pole: "
        play=$gracz_X
    fi

    read input

    if [ "$input" == 'q' ]
    then
        echo 'Saving... Podaj nazwe pliku:'
        read file_name
        saveToFile $file_name
        exit 0
    fi

    space=${pola[($input -1)]} 

    if [[ ! $input =~ ^-?[0-9]+$ ]] || [[ ! $space =~ ^[0-9]+$  ]]
    then 
        echo "Pole zajete lub nieistniejace"
        playerInputTurn
    else
        pola[($input -1)]=$play
        ((turn=turn+1))
    fi
    space=${pola[($input-1)]} 

}

playerInputAI(){

    if [[ $(($turn % 2)) == 0 ]]
    then
        echo -n "Gracz o - komputer "  # komputer
        play=$gracz_O
    else
        echo -n "Gracz x - wybierz pole: "  # czlowiek
        play=$gracz_X
    fi

    # echo 'play teraz' $play

    if [ $play == $gracz_X ]
    then
        # echo 'czytam input gracza x czlowiek'
        read input
    fi

    if [ "$input" == 'q' ]
    then
        echo 'Saving... Podaj nazwe pliku:'
        read file_name
        saveToFile $file_name
        exit 0
    fi

    if [ $play == $gracz_X ]
    then
        echo 'ruch gracza x czlowiek'
        space=${pola[($input -1)]} 
        if [[ ! $input =~ ^-?[0-9]+$ ]] || [[ ! $space =~ ^[0-9]+$  ]]
        then 
            echo "Pole zajete lub nieistniejace"
            playerInputAI
        else
            pola[($input-1)]=$play
            ((turn=turn+1))
        fi
        space=${pola[($input-1)]} 
    fi

    if [ $play == $gracz_O ]
    then
        echo 'ruch gracza o komputer... AI...'
        moveByAI
        local poleAI=$?
        echo 'AI wybralo pole: ' $poleAI
        #zaznacz pole 
        pola[($poleAI-1)]=$play
        #oddaj ture czowiekowi
        ((turn=turn+1))
    fi

}

moveByAI(){

    local indexpola=""

    echo 'indexpola = null ? ' $indexpola
    echo 'status pol : ' ${pola[@]}

    if [ ! -z "$indexpola" ]
    then
        echo "\$indexpola is not NULL"
    else
        echo "\$indexpola is NULL"
    fi

    checkRowOneMoreToWin 0 1 2
    indexpola=$?
    if [ "$indexpola" != 99 ]
    then
        return $indexpola
    else
    fi

    checkRowOneMoreToWin 3 4 5
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 6 7 8
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 0 4 8
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 2 4 6
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 0 3 6
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 1 4 7
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    checkRowOneMoreToWin 2 5 8
    indexpola=$?
    if [ "$indexpola" != 99 ] 
    then
        return $indexpola
    fi

    if [ $turn -gt 9 ]
    then
        echo "Brak wolnych pol - koniec gry"
        $game_terminate = true
        exit 0
    fi

    # losowe, wolne pole
    wolne=false
    while [ $wolne == false ]
    do
        indexpola=$(( $RANDOM % 9 + 1 ))
        echo 'random' $indexpola
        # sprwdzic czy niepuste i w petli to losowac
        if [ ${pola[indexpola-1]} != 'x' ] && [ ${pola[indexpola-1]} != 'o' ]
        then
            wolne=true
        fi
    done

    return $indexpola
}

checkRowSolved() {
    if [[ ${pola[$1]} == ${pola[$2]} ]] && [[ ${pola[$2]} == ${pola[$3]} ]]
    then
        game_terminate=true
        if [ ${pola[$1]} == 'x' ]
        then
            echo "Gracz x wygrywa!"
        else
            echo "Gracz o wygrywa!"
        fi
    fi
}

# czy jest rzad z 2 tymi samymi: x lub o
# i jednym pustym
# albo zwyciestwo albo blokada przeciwnika
checkRowOneMoreToWin() {
    echo 'checkRowOneMoreToWin dla ' $1 $2 $3

    # ile pustych w rzedzie
    local ile_pustych=0
    local index_pustego=99

    if [ ${pola[$1]} != 'x' ] && [ ${pola[$1]} != 'o' ]
    then
        ile_pustych=$((ile_pustych+1))
    fi
    if [ ${pola[$2]} != 'x' ] && [ ${pola[$2]} != 'o' ]
    then
        ile_pustych=$((ile_pustych+1))
    fi
    if [ ${pola[$3]} != 'x' ] && [ ${pola[$3]} != 'o' ]
    then
        ile_pustych=$((ile_pustych+1))
    fi

    echo 'ile pustych w rzedzie' $ile_pustych

    if [ $ile_pustych == 1 ]
    then
        echo 'ile_pustych == 1 ---> ' $ile_pustych
        if [[ ${pola[$1]} == ${pola[$2]} ]] || [[ ${pola[$2]} == ${pola[$3]} ]] || [[ ${pola[$1]} == ${pola[$3]} ]]
        then
            # sa 2 takie same: x lub o
            # wstaw x lub o zeby wygrac lub zablokowac przeciwnika
            # w ktore trzeba wstawic - w puste
            if [[ ${pola[$1]} == ${pola[$2]} ]]
            then 
                index_pustego=${pola[$3]}
            else   
                if [[ ${pola[$2]} == ${pola[$3]} ]] 
                then
                    index_pustego=${pola[$1]}
                else
                    index_pustego=${pola[$2]}
                fi
            fi
        fi
    fi

    echo 'checkRow OneMoreToWin puste: ' $index_pustego

    return $index_pustego
}

checkStatus(){
    echo 'checking status...'
    # if [ $game_terminate == true ]
    # then 
    #     return
    # fi
    checkRowSolved 0 1 2
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 3 4 5
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 6 7 8
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 0 4 8
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 2 4 6
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 0 3 6
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 1 4 7
    if [ $game_terminate == true ]
    then 
        return
    fi
    checkRowSolved 2 5 8
    if [ $game_terminate == true ]
    then 
        return
    fi

    if [ $turn -gt 9 ]
    then
        echo "Brak wolnych pol - koniec gry"
        $game_terminate = true
        exit 0
    fi
}

saveToFile(){
    # save a game state to a file
    arr=(1 8 6)
    echo 'Saving... zapisz do pliku: ' $1
    echo ${pola[@]} > $1
    echo " " >> $1
    echo $game_mode >> $1
    echo " " >> $1
    echo $turn >> $1
}

resumeFromFile(){
    # resume a game from state from file
    wczytaj=$(cat $1)
    echo 'Wczytane z pliku: ' $wczytaj

    # tryb gry do kontynuacji

    k=$(echo "$wczytaj" | grep "k")
    echo 'kt k' $k

    t=$(echo "$wczytaj" | grep "t")
    echo 'kt t' $t

    if [ "$k" != '' ]
    then
        game_mode='k'
        # echo 'wczytany tryb ' $game_mode
    fi
    if [ "$t" != '' ]
    then
        game_mode='t'
        # echo 'wczytany tryb ' $game_mode
    fi

    pola=($wczytaj)
    unset pola[9]  # k / t
    unset pola[10]  # tura
    echo 'Resuming...' ${pola[@]}
    printBoard

    if [ "$game_mode" == 't' ]
    then
        echo 'Kontynuuje tryb gry turowej...'
        gameLoopTurn
    else
        if [ "$game_mode" == 'k' ]
        then
            echo 'Kontynuuje tryb gry z komputerem...'
            gameLoopAI
        fi
    fi
}

gameLoopTurn(){
    echo 'Tryb gry turowej...'
    while [ $game_terminate == false ]
    do
        playerInputTurn
        printBoard
        checkStatus
    done
}

gameLoopAI(){
    echo 'Tryb gry z komputerem...'
    while [ $game_terminate == false ]
    do
        playerInputAI
        printBoard
        checkStatus
    done
}

    # start game
    launchGame

exit 0
