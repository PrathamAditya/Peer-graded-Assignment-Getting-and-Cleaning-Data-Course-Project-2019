# Step 1 
# Download dataset
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- file.path(getwd(), "dataset.zip")
if (!file.exists(f)) {
    download.file(url, f, mode = "wb")
}

# Step 2 
# Unzip dataset
dataPath <- "dataset"
if (!file.exists(dataPath)) {
    unzip(f)
}


# Step 3 
# Loading testing data
x_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")
subject_test <- read.table("subject_test.txt")


# Step 4 
# Loading training data
x_train <- read.table("X_train.txt")
y_train <- read.table("y_train.txt")
subject_train <- read.table("subject_train.txt")

# Step 5 
# Loading feature data
features <- read.table("features.txt")

# Step 6 
# Loading activity labes data
activityLabels = read.table("activity_labels.txt")

# Step 7 
# Labelling column names of training and testing data
colnames(x_train) <- features[,2]
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"
colnames(activityLabels) <- c('activityId','activityType')

# Step 8 
# Merging dataset
mgtrain <- cbind(y_train, subject_train, x_train)
mgtest <- cbind(y_test, subject_test, x_test)
mrg_data <- rbind(mgtrain, mgtest)
colNames <- colnames(mrg_data)

# Step 8 
# Merging data with activity labels
label <- (grepl("activityId" , colNames) | 
                     grepl("subjectId" , colNames) | 
                     grepl("mean.." , colNames) | 
                     grepl("std.." , colNames) 
)
data_wants <- data[ , label == TRUE]
completed_data <- merge(data_wants, activityLabels,by='activityId', all.x=TRUE)

# Step 9
# Create a second, independent tidy data set with the average of each variable
# for each activity and each subject

library(reshape2)
completed_data$activityId <- factor(completed_data$activityId, levels = activityLabels[,1], labels = activityLabels[,2])
completed_data$subjectId <- as.factor(completed_data$subjectId)
completed_data_melted <- melt(completed_data, id = c("subjectId", "activityId"))
completed_data_mean <- dcast(completed_data_melted, subjectId + activityId ~ variable, mean)

write.table(completed_data_mean, "tidy_data.txt", row.name=FALSE)
