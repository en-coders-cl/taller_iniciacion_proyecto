#' Plot a Confusion Matrix
#'
#' This function creates a base R plot of a confusion matrix
#'
#' @param predict A vector with the predictions
#' @param response A vector with the actual classes
#' @param positive int, char, boolean specifying the positive class
#' @param get_metrics boolean, if TRUE prints basic metrics: Accuracy, Precision, Recall, F1-Score
#' @param main A string representing the title of the chart
#' @param frame.plot boolean, if TRUE plots a line around the confusion matrix
#'
#' @return A base R plot
#' @export
#'
#' @examples 
#' predict <- runif(1000) > 0.5 
#' response <- runif(1000) > 0.5 
#' plotConfusionMatrix(predict, response, positive = TRUE) 
plotConfusionMatrix <- function(predict, response, positive, get_metrics = TRUE, main = "Confusion Matrix", frame.plot = FALSE) {
                
                predict  <- as.character(predict)
                response <- as.character(response)
                positive <- as.character(positive)
                negative <- setdiff(union(unique(predict), unique(response)), positive)
                
                pred <- factor(predict,  levels = c(negative,positive))
                resp <- factor(response, levels = c(negative,positive))
                
                confusion_matrix <- table(pred, resp)
                
                TP <- confusion_matrix[2, 2]
                FP <- confusion_matrix[2, 1]
                TN <- confusion_matrix[1, 1]
                FN <- confusion_matrix[1, 2]
                
                if(is.null(main)) {
                                main = "Confusion Matrix"
                }
                
                # plot confusion matrix
                layout(matrix(c(1)))
                plot(1:2, 1:2, type = "n", xaxt='n', yaxt='n', frame.plot = frame.plot, xlab = "", ylab = "")
                title(main, cex.main=1, line = .5, adj = 0)
                
                # Actual labels
                text(1.5, 2.25, "Actual", cex=1.1)
                text(1, 2.07, levels(pred)[1], cex=0.8)
                text(2, 2.07, levels(pred)[2], cex=0.8)
                
                # Prediction Labels
                text(0.3, 1.5, "Predicted", cex=1.1, srt = 90)
                text(0.7, 1, levels(pred)[1], cex=0.8, srt = 90)
                text(0.7, 2, levels(pred)[2], cex=0.8, srt = 90)
                
                # Values of TP, FP, ...
                text(1, 1, FP, cex=1.4)
                text(2, 1, TP, cex=1.4)
                text(1, 2, TN, cex=1.4)
                text(2, 2, FN, cex=1.4)
                
                if(get_metrics){
                                accuracy  = round((TP+TN)/(TP+TN+FP+FN),5)
                                precision = round(TP/(TP+FP),5)
                                recall    = round(TP/(TP+FN),5)
                                f1        = round(2*(precision*recall)/(precision+recall),5)
                                cat("Accuracy  ", accuracy,"\n")
                                cat("Precision ", precision,"\n")
                                cat("Recall    ", recall,"\n")
                                cat("F1-score  ", f1,"\n")
                }
}
