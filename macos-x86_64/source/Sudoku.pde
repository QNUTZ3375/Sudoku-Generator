import java.util.Arrays;
import java.util.Set;
import java.util.HashSet;
int cols = 9;
int rows = 9;
int cellSize = 60;
int xStartPos = 80;
int yStartPos = 80;
int yCandidatePos = 25 + 2 * yStartPos + rows * cellSize;
int currX = 0;
int currY = 0;
boolean isOnCell = false;
Cell[][] board = new Cell[cols][rows];
int[][] candidates = new int[cols][2];
PFont mainCandidateFont;
PFont amountOfCandidatesLeft;
PFont smallCandidate;
PFont timerFont;
PFont difficultyFont;
int[][] solution = new int[cols][rows];
String[] allSolutions = {};
String[] currSolution = new String[cols * rows];
int finalDiff = 0;
int currBranches = 0;
int emptySpaces = 0;
boolean candidateMode = false;
boolean finishedPuzzle = false;
int puzzleState = 0; //determines whether the puzzle equals the solution; 1 = correct, -1 = incorrect
float threshold = 0.7; //represents the threshold for how many clues to be removed vs added, 0 = always add, 1 = always remove
int timer = 0;
boolean showDifficulty = false;
int maxDiff = 500;


void resetBoard(){
  puzzleState = 0;
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j].reset();
    }
  }
}

void checkBoardState(){
  finishedPuzzle = true;
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[i][j].num != solution[i][j]){
        println(board[i][j].num, solution[i][j], i, j);
        finishedPuzzle = false;
        puzzleState = -1;
        return;
      }
    }
  }
  puzzleState = 1;
  return;
}

void generateRemainingDigits(){
  for(int i = 0; i < candidates.length; i++){
    candidates[i][1] = 9;
  }
  
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[i][j].num > 0){
        candidates[board[i][j].num - 1][1]--;
      }
    }
  }
}

int[][] copySolution(int[][] toCopyTo){
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      toCopyTo[i][j] = board[i][j].num;
    }
  }
  return toCopyTo;
}

void highlightSameNumbers(int x, int y){
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[x][y].num == board[i][j].num){
        fill(255, 0, 255, 100);
        square(xStartPos + i * cellSize, yStartPos + j * cellSize, cellSize);
      }
      for(int k = 0; k < board[x][y].candidateArr.length; k++){
        if(board[i][j].candidateArr[k] && k + 1 == board[x][y].num){
          fill(200, 100, 0, 150);
          int defaultX = xStartPos + i * cellSize;
          int defaultY = yStartPos + j * cellSize;
          square(defaultX + cellSize/12 + (k % 3) * cellSize/3, defaultY + cellSize/12 + (k/3) * cellSize/3, cellSize/6 + 2);
        }
      }
    }
  }
}

void highlightRowColumnBox(int x, int y){
  fill(0, 250, 250, 100);
  noStroke();
  for(int i = 0; i < cols/3; i++){
    if(y < i * 3 || y >= i * 3 + rows/3){
      rect(xStartPos + x * cellSize, yStartPos + i * 3 * cellSize, cellSize, cols/3 * cellSize); //column
    }
    if(x < i * 3 || x >= i * 3 + cols/3){
      rect(xStartPos + i * 3 * cellSize, yStartPos + y * cellSize, rows/3 * cellSize, cellSize);
    }
  }
  rect(xStartPos + (x/3 * 3) * cellSize, yStartPos + (y/3 * 3) * cellSize, cellSize * cols/3, cellSize * rows/3);
}

