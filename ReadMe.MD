Getting and Cleaning Data Course Project
===========

This R-project is aimed to present a way to deliver raw data from external 
source to statisticians in a tidy form.

In summary, the raw data comes from a Human Activity Recognition database built 
from the recordings of 30 subjects performing activities of daily living 
, while carrying a waist-mounted smartphone with embedded inertial sensors.

Full description where the data comes from can be accessed on this URL: 
[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]

The raw data set can be accessed via this URL: 
[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip]

The R script called 'run_analysis.R' performs the following actions on the data set.
    - downloads and unzip the data package
    - merge the training and test data set
    - extracts mean and standard deviation of each measurements to obtain a 
      tiny dataset
    - make some cosmetics with labels to increase understanding or variables
    - finally creates an independent tidy data set, called 'DT.tidiest' with the average of each 
      variable for each activity and each subject.   

### The raw data

Access to raw data: 
[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip]
Full description where the data comes from: 
[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]

The following paragraph is a citation from the provided URL:

"The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) 
wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, 
we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. 
The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned 
into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in 
fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, 
which has gravitational and body motion components, was separated using a Butterworth low-pass filter
 into body acceleration and gravity. The gravitational force is assumed to have only low frequency components,
 therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating
 variables from the time and frequency domain. See 'features_info.txt' for more details.

For each record it is provided:

    - Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
    - Triaxial Angular velocity from the gyroscope. 
    - A 561-feature vector with time and frequency domain variables. 
    - Its activity label. 
    - An identifier of the subject who carried out the experiment.

The dataset includes the following files:
    - 'features_info.txt': Shows information about the variables used on the feature vector.
    - 'features.txt': List of all features.
    - 'activity_labels.txt': Links the class labels with their activity name.
    - 'train/X_train.txt': Training set.
    - 'train/y_train.txt': Training labels.
    - 'train/subject_train.txt': Each row identifies the subject 
        who performed the activity for each window sample. Its range is from 1 to 30.
    - 'test/X_test.txt': Test set.
    - 'test/y_test.txt': Test labels.
    - 'test/subject_test.txt': Each row identifies the subject 
        who performed the activity for each window sample. Its range is from 1 to 30."

The raw data is not manipulated during the running of the 'run_analysis.R' script.  

### The tidy data set

To obtain a tidy data set Hadley Wickham's general principles on tidy data set was followed:

    - Each variable you measure should be in one column
    - Each different observation of that variable should be in a different row
    - There should be one table for each "kind" of variable
    - If you have multiple tables, they should include a column in the table that allows them to be linked
    - Abbreviations are replaced with their longer name in the table header

### The instruction list/script

The script was tested under Windows 8.1 OS running RStudio Version 0.98.1028 with R Version 3.1.1 using  
the following R packages: Data Table  v1.9.2, Reshape2 v1.4, stringr v0.6.2

To obtain the tidy file 'TidyMeasurement.txt', the following steps have to be taken:
    Step1 - Run R Studio or R console
    Step2 - Set a working directory with 'setwd(directory)'command
    Step3 - If necessary install the following R packages: 
            Data Table  v1.9.2, Reshape2 v1.4, stringr v0.6.2, plyr v 1.8.1.
    Step4 - Run the R script with 'source("run_analysis.R")' command
    Step5 - Either print the 'DF.tidiest' data frame or load the 'TidyMeasurement.txt' to a text editor
            to see the summarized results

The script perform the following actions from scratch: 

