String[] findAllSolutions(String[] solutions, String[] curr, Cell[][] currBoard, boolean returnEarly){
  int filledNums = 0; //counts the number of cells with numbers filled in
  int[] nextPos = {-1, -1}; //stores the next cell position to be searched
  Integer[] minCandidates = new Integer[cols]; //stores the candidates with the smallest length
  boolean foundOnlyOne = false;
  
  //goes through the entire board
  for(int idx1 = 0; idx1 < cols; idx1++){
    for(int idx2 = 0; idx2 < rows; idx2++){
      foundOnlyOne = false;
      if(currBoard[idx1][idx2].num > 0){ //case where cell is filled
        filledNums++;
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
      //case where there are no possible candidates (therefore the sudoku is invalid)
      if(unusedNums.size() == 0){
        return solutions;
      }
      //case where a new shortest candidate list is found
      if(unusedNums.size() < minCandidates.length){
        nextPos[0] = idx1;
        nextPos[1] = idx2;       
        minCandidates = unusedNums.toArray(new Integer[unusedNums.size()]);
        if(unusedNums.size() == 1){ //case where only one candidate is possible within a cell (will never find a shorter length)
          foundOnlyOne = true;
          break;
        }
      }
    }
    if(foundOnlyOne){
      break;
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
  
  currBranches += minCandidates.length - 1;
  
  for(int i = 0; i < minCandidates.length; i++){ //loops through all possible candidates
    currBoard[nextPos[0]][nextPos[1]].num = minCandidates[i];
    curr[nextPos[0] * cols + nextPos[1]] = str(minCandidates[i]);
    solutions = findAllSolutions(solutions, curr, currBoard, returnEarly);
    if(returnEarly && solutions.length > 1){
      break;
    }
  }
  
  currBoard[nextPos[0]][nextPos[1]].num = 0;
  curr[nextPos[0] * cols + nextPos[1]] = null;
  return solutions;
}
