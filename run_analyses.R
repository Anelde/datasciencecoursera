## Final project Getting and Cleaning data

# packages
library(data.table)
library(reshape2)
library(knitr)

# data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"

path <- getwd()
download.file(url, file.path(path, f))

#unzip file
unzip(f)
pathData <- file.path(path, "UCI HAR Dataset")

# read data
dataTrainSubject <- fread(file.path(pathData, "train", "subject_train.txt"))
dataTrainY <- fread(file.path(pathData, "train", "Y_train.txt"))
dataTrainX <- fread(file.path(pathData, "train", "X_train.txt"))

dataTestSubject  <- fread(file.path(pathData, "test" , "subject_test.txt" ))
dataTestY  <- fread(file.path(pathData, "test" , "Y_test.txt" ))
dataTestX  <- fread(file.path(pathData, "test" , "X_test.txt" ))

# 1. "Merges the training and the test sets to create one data set."

# Both datasets for Train and Test have the same numeber of columns, 
#so we need to add up all the rows (rbind)
dataSubject <- rbind(dataTrainSubject, dataTestSubject)
setnames(dataSubject, "V1", "subject")
dataActivity <- rbind(dataTrainY, dataTestY)
setnames(dataActivity, "V1", "activityNum")
dataX <- rbind(dataTrainX, dataTestX)

# now we need to combine the datasets between the subject and activity sets
dataSubject <- cbind(dataSubject, dataActivity)
# and finally merge the subject/activity data with the measurements
dataset <- cbind(dataSubject, dataX)

# 2. "Extracts only the measurements on the mean and standard deviation for each measurement."

# in the feature.txt file it is written which variables are representing the mean 
# and standard deviation
dataFeatures <- fread(file.path(pathData, "features.txt"))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))

# look for any 'mean' and ' std' in the names, use regular expressions to find the 
# string expression for mean and std in the name
dataFeatures <- dataFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
# link the feature numbers in column 1 to the column names in the dataset (featureCodes)
dataFeatures$featureCode <- dataFeatures[, paste0("V", featureNum)]

# subset only these columns in the dataset
select <- c("subject", "activityNum", dataFeatures$featureCode)
dataset <- dataset[, select, with=FALSE]

#3. Uses descriptive activity names to name the activities in the data set

# In the activity_labels.txt file is written where each activity number stands for
# read activity_labels.txt
dataActivityNames <- fread(file.path(pathData, "activity_labels.txt"))
setnames(dataActivityNames, names(dataActivityNames), c("activityNum", "activityName"))
# add ezxtra column with activity name by merging this datset set with the main dataset
dataset <- merge(dataset, dataActivityNames, by="activityNum", all.x=TRUE)

# set the key for this data to the combination of subject and activity
setkey(dataset, subject, activityNum, activityName)
# reshape the dataset to put everything below eachother
dataset <- data.table(melt(dataset, key(dataset), variable.name="featureCode"))
dataset <- merge(dataset, dataFeatures[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)

# 4. make the activity name and feature name a factor
# Create a new variable, activity that is equivalent to activityName as a factor class. 
# Create a new variable, feature that is equivalent to featureName as a factor class.
dataset$activityName <- factor(dataset$activityName)
dataset$featureName <- factor(dataset$featureName)

# refactor code so that the features are clearly visible
grepthis <- function (regex) {
      grepl(regex, dataset$featureName)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow=n)
# if featureName variable contains an 't' at the beginning then it means it represents
# a count, if there is a 'f' then it mean frequency
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol=nrow(y))
dataset$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
# if featureNAme variable contains 'Acc' anywhere in the variable name it means 'Accelerometer'
# if it contains 'Gyro' it means 'Gyroscope'
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol=nrow(y))
dataset$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
# if featureNAme variable contains 'BodyAcc' it gets an extra label called 'Body'
# Otherwise there is 'GravityAcc' in the name and that means 'Gravity'
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol=nrow(y))
dataset$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
# if featureNAme variable contains mean ot std it means respectively the mean or 
# standard deviation (SD)
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol=nrow(y))
dataset$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))
## Features with 1 category
dataset$featJerk <- factor(grepthis("Jerk"), labels=c(NA, "Jerk"))
dataset$featMagnitude <- factor(grepthis("Mag"), labels=c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol=nrow(y))
dataset$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))

# 5. Create a tidy set that shows the mean for every variable per 
# each subject/ activity/ feature combination
setkey(dataset, subject, activityName, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dataTidy <- dataset[, list(count = .N, average = mean(value)), by=key(dataset)]

# Make a codebook
knit("run_analyses.R", output="codebook.md", encoding="ISO8859-1", quiet=TRUE)
