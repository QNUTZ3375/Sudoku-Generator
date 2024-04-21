/*
modified set-oriented approach:
search for all columns, rows and boxes

check all missing values within each set, and check how many positions each value can occupy (the fewer the better)

take note of the set and value with the least positions that can be occupied.

compare that set and value to the cell with the least amount of candidates available.

if set and value has less possible positions, use that with the positions and solve recursively.
else, continue as usual.
*/

boolean presentInOtherSets(String initialSetType, int col, int row, int digitToCompare, Cell[][] currBoard){
  if(initialSetType != "ROW"){ //checks row if the initial set type is not row
    for(int i = 0; i < rows; i++){
      if (currBoard[col][i].num == digitToCompare){ //column stays constant, row changes
        return true;
      }
    }
  }
  if(initialSetType != "COL"){ //checks column if the initial set type is not column
    for(int i = 0; i < cols; i++){
      if (currBoard[i][row].num == digitToCompare){ //row stays constant, column changes
        return true;
      }
    }
  }
  if(initialSetType != "BOX"){ //checks box if the initial set type is not box
    for(int i = col / 3 * 3; i < col / 3 * 3 + 3; i++){
      for(int j = row / 3 * 3; j < row / 3 * 3 + 3; j++){
        if(currBoard[i][j].num == digitToCompare){
          return true;
        }
      }
    }
  }
  return false;
}

int[][] searchSetAndValue(String setType, int col, int row, Cell[][] currBoard){
  int[][] cellsOfInterest = {};
  Set<Integer> unusedNums = new HashSet<Integer>();
  for(int i = 0; i < cols; i++){ //makes a set from 1-9
    unusedNums.add(i + 1);
  }
  
  //phase 1: removes filled numbers from the target set
  if(setType == "ROW"){
    for(int i = 0; i < rows; i++){ //removes numbers in the same row (row changes, col doesn't change)
      unusedNums.remove(currBoard[col][i].num);
      //checks if the cell is empty; to be added to cellsOfInterest
      if(currBoard[col][i].num <= 0){
        cellsOfInterest = Arrays.copyOf(cellsOfInterest, cellsOfInterest.length + 1);
        cellsOfInterest[cellsOfInterest.length - 1] = new int[2];
        cellsOfInterest[cellsOfInterest.length - 1][0] = col;
        cellsOfInterest[cellsOfInterest.length - 1][1] = i;
      }
    }
  }else if(setType == "COL"){
    for(int i = 0; i < cols; i++){ //removes numbers in the same column (row doesn't change, col changes)
      unusedNums.remove(currBoard[i][row].num);
      //checks if the cell is empty; to be added to cellsOfInterest
      if(currBoard[i][row].num <= 0){
        cellsOfInterest = Arrays.copyOf(cellsOfInterest, cellsOfInterest.length + 1);
        cellsOfInterest[cellsOfInterest.length - 1] = new int[2];
        cellsOfInterest[cellsOfInterest.length - 1][0] = i;
        cellsOfInterest[cellsOfInterest.length - 1][1] = row;
      }
    }
  }else if(setType == "BOX"){
    for(int i = col / 3 * 3; i < col / 3 * 3 + 3; i++){ //removes numbers in the same box of c, r
      for(int j = row / 3 * 3; j < row / 3 * 3 + 3; j++){
        unusedNums.remove(currBoard[i][j].num);
        //checks if the cell is empty; to be added to cellsOfInterest
        if(currBoard[i][j].num <= 0){
          cellsOfInterest = Arrays.copyOf(cellsOfInterest, cellsOfInterest.length + 1);
          cellsOfInterest[cellsOfInterest.length - 1] = new int[2];
          cellsOfInterest[cellsOfInterest.length - 1][0] = i;
          cellsOfInterest[cellsOfInterest.length - 1][1] = j;
        }
      }
    }
  }
  
  Integer[] unusedDigits = unusedNums.toArray(new Integer[unusedNums.size()]);
  
  //the shorter the better; default will always be the length of the board
  //(inner arrays are always length 2 to store xy values)
  //last variable holds the set type (0 = row, 1 = column, 2 = box)
  int[][] currValidPoints = {};
  int[][] bestValidPoints = new int[cols + 1][];
  
  //phase 2: checks the number of valid positions for each value within unusedNums using the other sets
  /*
    for each value, make an array of available positions. loop through each value doing the following:
    
    1. go through the target set; if current cell is filled, skip to next cell.
    2. check the other two sets associated with current cell. if either contains current value, skip to next cell.
    3. add coordinate to list of empty points for said value.
    4. after the end of the current loop, check if the created array is shorter than the current smallest one.
    4a. if its shorter, replace it as the current array. 
  */
  
  //goes through the available digits
  for(int i = 0; i < unusedDigits.length; i++){
    //reset currValidPoints before checking each digit 
    currValidPoints = Arrays.copyOf(currValidPoints, 0);
    //goes through the empty cells
    for(int j = 0; j < cellsOfInterest.length; j++){
      //checks if current cell is occupiable using current value according to the setType 
      //(there are none of the same digit within the other sets of the current cell)
      if(!presentInOtherSets(setType, cellsOfInterest[j][0], cellsOfInterest[j][1], unusedDigits[i], currBoard)){
        //adds it to currValidPoints
        currValidPoints = Arrays.copyOf(currValidPoints, currValidPoints.length + 1);
        currValidPoints[currValidPoints.length - 1] = new int[2];
        currValidPoints[currValidPoints.length - 1][0] = cellsOfInterest[j][0];
        currValidPoints[currValidPoints.length - 1][1] = cellsOfInterest[j][1];
      }
    }
    //case where a new shortest set of points are found
    if(currValidPoints.length < bestValidPoints.length - 1 && currValidPoints.length > 0){
      //updates the array
      bestValidPoints = Arrays.copyOf(bestValidPoints, currValidPoints.length);
      for(int j = 0; j < currValidPoints.length; j++){
        bestValidPoints[j] = new int[2];
        bestValidPoints[j][0] = currValidPoints[j][0];
        bestValidPoints[j][1] = currValidPoints[j][1];
      }
      //appends the value to bestValidPoints
      bestValidPoints = Arrays.copyOf(bestValidPoints, bestValidPoints.length + 1);
      bestValidPoints[bestValidPoints.length - 1] = new int[1];
      bestValidPoints[bestValidPoints.length - 1][0] = unusedDigits[i];
    }
    if(bestValidPoints.length == 2){ //case where a hidden single has been found
      break;
    }
  }
  
  return bestValidPoints;
}

