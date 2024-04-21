boolean generateSudokuConfig(int c, int r){
  if(c == cols - 1 && r == rows){ //case where the end of the board has been reached
    return true;
  }
  
  if(r >= rows){ //updates the column and row when row hits the end
    c++;
    r = 0;
  }
  
  Set<Integer> usedNums = new HashSet<Integer>();
  for(int i = 0; i < cols; i++){ //makes a set from 1-9
    usedNums.add(i + 1);
  }
  for(int i = 0; i < cols; i++){ //removes numbers in the same column and row of c, r
    usedNums.remove(board[i][r].num);
    usedNums.remove(board[c][i].num);
  }
  for(int i = c / 3 * 3; i < c / 3 * 3 + 3; i++){ //removes numbers in the same box of c, r
    for(int j = r / 3 * 3; j < r / 3 * 3 + 3; j++){
      usedNums.remove(board[i][j].num);
    }
  }
    
  if(usedNums.size() == 0){ //condition where there are no available elements to use
    return false;
  }
  
  //generates the possible candidates using usedNums
  Integer[] dummy = usedNums.toArray(new Integer[usedNums.size()]);
  int[] selection = new int[dummy.length];
  for(int i = 0; i < dummy.length; i++){
    selection[i] = dummy[i];
  }
  
  //randomizes the number priorities
  while (dummy.length > 1){
    int rand = int(random(0, dummy.length));
    int temp = dummy[rand];
    dummy[rand] = dummy[0];
    selection[rand] = selection[0];
    dummy[0] = temp;
    selection[0] = temp;
    dummy = Arrays.copyOf(dummy, dummy.length - 1);
  }
  
  boolean state = false;
  //goes through all possible configurations using backtracking
  for(int i = 0; i < selection.length; i++){
    board[c][r].num = selection[i];
    state = generateSudokuConfig(c, r + 1);
    if(state){
      break;
    }
  }
  
  if(!state){ //case where a match hasn't been found yet
    board[c][r].num = 0;
    return false;
  }
  
  return true;
}

void generateEasySudoku(){
  timer = 0;
  finishedPuzzle = false;
  board[currX][currY].isClickedOn = false;
  isOnCell = false;
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      board[i][j].num = 0;
      board[i][j].cellType = "None";
    }
  }
  generateSudokuConfig(0, 0);
  //chooeses clues at random (25 is the limit here)
  int count = 0;
  while(count < 25){
    int c = int(random(0, cols));
    int r = int(random(0, rows));
    
    if(board[c][r].cellType == "Clue"){
      continue;
    }
    
    board[c][r].cellType = "Clue";
    currSolution[c * cols + r] = str(board[c][r].num);
    count++;
  }
  //resets the non-clue cells from the board
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(board[i][j].cellType != "Clue"){
        board[i][j].num = 0;
      }
    }
  }
  
  allSolutions = Arrays.copyOf(allSolutions, 0);
  allSolutions = findAllSolutions(allSolutions, currSolution, board, false);
  println(currBranches);
  println("Solutions: ", allSolutions.length);
  printArray(allSolutions);
  
  println("Current Board: ");
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[j][i].num == 0){
        print('.');
      }else{
        print(board[j][i].num);
      }
    }
    println();
  }
  
  while(allSolutions.length > 1){
    int[] currDiff = findMostDifferentCell(allSolutions);
    if(currDiff[2] > 0){
      //adds new clue
      board[currDiff[0]][currDiff[1]].num = currDiff[2];
      board[currDiff[0]][currDiff[1]].cellType = "Clue";
      currSolution[currDiff[0] * cols + currDiff[1]] = str(currDiff[2]);
      
      allSolutions = Arrays.copyOf(allSolutions, 0);
      allSolutions = findAllSolutions(allSolutions, currSolution, board, false);
    }
  }
  
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      solution[i][j] = Character.getNumericValue(allSolutions[0].charAt(i * cols + j));
    }
  }
  
  
  println("Solutions: ", allSolutions.length);
  printArray(allSolutions);
  
  println("Current Board: ");
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[j][i].num == 0){
        print('.');
      }else{
        print(board[j][i].num);
      }
    }
    println();
  }
}

