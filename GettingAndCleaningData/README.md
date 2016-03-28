# datasciencecoursera
## Final 'Getting and cleaning data' course project

This readme file describes how the run_analyses script works.
It assumes that the data is in a .zip file in the working directory. It will skip the unpacking if there already exists a folder named 
"UCI HAR Dataset" that is also in your working directory.

Next, the following 5 steps will be executed by the script:

1. It collects the 'train' and 'test' data from all subjects. It merges them together to get a total dataset of all features (V1 ..) and it will rename the first two columns to 'subject' and 'activityNum'

2. From all the features available it will only substract the mean and std variables.

3. Rename the integers in the 'activityNum' column to the real names/values

4. Extract from the feature names the variables that mean something and make a new descriptive column for those (for example Body/Gravity, time/frequency, Gyroscope/Accelerometer and others), when there is no descriptive name as such then a NA is given.

5. Calculate for each combination of subject/activity and features the mean

6. This block of code will generate the codebook