int[][] removeCandidateFromSets(int[] nextPos, int[][][] tempAllCandidates, int minCandidate){
  int[][] modifiedPoints = {};
  //goes through the column
  for(int i = 0; i < cols; i++){
    if(i == nextPos[0]){ //skips the column where the actual cell with the candidate is on
      continue;
    }
    //goes through the list of candidates in the column
    for(int j = 0; j < tempAllCandidates[i][nextPos[1]].length; j++){
      //removes same candidates along the column
      if(minCandidate == tempAllCandidates[i][nextPos[1]][j]){
        for(int k = j; k < tempAllCandidates[i][nextPos[1]].length - 1; k++){
          tempAllCandidates[i][nextPos[1]][k] = tempAllCandidates[i][nextPos[1]][k + 1];
        }
        tempAllCandidates[i][nextPos[1]] = Arrays.copyOf(tempAllCandidates[i][nextPos[1]], tempAllCandidates[i][nextPos[1]].length - 1);
        //adds the modified point to array
        modifiedPoints = Arrays.copyOf(modifiedPoints, modifiedPoints.length + 1);
        modifiedPoints[modifiedPoints.length - 1] = new int[2];
        modifiedPoints[modifiedPoints.length - 1][0] = i;
        modifiedPoints[modifiedPoints.length - 1][1] = nextPos[1];
      }
    }
  }
  //goes through the row
  for(int i = 0; i < rows; i++){
    if(i == nextPos[1]){ //skips the row where the actual cell with the candidate is on
      continue;
    }
    //goes through the list candidates in the row
    for(int j = 0; j < tempAllCandidates[nextPos[0]][i].length; j++){
      //removes same candidates along the row
      if(minCandidate == tempAllCandidates[nextPos[0]][i][j]){
        for(int k = j; k < tempAllCandidates[nextPos[0]][i].length - 1; k++){
          tempAllCandidates[nextPos[0]][i][k] = tempAllCandidates[nextPos[0]][i][k + 1];
        }
        tempAllCandidates[nextPos[0]][i] = Arrays.copyOf(tempAllCandidates[nextPos[0]][i], tempAllCandidates[nextPos[0]][i].length - 1);
        //adds the modified point to array
        modifiedPoints = Arrays.copyOf(modifiedPoints, modifiedPoints.length + 1);
        modifiedPoints[modifiedPoints.length - 1] = new int[2];
        modifiedPoints[modifiedPoints.length - 1][0] = nextPos[0];
        modifiedPoints[modifiedPoints.length - 1][1] = i;
      }
    }
  }
  //goes through the box
  for(int i = 0; i < rows; i++){
    int c = nextPos[0]/3 * 3 + i/3;
    int r = nextPos[1]/3 * 3 + i%3;
    if(c == nextPos[0] && r == nextPos[1]){ //skips the coordinate where the actual cell with the candidate is on
      continue;
    }
    //goes through the list of candidates in the box
    for(int j = 0; j < tempAllCandidates[c][r].length; j++){
      //removes same candidates in the box
      if(minCandidate == tempAllCandidates[c][r][j]){
        for(int k = j; k < tempAllCandidates[c][r].length - 1; k++){
          tempAllCandidates[c][r][k] = tempAllCandidates[c][r][k + 1];
        }
        tempAllCandidates[c][r] = Arrays.copyOf(tempAllCandidates[c][r], tempAllCandidates[c][r].length - 1);
        //adds the modified point to array
        modifiedPoints = Arrays.copyOf(modifiedPoints, modifiedPoints.length + 1);
        modifiedPoints[modifiedPoints.length - 1] = new int[2];
        modifiedPoints[modifiedPoints.length - 1][0] = c;
        modifiedPoints[modifiedPoints.length - 1][1] = r;
      }
    }
  }
  return modifiedPoints;
}

