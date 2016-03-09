#part2
complete <- function(directory, id = 1:332) {
      completeObservations <- data.frame(id = id, nobs = c(""), stringsAsFactors=FALSE)
      id <- sprintf("%03d", id)
      counter <- 1
      for(i in id) {
            file <- paste(directory, "/", paste(i, ".csv", sep = ""), sep = "")
            data <- read.csv(file)
            collist <- c("sulfate", "nitrate")
            data <- data[complete.cases(data[collist]), collist]
            completeObservations[counter, 2] <- nrow(data)
            counter <- counter + 1
      }
      transform(completeObservations, nobs = as.numeric(nobs))
}