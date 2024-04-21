int[] findMostDifferentCell(String[] solutions){
  int[] maxDiffs = {};
  int maxOccurences = 0;
  
  //goes through the elements within the first solution
  for(int i = 0; i < solutions[0].length(); i++){
    //creates a new array
    char[] currDiffs = new char[1];
    currDiffs[0] = solutions[0].substring(i, i + 1).charAt(0);
    //goes through the rest of the solutions
    for(int j = 1; j < solutions.length; j++){
      //gets the i-th digit within the current solution
      char currDigit = solutions[j].substring(i, i + 1).charAt(0);
      boolean inArray = false;
      //checks if the current digit is already is within curDiffs
      for(int k = 0; k < currDiffs.length; k++){
        if(currDiffs[k] == currDigit){
          inArray = true;
        }
      }
      //adds the digit in the case where it's not present yet
      if(!inArray){
        currDiffs = Arrays.copyOf(currDiffs, currDiffs.length + 1);
        currDiffs[currDiffs.length - 1] = currDigit;
      }
    }
    //checks if there are more differing solutions than the current max
    if(maxDiffs.length < currDiffs.length){
      //updates the index where for the most occurences
      maxOccurences = i;
      //copies all of the solutions to maxDiffs
      maxDiffs = Arrays.copyOf(maxDiffs, currDiffs.length);
      for(int temp = 0; temp < currDiffs.length; temp++){
        maxDiffs[temp] = currDiffs[temp];
      }
    }
  }
  
  int rand = int(random(0, maxDiffs.length));
  int[] retDiffVals = {maxOccurences / cols, maxOccurences % rows, Character.getNumericValue(maxDiffs[rand])};
  
  return retDiffVals;
}