int[][][] findAllCandidates(Cell[][] currBoard){
  int[][][] allCandidates = new int[cols][rows][];
  int[][][] invalidSudoku = {{{-1}}};
  
  for(int idx1 = 0; idx1 < cols; idx1++){
    for(int idx2 = 0; idx2 < rows; idx2++){
      if(currBoard[idx1][idx2].num > 0){ //case where cell is filled
        allCandidates[idx1][idx2] = new int[0];
        continue;
      }
      Set<Integer> unusedNums = new HashSet<Integer>();
      for(int i = 0; i < cols; i++){ //makes a set from 1-9
        unusedNums.add(i + 1);
      }
      for(int i = 0; i < cols; i++){ //removes numbers in the same column and row of c, r
        unusedNums.remove(currBoard[i][idx2].num);
        unusedNums.remove(currBoard[idx1][i].num);
      }
      for(int i = idx1 / 3 * 3; i < idx1 / 3 * 3 + 3; i++){ //removes numbers in the same box of c, r
        for(int j = idx2 / 3 * 3; j < idx2 / 3 * 3 + 3; j++){
          unusedNums.remove(currBoard[i][j].num);
        }
      }
      //case where there are no possible candidates, meaning the sudoku is unsolvable
      if(unusedNums.size() == 0){
        return invalidSudoku;
      }
      //stores all the candidates in the return array
      allCandidates[idx1][idx2] = new int[unusedNums.size()];
      Integer[] temp = unusedNums.toArray(new Integer[unusedNums.size()]);
      for(int i = 0; i < unusedNums.size(); i++){
        allCandidates[idx1][idx2][i] = temp[i];
      }
    }
  }
  return allCandidates;
}

