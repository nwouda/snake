About
---------------
Snake. In Bash.

How to play
---------------
i=up, j=left, k=down, l=right
q=quit
This game is borderless, which means once you get to an edge, the snake warps to the other side of the field. Also, like regular snake, once you bite yourself, you die.

How it works
---------------
The snake is actually defined as an array of x and y positions, which on each iteration get increased in the direction of the snake. The game uses `tput` for drawing the snake. It only writes the new position of the head, and removes the tail on each draw. Once written, a character will stay there until overwritten. When eating, the tail doesn't get removed from the array.

On each move, the moveSnake function checks for a collision with itself and if it is on the same position as the fruit.
