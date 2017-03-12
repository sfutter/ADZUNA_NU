# THIS IS NOT IN USE CURRENTLY as of MARCH 5th 2017


########################################################################################################################
# On the first run-through make sure that h2o is installed and ready to work. Note that Java is needed for h2o to work. 
########################################################################################################################
# # The following two commands remove any previously installed H2O packages for R.
# if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
# if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }
# 
# # Next, we download packages that H2O depends on.
# if (! ("methods" %in% rownames(installed.packages()))) { install.packages("methods") }
# if (! ("statmod" %in% rownames(installed.packages()))) { install.packages("statmod") }
# if (! ("stats" %in% rownames(installed.packages()))) { install.packages("stats") }
# if (! ("graphics" %in% rownames(installed.packages()))) { install.packages("graphics") }
# if (! ("RCurl" %in% rownames(installed.packages()))) { install.packages("RCurl") }
# if (! ("jsonlite" %in% rownames(installed.packages()))) { install.packages("jsonlite") }
# if (! ("tools" %in% rownames(installed.packages()))) { install.packages("tools") }
# if (! ("utils" %in% rownames(installed.packages()))) { install.packages("utils") }


codePath = file.path("~/Dropbox","NU","ADVANCED_MODELING","ADZUNA_NU")
source(file.path(codePath,"data_preparation.R"))

trainData1 = processData1(valData)

## sanity check that data is found post data processing step from part 1
head(valDataPart1,10)