########################################
## ADVANCED MODELING CLASS
## Adzuna Salary Prediction Project
########################################

# Function to perform Part 1 data processing steps on a data frame.
processDataPart1 = function(myData)
{
  ## Resolve Missing Values - no steps here for now. 
  
  # convert ABILITY_tfidf, ABILITY_kwfreq, and SALARYNORM to numerical values. For some reason they get converted to factor variables via read.csv() so need correcting. 
  myData$ABILITY_tfidf  = as.numeric(myData$ABILITY_tfidf)
  myData$ABILITY_kwfreq = as.numeric(myData$ABILITY_kwfreq)
  myData$SALARYNORM     = as.numeric(myData$SALARYNORM)
  
  ## Part B - Derived or Transformed Variables
  #  myData$LOG_SALARYNORM = log(myData$SALARYNORM)  	# Keeping this commented out for now. May need to uncomment for final assignment hand-in. Coord with working group. 
  
  ## Part D - Drop Variables
  #  Dropping Company and Title as too many factors for my computer to handle in memory data frame.
  dropIdx1 = which(names(myData) %in% c("Company","Title"))
  myData = myData[,-dropIdx1]
  attach(myData)
  
  adzunaMatrix = data.frame(model.matrix(SALARYNORM~., myData))
  
  # create vector with columns that have <1% values (consider revising this ... not 100% sure this is correct way of doing)
  vector = c()
  for (i in 3:length(adzunaMatrix)){
    val = prop.table(table(adzunaMatrix[,i]))[[2]] < 0.01
    vector[i] <- val
  }
  
  # Drop the columns that have # obs below 1% threshold
  incIndx = which(vector)
  adzunaMatrix = adzunaMatrix[,-incIndx]
    
  # add back salary to data frame
  myData = cbind(SALARYNORM,adzunaMatrix)
  
  # let's also remove price so that there is no confusion as to which response variable should be used
  #dropIdx = which(names(adzuna) %in% c("Id","SalaryNormalized","X.Intercept.","X"))
  dropIdx2 = which(names(myData) %in% c("X.Intercept.","X","Id"))
  myData = myData[,-dropIdx2]
    
  return(myData)
}


