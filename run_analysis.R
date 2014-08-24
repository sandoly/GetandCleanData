#### Name: run_analysis.R
#### Description: This code downloads data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip URL address,
####              merge the training and test data set, extracts mean and standard deviation of each measurements,
####              make some cosmetics with labels, and finally creates an independent tidy data set with the average of each variable 
####              for each activity and each subject.   
#### Created by: Szabolcs Sandoly   

## load required libraries
library(data.table)
library(stringr)
library(reshape2)

## download data
if (!file.exists("data")) {                                                 # create data folder to download data if data directory does not exist
        dir.create("data") }
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                                                                            # download URL
if(!file.exists('./data/UCI-HAR-Dataset.zip')) {                             # if file does not exists download it to data folder 
        download.file(fileURL, "./data/UCI-HAR-Dataset.zip")
}
unzip("./data/UCI-HAR-Dataset.zip", exdir = "./data")                       # unzip file to data folder

#if (file.exists("./data/UCI-HAR-Dataset.zip")) file.remove("./data/UCI-HAR-Dataset.zip")    
                                                                            # delete zip file

## processing common data from root (UCI HAR Dataset) folder
activity.labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", header = F)
                                                                            # load activity labels into 'activity.labels' data frame 
# format activity labels                                                                          
activity.labels[,2] <- tolower(activity.labels[,2])                         # to lowercase
activity.labels[,2] <- gsub("(^|[[:punct:]])([[:alpha:]])","\\1\\U\\2"      # to capitalize starting of words
                            , activity.labels[,2], perl = TRUE)
activity.labels[,2] <- gsub("([[:punct:]])",""                              # remove _ 
                            , activity.labels[,2], perl = TRUE)
                                                                            
features <- read.table("./data/UCI HAR Dataset/features.txt", header = F,   # load measurements (features) number and label into 'features' data frame
                        strip.white = T, stringsAsFactors = F )

## processing 'train' data
y.train <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header = F 
                      , strip.white = T, stringsAsFactors = F)              # load activity labels of train set into 'y.train' data frame

subject.train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt"
                            , col.names=c("Subject"), header = F)    
                                                                            # load subject train data into 'subject.train' data frame
                                                                            

activity.y.train <- data.frame(Activity.Nr = y.train$V1, 
                    Activity = activity.labels[match(y.train$V1,activity.labels$V1),2])
                                                                            # Match activity number in 'y.train' with activity number in 'activity.labels' 
                                                                            # and add the corresponding activity label in a new column in the 'activity.y.train' data frame 



x.train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header = F,
                       , colClasses = rep("numeric",561),
                       strip.white = T, stringsAsFactors = F)               # load train measurements data into 'x.train' data frame       
colnames(x.train) <- features[,2]                                           # name the columns after measurements (features) label from 
                                                                            # 'features' data frame
 
temp <- cbind(subject.train, activity.y.train)                              # join 'subject.train' and 'activity.y.train' data frame temporary
train.set <- cbind(temp, x.train)                                           # join temporary data frame with x.train in 'train.set'

DT.train.set <- as.data.table(train.set)                                    # transform 'train.set' to data.table

rm(activity.y.train, temp, x.train, y.train, subject.train, train.set)
                                                                            # remove unused data frames to free up memory

## processing 'test' data     
y.test <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header = F   # load activity labels of test set into 'y.test' data frame
                      , strip.white = T, stringsAsFactors = F)

subject.test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt"   # load subject test data into 'subject.test' data frame
                            , col.names=c("Subject"), header = F)

activity.y.test <- data.frame(Activity.Nr = y.test$V1, Activity = activity.labels[match(y.test$V1,activity.labels$V1),2])
                                                                            # Match activity number in 'y.test' with activity number in 'activity.labels' 
                                                                            # and add the corresponding activity label in a new column in the 'activity.y.test' data frame

