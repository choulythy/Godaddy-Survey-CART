library(rpart) #One of the packages that supports CART.
library(rpart.plot) #For nicer plotting of trees
library(gmodels) #For confusion matrix
library(readxl)
library(ggplot2)
library(dplyr)
library(janitor)
library(shiny)
library(shinythemes)

####################################################################################################################
#PART1: Import and clean data 
####################################################################################################################
knitr::opts_knit$set(root.dir = '~/Downloads/Field Project/Assignment 1') 
df3 <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Data")

#extract data
df <- df3[c("q2", "q5", "q5a", "q5b", "q5c", "q5d", "q6", "q9", "q11", "q12", "q13", "q14", "q25")]
rm(df3)
summary(df)
hist(df$q14)


#match data with value from sheet 2
values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B15:C19", col_names = c("q2", "q2_text"))
df=merge(df,values, by="q2", all.x=T)

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B24:C28", col_names = c("q5", "q5_text"))
df=merge(df,values, by="q5", all.x=T)

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B29:C33", col_names = c("q5a", "q5a_text"))
df=merge(df,values, by="q5a", all.x=T)
df <- df %>%
  mutate(q5a_text = ifelse(q5a == -8, "Prefer not to answer", q5a_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B34:C36", col_names = c("q5b", "q5b_text"))
df=merge(df,values, by="q5b", all.x=T)
df <- df %>%
  mutate(q5b_text = ifelse(q5b == -8, "Prefer not to answer", q5b_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B37:C50", col_names = c("q5c", "q5c_text"))
df=merge(df,values, by="q5c", all.x=T)
df <- df %>%
  mutate(q5c_text = ifelse(q5c == -8, "Prefer not to answer", q5c_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B51:C61", col_names = c("q5d", "q5d_text"))
df=merge(df,values, by="q5d", all.x=T)
df <- df %>%
  mutate(q5d_text = ifelse(q5d == -8, "Prefer not to answer", q5d_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B62:C66", col_names = c("q6", "q6_text"))
df=merge(df,values, by="q6", all.x=T)
df <- df %>%
  mutate(q6_text = ifelse(q6 == -8, "Prefer not to answer", q6_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B107:C111", col_names = c("q9", "q9_text"))
df=merge(df,values, by="q9", all.x=T)
df <- df %>%
  mutate(q9_text = ifelse(q9 == -8, "Prefer not to answer", q9_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B367:C369", col_names = c("q11", "q11_text"))
df=merge(df,values, by="q11", all.x=T)
df <- df %>%
  mutate(q11_text = ifelse(q11 == -8, "Prefer not to answer", q11_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B372:C375", col_names = c("q12", "website_importance"))
df=merge(df,values, by="q12", all.x=T)
df <- df %>%
  mutate(website_importance = ifelse(q12 == -8, "Prefer not to answer", website_importance))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B387:C390", col_names = c("q13", "customer_care_rating"))
df=merge(df,values, by="q13", all.x=T)
df <- df %>%
  mutate(customer_care_rating = ifelse(q13 == -8, "Prefer not to answer", customer_care_rating))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B425:C434", col_names = c("q25", "q25_text"))
df=merge(df,values, by="q25", all.x=T)
df <- df %>%
  mutate(q25_text = ifelse(q25 == -8, "Prefer not to answer", q25_text))

rm(values)

#remove the column without the Values
df <- df[, !names(df) %in% c("q2", "q5", "q5a", "q5b", "q5c", "q5d", "q6", "q9", "q11", "q12", "q13", "q25")]

#dealing with missing value, replace NA with Inapplicable
df[is.na(df)] <- "Inapplicable"

#remove the numbers before the text i.e. (1),(2),.....
df[] <- lapply(df, function(x) gsub("^\\([0-9]+\\) ", "", x))

summary(df)
df$q14=as.numeric(df$q14)
hist(df$q14)

####################################################################################################################
#PART2: ClASSIFICATION TREE
####################################################################################################################

#Parameter Set-up for top-to-bottom growing of the tree (before pruning)
min_cp=0.01
minbucket=15

#Check the structure of the data and the distribution of recommendation
str(df)
hist(df$q14)

#Create a categorical variable for Rings
df$q14_group=ifelse(df$q14 <=6, "Detractors", 
                        ifelse(df$q14 <=9, "Moderates", "Advocate"))

#Check that the levels are created correctly
table(df$q14_group)

#START OF VARIABLE REDEFINITION

df$recommendation=df$q14_group 
df$q14_group=NULL

#Convert the outcome variable below to a factor

df$recommendation=as.factor(df$recommendation) 


#START OF REDUNDANT VARIABLE REMOVAL

#Remove these variables - reduce redundancy for the commercial 

df$q5a_text=NULL      
df$q5b_text=NULL 
df$q5c_text=NULL 
df$q5d_text=NULL
df$q9_text=NULL 
df$q11_text=NULL 
df$q25_text=NULL  

#Remove 'Rings' as we are modeling its categorical version (rings_grp)
df$q14=NULL

df <- df %>% mutate_all(as.factor)

#END OF REDUNDANT VARIABLE REMOVAL

#STRUCTURE AND SUMMARY OF THE DATA

str(df)

#START OF DATA BREAKDOWN FOR HOLDOUT METHOD

nobs=dim(df)[1]
set.seed(1) #sets the seed for random sampling

train_size=round(0.8*nobs)
test_size=nobs-train_size


train_index=sample(nobs,train_size,replace=F) #returns train_size numbers randomly chosen from 1 to nobs without replacement.
#The training set will consist of observations sampled from the original data at
#locations indiced by the train_index



df_train=df[train_index,] #randomly select the data for training set using the row numbers generated above
df_test=df[-train_index,]#everything not in the training set should go into testing set

dim(df_train) #confirms that training data has only 80% of observations
dim(df_test) #confirms that testing data has 20% of observations

#END OF DATA BREAKDOWN FOR HOLDOUT METHOD


#(Over)Fit the tree, then prune it to a more manageable size


trained=rpart(recommendation ~ ., 
              data = df_train, 
              cp=min_cp, 
              minbucket=minbucket)

#printcp(trained)
#plotcp(trained)

optimal_cp = trained$cptable[which.min(trained$cptable[, "xerror"]), "CP"]

# Prune the tree
pruned_tree <- prune(trained, cp = optimal_cp)

# View the pruned tree
plot(pruned_tree)
rpart.plot(pruned_tree, type=5)

#Start predicting the test set

predicted_raw=predict(pruned_tree, df_test)
predicted <- apply(predicted_raw, 1, function(row) colnames(predicted_raw)[which.max(row)])
predicted_raw=cbind(predicted_raw, predicted)
df.test.with.pred=cbind(predicted_raw,df_test)


#Evaluate the predictive accuracy
#Confusion matrix
predictions <- predict(pruned_tree, df_test, type = "class")
df.test.with.pred$predicted <- predictions

df.test.with.pred <- df.test.with.pred[complete.cases(df.test.with.pred), ]
df.test.with.pred <- droplevels(df.test.with.pred)

df.test.with.pred$recommendation <- as.factor(df.test.with.pred$recommendation)
df.test.with.pred$predicted <- as.factor(df.test.with.pred$predicted)

CrossTable(df.test.with.pred$recommendation, df.test.with.pred$predicted, prop.chisq = FALSE, prop.t = FALSE)

#Compare with benchmark performance, i.e. if all predictions for testing set observations
#Were the class that dominated the training set (i.e. most frequent training class)

benchmark.pred=rep(names(which.max(table(df_train$recommendation))), nrow(df_test))
bench.df=as.data.frame(cbind(predicted=benchmark.pred, df_test))

bench.acc=100*sum(bench.df$predicted==bench.df$recommendation)/nrow(bench.df)
model.acc=100*sum(df.test.with.pred$predicted==df.test.with.pred$recommendation)/nrow(df.test.with.pred)

#Print benchmark and model performance
print(paste("Benchmark Accuracy: ", round(bench.acc,2)))
print(paste("Model Accuracy: ", round(model.acc,2)))