String[] findAllSolutionsVersionTwo(String[] solutions, String[] curr, Cell[][] currBoard, int[][][] allCandidates, boolean returnEarly){
  int filledNums = 0; //counts the number of cells with numbers filled in
  int[] nextPos = {-1, -1}; //stores the next cell position to be searched
  int[] minCandidates = new int[cols]; //stores the candidates with the smallest length
  String[] setTypes = {"ROW", "COL", "BOX"};
  int[][] setSearchCandidates = {};
  int[][] bestSetSearchCandidates = new int[cols + 1][];
  int[][][] tempAllCandidates = new int[cols][rows][];
  boolean foundSingle = false;
  
  //goes through the entire board
  for(int idx1 = 0; idx1 < cols; idx1++){
    for(int idx2 = 0; idx2 < rows; idx2++){
      //default case
      tempAllCandidates[idx1][idx2] = new int[0];
      if(currBoard[idx1][idx2].num > 0){ //case where cell is filled
        filledNums++;
        continue;
      }
      if(allCandidates[idx1][idx2].length == 0){ //case where there are no candidates for the cell (invalid solution)
        return solutions;
      }
      
      //copies the candidates within a cell to a temporary variable which will be used for the recursion part
      tempAllCandidates[idx1][idx2] = new int[allCandidates[idx1][idx2].length];
      for(int i = 0; i < allCandidates[idx1][idx2].length; i++){
        tempAllCandidates[idx1][idx2][i] = allCandidates[idx1][idx2][i];
      }
      
      if(foundSingle){ //case where a single has been found, making the whole bottom section unnecessary
        continue;
      }
      
      //case where a new shortest candidate list is found
      if(allCandidates[idx1][idx2].length < minCandidates.length){
        nextPos[0] = idx1;
        nextPos[1] = idx2;       
        minCandidates = new int[allCandidates[idx1][idx2].length];
        for(int i = 0; i < allCandidates[idx1][idx2].length; i++){
          minCandidates[i] = allCandidates[idx1][idx2][i];
        }
        if(minCandidates.length == 1){
          foundSingle = true;
        }
      }
      
      //case where a better potential cell to be filled is possible
      if(minCandidates.length > 1){
        //goes through the set types
        for(int i = 0; i < setTypes.length; i++){
          setSearchCandidates = searchSetAndValue(setTypes[i], idx1, idx2, currBoard);
          //checks if there is a new shortest array
          if(setSearchCandidates.length < bestSetSearchCandidates.length && setSearchCandidates.length > 0){
            bestSetSearchCandidates = Arrays.copyOf(bestSetSearchCandidates, setSearchCandidates.length);
            //copies the values to bestSetSearchCandidates
            for(int j = 0; j < setSearchCandidates.length; j++){
              bestSetSearchCandidates[j] = new int[setSearchCandidates[j].length];
              for(int k = 0; k < setSearchCandidates[j].length; k++){
                bestSetSearchCandidates[j][k] = setSearchCandidates[j][k];
              }
            }
          }
        }
        if(bestSetSearchCandidates.length - 1 == 1){
          foundSingle = true;
        }
      }
    }
  }
  
  if(filledNums == cols * rows){ //case where all cells have been filled
    solutions = Arrays.copyOf(solutions, solutions.length + 1);
    solutions[solutions.length - 1] = String.join("", curr);
    return solutions;
  }
  
  if(nextPos[0] == nextPos[1] && nextPos[0] == -1){ //case where the current puzzle state is invalid
    return solutions;
  }
  
  int[][] modifiedPoints = {};
      
  if(bestSetSearchCandidates.length - 1 < minCandidates.length){
    int valToUse = bestSetSearchCandidates[bestSetSearchCandidates.length - 1][0];
    
    bestSetSearchCandidates = Arrays.copyOf(bestSetSearchCandidates, bestSetSearchCandidates.length - 1);
    currBranches += (bestSetSearchCandidates.length - 1) * (bestSetSearchCandidates.length - 1);

    for(int i = 0; i < bestSetSearchCandidates.length; i++){ //loops through all possible candidates
      //removes all occurences of minCandidates[i] within its column, row and box
      modifiedPoints = removeCandidateFromSets(bestSetSearchCandidates[i], tempAllCandidates, valToUse);
  
      currBoard[bestSetSearchCandidates[i][0]][bestSetSearchCandidates[i][1]].num = valToUse;
      curr[bestSetSearchCandidates[i][0] * cols + bestSetSearchCandidates[i][1]] = str(valToUse);
            
      solutions = findAllSolutionsVersionTwo(solutions, curr, currBoard, tempAllCandidates, returnEarly);
      //restores the removed clues from tempAllCandidates
      for(int j = 0; j < modifiedPoints.length; j++){
        tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]] = 
        Arrays.copyOf(tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]], 
                      tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]].length + 1);
                      
        tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]][tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]].length - 1] = valToUse;
      }
        
      currBoard[bestSetSearchCandidates[i][0]][bestSetSearchCandidates[i][1]].num = 0;
      curr[bestSetSearchCandidates[i][0] * cols + bestSetSearchCandidates[i][1]] = null;
      
      if(returnEarly && solutions.length > 1){
        break;
      }
    }
  }else{
    currBranches += (minCandidates.length - 1) * (minCandidates.length - 1);
  
    for(int i = 0; i < minCandidates.length; i++){ //loops through all possible candidates
      //removes all occurences of minCandidates[i] within its column, row and box
      modifiedPoints = removeCandidateFromSets(nextPos, tempAllCandidates, minCandidates[i]);
  
      currBoard[nextPos[0]][nextPos[1]].num = minCandidates[i];
      curr[nextPos[0] * cols + nextPos[1]] = str(minCandidates[i]);
      solutions = findAllSolutionsVersionTwo(solutions, curr, currBoard, tempAllCandidates, returnEarly);

      //restores the removed clues from tempAllCandidates
      for(int j = 0; j < modifiedPoints.length; j++){
        tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]] = 
        Arrays.copyOf(tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]], 
                      tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]].length + 1);
                      
        tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]][tempAllCandidates[modifiedPoints[j][0]][modifiedPoints[j][1]].length - 1] = minCandidates[i];
      }
      
      if(returnEarly && solutions.length > 1){
        break;
      }
    }
      
    currBoard[nextPos[0]][nextPos[1]].num = 0;
    curr[nextPos[0] * cols + nextPos[1]] = null;
  }
  return solutions;
}
