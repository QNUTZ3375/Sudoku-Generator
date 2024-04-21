class Cell{
  int x, y;
  int num = 0;
  String cellType = "Clue";
  boolean isClickedOn = false;
  boolean[] candidateArr = new boolean[cols];
  int currState = 0;
  
  Cell(int _x, int _y){
    x = _x;
    y = _y;
    for(int i = 0; i < candidateArr.length; i++){
      candidateArr[i] = false;
    }
  }
  
  void reset(){
    num = 0;
    cellType = "Clue";
    for(int i = 0; i < candidateArr.length; i++){
      candidateArr[i] = false;
    }
  }
  
  void flipCandidate(int n){
    candidateArr[n - 1] = !candidateArr[n - 1];
  }
  
  void setNum(int n){
    num = n;
  }
  
  void show(){
    int defaultX = xStartPos + x * cellSize;
    int defaultY = yStartPos + y * cellSize;
    if(isClickedOn){
      fill(0, 200, 255);
    } else{
      noFill();
    }
    strokeWeight(1);
    stroke(0);
    square(defaultX, defaultY, cellSize);
    textFont(mainCandidateFont, cellSize * 2/3);
    if(cellType == "Clue"){
      fill(0);
    }else{
      fill(0, 0, 150);
    }
    if(num > 0){
      text(num, xStartPos + x * cellSize + cellSize/2, yStartPos + y * cellSize + cellSize/2);
    }else{
      textFont(smallCandidate, cellSize / 6);
      fill(30);
      for(int i = 0; i < candidateArr.length; i++){
        if(candidateArr[i]){
          text(i + 1, defaultX + cellSize/6 + 1 + (i % 3) * cellSize/3, defaultY + cellSize/6 + 1 + (i/3) * cellSize/3);
        }
      }
    }
  }
}