void showCandidates(){
  if(candidateMode){
    noStroke();
    fill(0, 255, 200, 100);
    rect(0, 2 * yStartPos + rows * cellSize, 2 * xStartPos + cols * cellSize, height - 2 * yStartPos + rows * cellSize);
  }
  stroke(0);
  strokeWeight(2);
  line(0, 2 * yStartPos + rows * cellSize, 2 * xStartPos + cols * cellSize, 2 * yStartPos + rows * cellSize);
  line(xStartPos, yCandidatePos + cellSize, xStartPos + cols * cellSize, yCandidatePos + cellSize);
  strokeWeight(1);
  for(int i = 0; i < candidates.length - 1; i++){
    line(xStartPos + (i + 1) * cellSize, yCandidatePos, xStartPos + (i + 1) * cellSize, yCandidatePos + 2 * cellSize);
  }
  fill(0);
  for(int i = 0; i < candidates.length; i++){
    textFont(mainCandidateFont, 40);
    text(candidates[i][0], xStartPos + i * cellSize + cellSize/2, yCandidatePos + cellSize/2);
    textFont(amountOfCandidatesLeft, 40);
    text(candidates[i][1], xStartPos + i * cellSize + cellSize/2, yCandidatePos + cellSize + cellSize/2);
  }
}

void drawBoardOutline(){
  noFill();
  strokeWeight(2);
  stroke(0);
  rect(xStartPos, yStartPos, cols * cellSize, rows * cellSize);
  line(xStartPos + cols * 1/3 * cellSize, yStartPos, xStartPos + cols * 1/3 * cellSize, yStartPos + rows * cellSize);
  line(xStartPos + cols * 2/3 * cellSize, yStartPos, xStartPos + cols * 2/3 * cellSize, yStartPos + rows * cellSize);
  line(xStartPos, yStartPos + rows * 1/3 * cellSize, xStartPos + cols * cellSize, yStartPos + rows * 1/3 * cellSize);
  line(xStartPos, yStartPos + rows * 2/3 * cellSize, xStartPos + cols * cellSize, yStartPos + rows * 2/3 * cellSize);
}

void setup(){
  size(1000, 870);
  mainCandidateFont = createFont("HelveticaNeue", cellSize * 2/3, true);
  amountOfCandidatesLeft = createFont("HelveticaNeue-Light", cellSize * 2/3, true);
  smallCandidate = createFont("HelveticaNeue-Light", cellSize / 5, true);
  timerFont = createFont("HelveticaNeue-Thin", cellSize * 3/5, true);
  difficultyFont = createFont("HelveticaNeue-Bold", cellSize / 2, true);
  textAlign(CENTER, CENTER);
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j] = new Cell(i, j);
    }
  }
  for(int i = 0; i < candidates.length; i++){
    candidates[i][0] = i + 1;
  }
  generateRandomSudoku();
  generateRemainingDigits();
}

void draw(){
  background(240);
  showCandidates();
  fill(0, 0, 190);
  rect(2 * xStartPos + cols * cellSize, 0, width - (2 * xStartPos + cols * cellSize), height);
  textFont(timerFont, cellSize * 3/5);
  fill(255);
  text("Time: " + timer/3600 + "m " + (timer/60) % 60 + 's', (width - (2 * xStartPos + cols * cellSize))/2 + 2 * xStartPos + cols * cellSize, 100);
  if(showDifficulty){
    textFont(difficultyFont, cellSize /2);
    fill(0);
    text("Difficulty rating: ~" + finalDiff, xStartPos + cols * cellSize - 100, yStartPos - 40);
  }
  if(isOnCell){
    highlightRowColumnBox(currX, currY);
    if(board[currX][currY].num > 0){
      highlightSameNumbers(currX, currY);
    }
  }  
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j].show();
    }
  }
  drawBoardOutline();
  strokeWeight(20);
  noFill();
  switch(puzzleState){
    case 1:
      stroke(0, 255, 0);
      circle((width - (2 * xStartPos + cols * cellSize))/2 + 2 * xStartPos + cols * cellSize, 550, 150);
      break;
    case -1:
      stroke(255, 0, 0);
      line(xStartPos + cols * cellSize + 155, 475, xStartPos + cols * cellSize + 305, 625);
      line(xStartPos + cols * cellSize + 305, 475, xStartPos + cols * cellSize + 155, 625);
      break;
    default:
  }
  if(!finishedPuzzle){
    timer++;
  }
}

