int[][] removeOrAddClues(Cell[][] currBoard, boolean forceAdd){
  float rand = random(0, 1);
  int counter = 0;
  int[][] res = {};
  int[][] listOfEmpties = {};
  int[][] listOfFulls = {};

  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      if(currBoard[i][j].num == 0){
        listOfEmpties = Arrays.copyOf(listOfEmpties, listOfEmpties.length + 1);
        listOfEmpties[listOfEmpties.length - 1] = new int[2];
        listOfEmpties[listOfEmpties.length - 1][0] = i;
        listOfEmpties[listOfEmpties.length - 1][1] = j;
      }
      if(currBoard[i][j].num > 0){
        listOfFulls = Arrays.copyOf(listOfFulls, listOfFulls.length + 1);
        listOfFulls[listOfFulls.length - 1] = new int[2];
        listOfFulls[listOfFulls.length - 1][0] = i;
        listOfFulls[listOfFulls.length - 1][1] = j;
      }
    }
  }  
  //Note: for a sudoku to be more potentially difficult, more clues need to be removed than added, 
  //hence why the random number threshold is very high
  if(forceAdd || (rand > threshold && listOfEmpties.length >= 2)){ //adds clues
    //adds two clues to the board
    while(counter < 2){
      int rand2 = int(random(0, listOfEmpties.length));
      currBoard[listOfEmpties[rand2][0]][listOfEmpties[rand2][1]].num = solution[listOfEmpties[rand2][0]][listOfEmpties[rand2][1]];
      res = Arrays.copyOf(res, res.length + 1);
      res[res.length - 1] = new int[2];
      res[res.length - 1][0] = listOfEmpties[rand2][0];
      res[res.length - 1][1] = listOfEmpties[rand2][1];
      counter++;
    }
    res = Arrays.copyOf(res, res.length + 1);
    res[res.length - 1] = new int[1];
    res[res.length - 1][0] = 1;
  }else if(listOfFulls.length >= 2){ //removes clues
    //removes two clues to the board
    while(counter < 2){
      int rand2 = int(random(0, listOfFulls.length));
      currBoard[listOfFulls[rand2][0]][listOfFulls[rand2][1]].num = 0;
      res = Arrays.copyOf(res, res.length + 1);
      res[res.length - 1] = new int[2];
      res[res.length - 1][0] = listOfFulls[rand2][0];
      res[res.length - 1][1] = listOfFulls[rand2][1];
      counter++;
    }
    res = Arrays.copyOf(res, res.length + 1);
    res[res.length - 1] = new int[1];
    res[res.length - 1][0] = 0;
  }
  return res;
}