void generateRandomSudokuVersionTwo(){
  timer = 0;
  finishedPuzzle = false;
  board[currX][currY].isClickedOn = false;
  isOnCell = false;
  emptySpaces = 0;
  //resets the whole board to become empty (sets all values to clues beforehand)
  resetBoard();
  //creates a new solved sudoku grid and stores it in a separate variable
  generateSudokuConfig(0, 0);
  solution = copySolution(solution);
  //initializes the number of shown clues to the entire board's dimensions and the hardest difficulty value
  int currBestBranches = 0;
  int[][][] allCandidates = new int[cols][rows][];
  Cell[][] tempBoard = new Cell[cols][rows];
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      tempBoard[i][j] = new Cell(i, j);
      tempBoard[i][j].setNum(board[i][j].num);
    }
  }
  
  //first counter is to keep track of the number of changes the board will go through
  for(int counter1 = 0; counter1 < 100; counter1++){
    boolean forceAdd = false;
    //println("C1", counter1);
    //makes two placeholder boards and sets them to have the same values as the current board
    
    //stores the points being modified
    int[][] returnVals = new int[3][];
    int[][] currBestVals = new int[3][];
    currBestVals[2] = new int[1];
    currBestVals[2][0] = -1;
    //second counter to keep track of the number of times a change is being tested
    for(int counter2 = 0; counter2 < 20; counter2++){
      currBranches = 0;
      //removes or adds clues on the board
      returnVals = removeOrAddClues(tempBoard, forceAdd);
            
      //gets all potential candidates
      allCandidates = findAllCandidates(tempBoard);
      
      //case where the sudoku is solvable
      if(allCandidates.length > 1){
        //finds the amount of solutions in the new board
        allSolutions = Arrays.copyOf(allSolutions, 0);
        allSolutions = findAllSolutionsVersionTwo(allSolutions, currSolution, tempBoard, allCandidates, true);
        
        //checks if the solution is unique
        if(allSolutions.length == 1){
          forceAdd = false;
          //checks if a new hardest difficulty is found
          if(currBranches >= currBestBranches && currBranches <= (maxDiff - 100) / 100){
            //updates values
            currBestBranches = currBranches;
            //stores the new values into currBestVals
            for(int i = 0; i < returnVals.length; i++){
              currBestVals[i] = new int[returnVals[i].length];
              for(int j = 0; j < returnVals[i].length; j++){
                currBestVals[i][j] = returnVals[i][j];
              }
            }
          }
        }else{
          if(allSolutions.length > 1){ //case where multiple solutions are found (needs to add more clues to force uniqueness)
            forceAdd = true;
          }
        }
        switch(returnVals[2][0]){ //restores the state of tempBoard after addOrRemoveClues
          case 1: //removes clues again
            tempBoard[returnVals[0][0]][returnVals[0][1]].num = 0;
            tempBoard[returnVals[1][0]][returnVals[1][1]].num = 0;
            break;
          case 0: //adds back clues
            tempBoard[returnVals[0][0]][returnVals[0][1]].num = solution[returnVals[0][0]][returnVals[0][1]];
            tempBoard[returnVals[1][0]][returnVals[1][1]].num = solution[returnVals[1][0]][returnVals[1][1]];
            break;
        }
      }
    }
    //updates the final difficulty level
    finalDiff = currBestBranches * 100;
    //updates the board to match the best board from the second counter loop
    switch(currBestVals[2][0]){ //modifies the state of board and tempBoard according to currBestVals
      case 0: //removes clues again
        board[currBestVals[0][0]][currBestVals[0][1]].num = 0;
        board[currBestVals[1][0]][currBestVals[1][1]].num = 0;
        
        tempBoard[currBestVals[0][0]][currBestVals[0][1]].num = 0;
        tempBoard[currBestVals[1][0]][currBestVals[1][1]].num = 0;
        break;
      case 1: //adds back clues
        board[currBestVals[0][0]][currBestVals[0][1]].num = solution[currBestVals[0][0]][currBestVals[0][1]];
        board[currBestVals[1][0]][currBestVals[1][1]].num = solution[currBestVals[1][0]][currBestVals[1][1]];
        
        tempBoard[currBestVals[0][0]][currBestVals[0][1]].num = solution[currBestVals[0][0]][currBestVals[0][1]];
        tempBoard[currBestVals[1][0]][currBestVals[1][1]].num = solution[currBestVals[1][0]][currBestVals[1][1]];        
        break;
    }
    if(finalDiff >= maxDiff - 100){
      break;
    }
    //println("Current Board: ");
    //for(int i = 0; i < board.length; i++){
    //  for(int j = 0; j < board[0].length; j++){
    //    if(board[j][i].num == 0){
    //      print('.');
    //    }else{
    //      print(board[j][i].num);
    //    }
    //  }
    //  println();
    //}
  }
  
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[i][j].num == 0){
        board[i][j].cellType = "None";
        currSolution[i * cols + j] = null;
        emptySpaces++;
      }else{
        currSolution[i * cols + j] = str(board[i][j].num);
      }
    }
  }
  finalDiff += emptySpaces;
  println("F", finalDiff, currBestBranches, emptySpaces);

  allSolutions = Arrays.copyOf(allSolutions, 0);
  allSolutions = findAllSolutions(allSolutions, currSolution, board, false);
  println("Solutions: ", allSolutions.length);
  printArray(allSolutions);
  
  println("Current Board: ");
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[j][i].num == 0){
        print('.');
      }else{
        print(board[j][i].num);
      }
    }
    println();
  }
}