x.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header = F,
                       , colClasses = rep("numeric",561),
                       strip.white = T, stringsAsFactors = F)               # load test measurements data into 'x.test' data frame
colnames(x.test) <- features[,2]                                            # name the columns after measurements (features) label from 
                                                                            # 'features' data frame 
   
temp <- cbind(subject.test, activity.y.test)                                # join 'subject.test' and 'activity.y.test' data frame temporary
test.set <- cbind(temp, x.test)                                             # join temporary data frame with 'x.test' in 'test.set'

DT.test.set <- as.data.table(test.set)                                      # transform 'test.set' to data.table

rm(activity.y.test, temp, x.test, y.test, subject.test, test.set)           # remove unused data frames to free up memory

rm(activity.labels,features)                                                # remove more unused data frames to free up memory

## join train data set (DT.train.set) and test data set (DT.test.set) and sort by Subject then Activity Number

DT.summary <- rbind(DT.test.set, DT.train.set)                              # binding 'DT.test.set' with 'DT.train.set' in 'DT.summary'
rm(DT.train.set,DT.test.set)                                                # remove unused data tables to free up memory

DT.summary.sorted <- DT.summary[order(DT.summary$Subject,DT.summary$Activity.Nr)]
                                                                            # sort rows in 'DT.summary' by "Subject" then "Activity.Nr" variable
rm(DT.summary)                                                              # remove unused data table to free up memory

## Selecting data
titles <- names(DT.summary.sorted)                                          # load 'DT.summary.sorted' data table header into 'titles' character vector                           
                                                                            # creating a mask, colSelection, that contains which columns we keep 
colSelection <- str_detect(titles, "std()|mean()")                          # select all features in "titles" that end with "mean()" or "std()"
colSelection[1] <- TRUE                                                     # keep "Subject" column                                                
colSelection[3] <- TRUE                                                     # keep "Activity" column   
columnMask <- which(colSelection)                                           # transform logical column selection to column index 
DT.tidy <- DT.summary.sorted[, columnMask, with=FALSE]                      # load selected columns into DT.tidy data table

rm(colSelection, columnMask, DT.summary.sorted, titles)                     # free up workspace memory

## Giving descriptive variable labels ergo Cosmetics
titles <- names(DT.tidy)                                                    # load 'DT.tidy' header into 'titles' character vector
titles <- str_replace(titles, "^t" , "Time")
titles <- str_replace(titles, "Freq" , "Frequency")
titles <- str_replace(titles, "^f" , "Frequency")
titles <- str_replace(titles, "Acc" , "Acceleration")
titles <- str_replace(titles, "Gyro" , "Gyroscope")
titles <- str_replace(titles, "Mag" , "Magnitude")
titles <- str_replace(titles, "mean" , "Mean")
titles <- str_replace(titles, "std" , "StandardDeviation")
titles <- str_replace_all( titles, "[[:punct:]]", "")                       # remove punctuation
titles <- str_replace(titles, "X" , "Xaxis")
titles <- str_replace(titles, "Y" , "Yaxis")
titles <- str_replace(titles, "Z" , "Zaxis")

setnames(DT.tidy,titles)                                                    # replace old column names by the new ones
rm(titles)                                                                  # free up workspace memory

## Producing Tidy Data Set
DT.melted <- melt(DT.tidy, id.vars = c("Activity", "Subject")               # reshapes DT.tidy, separate id variables (Activity, Subject)
            , variable.name = "Variable", value.name = "Value")             # from measure variables 
                                                                            

DF.tidiest <- dcast(DT.melted, Subject + Activity ~ Variable,
                    fun.aggregate = mean, value.var = "Value")              # use dcast to calculate mean of each measure variables
                    
rm(DT.melted)                                                               # free up workspace memory

## Saving file
write.table(DF.tidiest, file="./data/TidyMeasurement.txt", sep=","          # save 'DF.tidiest' to a txt file
            , row.names=FALSE, col.names=TRUE)