0. Load required libraries
    [//]: # (load required libraries)
    library(data.table)
    library(stringr)
    library(reshape2)
1. Download data:
    - create data folder to download data if data directory does not exist
    - unzip file to data folder (./data/UCI HAR Dataset), then delete the zip file
    
    [//]: # (download data)
    if (!file.exists("data")) {                                                 # create data folder to download data if data directory does not exist
            dir.create("data") }
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                                                                                # download URL
    if(!file.exists('./data/UCI-HAR-Dataset.zip')) {                            # if file does not exists download it to data folder 
            download.file(fileURL, "./data/UCI-HAR-Dataset.zip")
    }
    unzip("./data/UCI-HAR-Dataset.zip", exdir = "./data")                       # unzip file to data folder

2. Process common data from root (.data/UCI HAR Dataset/) folder:
    - load activity labels from 'activity_labels.txt' into 'activity.labels' data frame
    - format activity labels (lowercase, capitalize start of each word, remove punctuation string) 
    - load measurements number and label from 'features.txt' into 'features' data frame   
    
    [//]: # (processing common data from root (UCI HAR Dataset) folder)
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
    
3. Processing 'train' data set from the (./data/UCI HAR Dataset/train/) folder:
    - load activity labels of train set from 'y_train.txt' into 'y.train' data frame
    - load subject train data from 'subject_train.txt' into 'subject.train' data frame
    - match activity number in 'y.train' with activity number in 'activity.labels', 
      then add the corresponding activity label in a new column in the 'activity.y.train' data frame
      ('Activity.Nr' column label contains the activity number e.g.: 1, 
      while 'Activity' column label contains the descriptive activity e.g.: walking)
    - load train measurements data from 'X_train.txt' into 'x.train' data frame
    - name the columns after measurements  label (features) from 'features' data frame
    - join (cbind) 'subject.train' and 'activity.y.train' data frame temporary in 'temp' data frame
    - join (cbind) temporary, 'temp' data frame with 'x.train' in 'train.set' data frame
    - transform 'train.set' to 'DT.train.set' data.table
    - remove unused data frames to free up workspace memory
    
    [//]: # (processing 'train' data)
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
4. Processing 'test' data set from the (./data/UCI HAR Dataset/test/) folder:
    - load activity labels of test set from 'y_test.txt' into 'y.test' data frame
    - load subject test data from 'subject_test.txt' into 'subject.test' data frame
    - match activity number in 'y.test' with activity number in 'activity.labels', 
      then add the corresponding activity label in a new column in the 'activity.y.test' data frame
      ('Activity.Nr' column label contains the activity number e.g.: 1, 
      while 'Activity' column label contains the descriptive activity e.g.: walking)
    - load test measurements data from 'X_test.txt' into 'x.test' data frame
    - name the columns after measurements (features) label from 'features' data frame
    - join (cbind) 'subject.test' and 'activity.y.test' data frame temporary in 'temp' data frame
    - join (cbind) temporary, 'temp' data frame with 'x.test' in 'test.set'
    - transform 'test.set' to 'DT.test.set' data.table
    - remove unused data frames to free up workspace memory

    [//]: # (processing 'test' data)   
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
    
5. Joining train data set (DT.train.set) and test data set (DT.test.set) and sortin by Subject then Activity Number
    - binding (rbind) 'DT.test.set' with 'DT.train.set' in 'DT.summary'
    - remove unused data tables to free up memory
    - sort rows in 'DT.summary' by "Subject" then "Activity.Nr" variable
    
    [//]: # (join train data set (DT.train.set) and test data set (DT.test.set) and sort by Subject then Activity Number)
    DT.summary <- rbind(DT.test.set, DT.train.set)                              # binding 'DT.test.set' with 'DT.train.set' in 'DT.summary'
    rm(DT.train.set,DT.test.set)                                                # remove unused data tables to free up memory

    DT.summary.sorted <- DT.summary[order(DT.summary$Subject,DT.summary$Activity.Nr)]
                                                                                # sort rows in 'DT.summary' by "Subject" then "Activity.Nr" variable
    rm(DT.summary)                                                              # remove unused data table to free up memory
 
6. Selecting and extracting mean and standard deviation of data 
    - load 'DT.summary.sorted' data table header into 'titles' character vector
    - creating a mask, 'colSelection', that contains which columns we keep
    - select all column names in 'titles' vector that end with "mean()" or "std()" to get all mean and standard deviation
      for each measurement
    - set 'TRUE' the appropriate column in 'colSelection' to keep "Subject" and "Activity" column
    - transform logical column selection of 'colSelection' to column index in 'columnMask' numeric vector
    - load masked columns by 'columnMask' into 'DT.tidy' data table
    - free up workspace memory
    
    [//]: # (Selecting data)
    titles <- names(DT.summary.sorted)                                          # load 'DT.summary.sorted' data table header into 'titles' character vector                           
                                                                                # creating a mask, colSelection, that contains which columns we keep 
    colSelection <- str_detect(titles, "std()|mean()")                          # select all features in "titles" that end with "mean()" or "std()"
    colSelection[1] <- TRUE                                                     # keep "Subject" column                                                
    colSelection[3] <- TRUE                                                     # keep "Activity" column   
    columnMask <- which(colSelection)                                           # transform logical column selection to column index 
    DT.tidy <- DT.summary.sorted[, columnMask, with=FALSE]                      # load selected columns into DT.tidy data table
    rm(colSelection, columnMask, DT.summary.sorted, titles)                     # free up workspace memory
    
7. Giving descriptive variable labels ergo cosmetics
    - load 'DT.tidy' header into 'titles' character vector
    - replace abbreviations with their longer name
    - remove all punctuations like '(' and ')' and '-'
    - replace old column names by the new ones
    - free up workspace memory

    [//]: # (Giving descriptive variable labels ergo Cosmetics)
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
    
8. Producing Tidy Data Set
    - reshapes 'DT.tidy', separate id variables ('Activity', 'Subject') from measure variables 
      and load into 'DT.melted' data table
    - use the plyr package to summarize the measure variables, calculating mean for all measure variables 
      and place into 'DF.tidiest' data frame in the 'Mean' column
    - free up workspace memory
    - save 'DF.tidiest' data frame to a 'TidyMeasurement.txt' file in the './data/' folder

    [//]: # (Producing Tidy Data Set)
    DT.melted <- melt(DT.tidy, id.vars = c("Activity", "Subject"),              # reshapes DT.tidy, separate id variables (Activity, Subject)
                    variable.name = "Variable", value.name = "Value")           # from measure variables  

    DF.tidiest <- dcast(DT.melted, Subject + Activity ~ Variable,
                    fun.aggregate = mean, value.var = "Value")                  # use dcast to calculate mean of each measure variables
                                                                                
    rm(DT.melted)                                                               # free up workspace memory

    [//]: # (Saving file)
    write.table(DF.tidiest, file="./data/TidyMeasurement.txt", sep=","          # save DF.tidiest to a txt file
                , row.names=FALSE, col.names=TRUE)
    
    
### The code book

The codebook file 'codebook.md' is the description of the contents of the tidy data file, 'TidyMeasurement.txt'
It also describes how was the selection of variables was made. 