void generateRandomSudoku(){
  timer = 0;
  finishedPuzzle = false;
  board[currX][currY].isClickedOn = false;
  isOnCell = false;
  emptySpaces = 0;
  //resets the whole board to become empty (sets all values to clues beforehand)
  resetBoard();
  //creates a new solved sudoku grid and stores it in a separate variable
  generateSudokuConfig(0, 0);
  solution = copySolution(solution);
  //initializes the number of shown clues to the entire board's dimensions and the hardest difficulty value
  int currBestBranches = 0;
  
  //makes two placeholder boards and sets them to have the same values as the current board
  Cell[][] tempBoard = new Cell[cols][rows];
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      tempBoard[i][j] = new Cell(i, j);
      tempBoard[i][j].setNum(board[i][j].num);
    }
  }
  
  //first counter is to keep track of the number of changes the board will go through
  for(int counter1 = 0; counter1 < 100; counter1++){
    boolean forceAdd = false;
    //println("C1", counter1);
    //stores the points being modified and the currBestBoard points that were modified and the mode
    int[][] returnVals = new int[3][];
    int[][] currBestVals = new int[3][];
    currBestVals[2] = new int[1];
    currBestVals[2][0] = -1; //case where a new best board hasn't been set yet, therefore preventing the switch case from executing
    //second counter to keep track of the number of times a change is being tested
    for(int counter2 = 0; counter2 < 20; counter2++){
      currBranches = 0;
      //removes or adds clues on the board
      returnVals = removeOrAddClues(tempBoard, forceAdd);
      //finds the amount of solutions in the new board
      allSolutions = Arrays.copyOf(allSolutions, 0);
      allSolutions = findAllSolutions(allSolutions, currSolution, tempBoard, true);
      //checks if the solution is unique
      if(allSolutions.length == 1){
        forceAdd = false;
        //checks if a new hardest difficulty is found
        if(currBranches >= currBestBranches){
          //updates values
          currBestBranches = currBranches;
          //stores the new values into currBestVals
          for(int i = 0; i < returnVals.length; i++){
            currBestVals[i] = new int[returnVals[i].length];
            for(int j = 0; j < returnVals[i].length; j++){
              currBestVals[i][j] = returnVals[i][j];
            }
          }
        }
      }else{
        if(allSolutions.length > 1){ //case where multiple solutions are found (needs to add more clues to force uniqueness)
          forceAdd = true;
        }
      }
      switch(returnVals[2][0]){ //restores the state of tempBoard after addOrRemoveClues
        case 1: //removes clues again
          tempBoard[returnVals[0][0]][returnVals[0][1]].num = 0;
          tempBoard[returnVals[1][0]][returnVals[1][1]].num = 0;
          break;
        case 0: //adds back clues
          tempBoard[returnVals[0][0]][returnVals[0][1]].num = solution[returnVals[0][0]][returnVals[0][1]];
          tempBoard[returnVals[1][0]][returnVals[1][1]].num = solution[returnVals[1][0]][returnVals[1][1]];
          break;
      }
    }
    //updates the final difficulty level
    finalDiff = currBestBranches * 100;
    
    //updates the board to match the best board from the second counter loop
    switch(currBestVals[2][0]){ //modifies the state of board and tempBoard according to currBestVals
      case 0: //removes clues again
        board[currBestVals[0][0]][currBestVals[0][1]].num = 0;
        board[currBestVals[1][0]][currBestVals[1][1]].num = 0;
        
        tempBoard[currBestVals[0][0]][currBestVals[0][1]].num = 0;
        tempBoard[currBestVals[1][0]][currBestVals[1][1]].num = 0;
        break;
      case 1: //adds back clues
        board[currBestVals[0][0]][currBestVals[0][1]].num = solution[currBestVals[0][0]][currBestVals[0][1]];
        board[currBestVals[1][0]][currBestVals[1][1]].num = solution[currBestVals[1][0]][currBestVals[1][1]];
        
        tempBoard[currBestVals[0][0]][currBestVals[0][1]].num = solution[currBestVals[0][0]][currBestVals[0][1]];
        tempBoard[currBestVals[1][0]][currBestVals[1][1]].num = solution[currBestVals[1][0]][currBestVals[1][1]];        
        break;
    } 

    //println("Current Board: ");
    //for(int i = 0; i < board.length; i++){
    //  for(int j = 0; j < board[0].length; j++){
    //    if(board[j][i].num == 0){
    //      print('.');
    //    }else{
    //      print(board[j][i].num);
    //    }
    //  }
    //  println();
    //}
  }
  
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[i][j].num == 0){
        board[i][j].cellType = "None";
        currSolution[i * cols + j] = null;
        emptySpaces++;
      }else{
        currSolution[i * cols + j] = str(board[i][j].num);
      }
    }
  }
  finalDiff += emptySpaces;
  println("F", finalDiff, currBestBranches, emptySpaces);

  allSolutions = Arrays.copyOf(allSolutions, 0);
  allSolutions = findAllSolutions(allSolutions, currSolution, board, false);
  println("Solutions: ", allSolutions.length);
  //printArray(allSolutions);
  
  println("Current Board: ");
  for(int i = 0; i < board.length; i++){
    for(int j = 0; j < board[0].length; j++){
      if(board[j][i].num == 0){
        print('.');
      }else{
        print(board[j][i].num);
      }
    }
    println();
  }
}
