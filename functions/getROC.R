#' Calculates ROC Curve
#'
#' Calculates the ROC curve
#' @param score a numeric vector with the scores from the predictive model
#' @param response a boolean vector (TRUE or FALSE) vector with the actual values from the dataset
#' @return dataframe with the values of the ROC curve.
#' @import dplyr
#' @author Daniel Fischer, doc by Ruben
#' @examples
#' score = runif(1000)
#' response = (score + rnorm(1000,0,0.1)) > 0.5
#' ROC = getROC(score, response)
#' plot(ROC$false_positive,ROC$true_positive,type="l")
#' @seealso \code{\link{plotROC}}
#' @export

getROC = function(score, response) {
                dataset <- data.frame(score = score, response = response)
                
                # sort the dataset by score in decreasing order
                dataset <- dataset[order(dataset$score, decreasing = T), ]
                
                # calculate cumulative sum of responses
                cumsum_response <- cumsum(dataset$response)
                
                # calculate true positives and false positives
                dataset$true_positive <- cumsum_response / sum(dataset$response)
                dataset$false_positive <- cumsum(!dataset$response) / sum(!dataset$response)
                
                # create identity sequence
                dataset$identity <- seq(from = 0, to = 1, length.out = nrow(dataset))
                
                return(dataset)
}
