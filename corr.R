#part3
corr <- function(directory, threshold = 0) {
      obs <- complete(directory)
      files <- subset(obs, nobs >= threshold)
      counter <- 1
      correlations <- data.frame()
      for (id in files[,1]) {
            id <- sprintf("%03d", id)
            file <- paste(directory, "/", paste(id, ".csv", sep = ""), sep = "")
            data <- read.csv(file)  
            collist <- c("sulfate", "nitrate")
            data <- data[complete.cases(data[collist]), collist]
            c <- cor(data$nitrate, data$sulfate)
            correlations[counter,1] <- c
            counter <- counter + 1
      }
      if (nrow(correlations) == 0) {
            vector('numeric')
      } else {
            correlations
      }
      
}