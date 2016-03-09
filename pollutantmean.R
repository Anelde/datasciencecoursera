#part1
pollutantmean <- function(directory, pollutant, id = 1:332) {
      means <- data.frame()
      counter <- 1
      id <- sprintf("%03d", id)
      for(i in id) {
            file <- paste(directory, "/", paste(i, ".csv", sep = ""), sep = "")
            data <- read.csv(file)  
            m <- mean(data[,pollutant], na.rm = TRUE)
            means[counter,1] <- m
            counter <- counter + 1
      }
      mean(means[,], na.rm = TRUE)
}