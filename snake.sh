#!/usr/bin/env bash
clear
tput civis # Stop blinking cursor
if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi # Set bash to non-blocking mode

# Define dimensions of the field
width=$(($(tput cols)-1))
height=$(($(tput lines)-2))

# Define starting position for the snake
snake=("$(($width/2)),$(($height/2)), $(($width/2-1)),$(($height/2)), $(($width/2-2)),$(($height/2))")

# Some starting variables
dir="right"
speed=0
keypress=''
score=0
fruits=(🍎 🍏 🍇 🍈 🍉 🍊 🍋 🍌 🍍 🍐 🍑 🍒 🍓)

# Display some game information, used for debugging
debug () {
  tput cup 0 0
  printf "Field: ${width},${height} Player: $(echo ${snake[0]} | cut -d, -f1),$(echo ${snake[0]} | cut -d, -f2) Direction: $dir Food: $food     \n"
  printf "Snake length ${#snake[@]}, def: ${snake[*]}, last: $last          "
}

# Prints something on the third line. Used for debugging.
print () {
  tput cup 3 0
  printf "                                         "
  tput cup 3 0
  printf "$1"
}

# Prints the score in the bottom left of the screen
score () {
  score=$(($score+1))
  tput cup $height 0
  printf $score
}

# Check if $1 is in array $2. Used for collision detection and eating fruits
checkHit () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

renderSnake () {
  # Draw the snake by only drawing its head
  tput cup $(echo ${snake[0]} | cut -d, -f2) $(echo ${snake[0]} | cut -d, -f1)
  printf ■
  # Remove the butt from last draw
  tput cup $(echo $last | cut -d, -f2) $(echo $last | cut -d, -f1)
  printf ' '
}

# Defines the new position of the head and removes its tail if it hasn't eaten
moveSnake () {
  last=${snake[${#snake[@]}-1]}
  length=${#snake[*]}
  if [ $dir == right ]; then # Moving right
    if [[ $(($(echo ${snake[0]} | cut -d, -f1)+1)) -le $width ]]; then
      newpart="$(($(echo ${snake[0]} | cut -d, -f1)+1)),$(echo ${snake[0]} | cut -d, -f2)"
    else
      newpart="0,$(echo ${snake[0]} | cut -d, -f2)"
    fi
  elif [ $dir == left ]; then # Moving left
    if [[ $(($(echo ${snake[0]} | cut -d, -f1)-1)) -ge 0 ]]; then
      newpart="$(($(echo ${snake[0]} | cut -d, -f1)-1)),$(echo ${snake[0]} | cut -d, -f2)"
    else
      newpart="$width,$(echo ${snake[0]} | cut -d, -f2)"
    fi
  elif [ $dir == up ]; then # Moving up
    if [[ $(($(echo ${snake[0]} | cut -d, -f2)-1)) -ge 0 ]]; then
      newpart="$(echo ${snake[0]} | cut -d, -f1),$(($(echo ${snake[0]} | cut -d, -f2)-1))"
    else
      newpart="$(echo ${snake[0]} | cut -d, -f1),$height"
    fi
  elif [ $dir == down ]; then # Moving down
    if [[ $(($(echo ${snake[0]} | cut -d, -f2)+1)) -le $height ]]; then
      newpart="$(echo ${snake[0]} | cut -d, -f1),$(($(echo ${snake[0]} | cut -d, -f2)+1))"
    else
      newpart="$(echo ${snake[0]} | cut -d, -f1),0"
    fi
  fi
  if checkHit "$newpart" "${snake[@]}"; then
    die # It has hit itself here
  fi
    snake=($newpart ${snake[@]})
  if checkFood || [ "$grow" == 1 ]; then
    unset grow
  else
    unset 'snake[${#snake[@]}-1]'
  fi
}

# Draws the fruit. If the position overlaps with the snake array, it calls itself to define a new position and draw it.
drawFood () {
  food="$((RANDOM%$width)),$((RANDOM%$height))"
  tput cup $(echo $food | cut -d, -f2) $(echo $food | cut -d, -f1)
  printf ${fruits[$RANDOM % ${#fruits[*]} ]}
  if checkHit "$food" "${snake[@]}"; then
    drawFood
  fi
}

# Checks if the head is at the position of the food, if so, increase the score and draw new food.
checkFood () {
  if [[ "${snake[0]}" == "$food" ]]; then
    score
    drawFood
    return 0
  fi
  return 1
}

# Stop the game and reset the terminal
stop () {
  if [ -t 0 ]; then stty sane; fi
  tput reset
  exit 0
}

# Die, reset the terminal to display some sad text and stop the game.
die () {
  tput reset
  tput civis
  tput cup $(($height/2)) $(($width/2-10))
  printf "🥺 You've died... 🥺"
  sleep 3
  stop
}

# The gameloop which reads the key input. Uncomment debug to show debugging information. Note the g key which makes the snake grow.
game () {
  while :; do
    # debug
    renderSnake
    moveSnake
    sleep $speed
    read keypress
    if [ "$keypress" == 'i' ]; then
      if [ "$dir" != "down" ]; then dir="up"; fi
    elif [ "$keypress" == 'k' ]; then
      if [ "$dir" != "up" ]; then dir="down"; fi
    elif [ "$keypress" == 'j' ]; then
      if [ "$dir" != "right" ]; then dir="left"; fi
    elif [ "$keypress" == 'l' ]; then
      if [ "$dir" != "left" ]; then dir="right"; fi
    elif [ "$keypress" == "q" ]; then
      stop
    elif [ "$keypress" == "g" ]; then
      grow=1
    elif [ "$keypress" == "" ]; then
      echo
    fi
  done
}

# The function calls to set up the game
drawFood
game