void keyPressed(){
  if(!finishedPuzzle){
    if(key == BACKSPACE){
      if(board[currX][currY].cellType == "Clue"){
        return;
      }
      puzzleState = 0;
      board[currX][currY].num = 0;
      for(int i = 0; i < board[currX][currY].candidateArr.length; i++){
        board[currX][currY].candidateArr[i] = false;
      }   
      generateRemainingDigits();
    }
    if((int) key > 48 && (int) key <= 57 && isOnCell){
      puzzleState = 0;
      if(board[currX][currY].cellType == "Clue"){
        return;
      }
      if(!candidateMode){
        board[currX][currY].num = (int) key - 48;
        for(int i = 0; i < cols; i++){ //removes any candidate within the same row, column, or box as the clue filled in
          board[i][currY].candidateArr[(int) key - 48 - 1] = false;
          board[currX][i].candidateArr[(int) key - 48 - 1] = false;
          board[currX/3 * 3 + i/3][currY/3 * 3 + i%3].candidateArr[(int) key - 48 - 1] = false;
        }
      }else{
        board[currX][currY].flipCandidate((int) key - 48);
      }
      generateRemainingDigits();
    }
  }
  if(key == 'e'){ //e for easy
    generateEasySudoku();
    generateRemainingDigits();
    showDifficulty = false;
  }
  
  if(key == 'm'){ //m for medium
    generateRandomSudoku();
    generateRemainingDigits();
    showDifficulty = false;
  }
  
  if(key == 'h'){ //h for hard
    generateRandomSudokuVersionTwo();
    generateRemainingDigits();
    showDifficulty = true;
  }
  
  if(key == 'c'){ //c for candidate
    candidateMode = !candidateMode;
  }
  if(key == 'f'){ //f for finish
    checkBoardState();
  }
}

void mousePressed(){
  board[currX][currY].isClickedOn = false;
  isOnCell = false;
  if(mouseX > xStartPos && mouseY > yStartPos && mouseX < xStartPos + cols * cellSize && mouseY < yStartPos + rows * cellSize){
    currX = (mouseX - xStartPos) / cellSize;
    currY = (mouseY - yStartPos) / cellSize;
    board[currX][currY].isClickedOn = true;
    isOnCell = true;
  }
}

/*
Notes:
- 18 Jan: added UI (main sudoku board, candidates, right rectangle), 
added functions to select cells and highlight all cells that are relevant to the current cell
added a function to generate a sudoku board

- 19 Jan: tweaked the sudoku generation algorithm to remove duplicate solutions, 
added addOrRemoveClues, copySolution, chooseClues, removeNonClues, findAllSolutions, findMostDifferentCell, addNewClue functions
optimized the findAllSolutions function to prioritize fewest candidates first

- 20 Jan: added pencil marking function, added functionality to remaining digits function, started working on generateSudokuV2, 
fixed a bug where currBestBoard was being incorrectly updated due to board differences of more than 2 (previous changes not reverted)

- 21 Jan: optimized generateRandomSudokuV1 and V2 (removed two double for loops for the boards and removed currBestBoard as it wasn't necessary),
fixed an indexing bug where findAllSolutionsV2 was using wrong indexes (j instead of k) when removing same candidates along the column row and box.

- 21 Jan: added check if sudoku is solved, added timer

- 22 Jan: finished findAllSolutionsVersionTwo (included set theory approach and corrected the difficulty scoring), 
fixed a bug which caused duplicates to be filled in to the board due to set theory approach.
fixed a bug where the solution of generateEasySudoku doesnt match up with the actual solution (not being updated).

- 23 Jan: added a display for difficulty (only for the last sudoku generating algorithm), 
added an image to tell the solver if the configuration matches the solution or not. added highlighting for candidates.
added the ability to remove any candidates along the same row, colum or box in the most recently filled cell
added the ability to limit the difficulty rating when generating sudokus

THIS PROJECT IS NOW FINISHED (might add some more features in the future if I want to)

https://dlbeer.co.nz/articles/sudoku.html (main article used for the steps in creating the difficulty scorer and optimized solver)

https://www.sudokuwiki.org/sudoku.htm (main article used to solve and verify the actual difficulty of the sudoku)

https://www.thonky.com/sudoku/evaluate-sudoku (main article to check the number of solutions in a sudoku)
*/
