#' Plot ROC from getROC
#'
#' Returns a ggplot object with the ROC for the provided models
#' @param   rocs named list of ROC calculated with getROC or single ROC calculated with getROC
#' @param ... more results from getROC
#' @return a plot of ROC curves, 1 line per model. Additionally, a table with AUCs if required (default)
#' @importFrom purrr map2_dfr
#' @importFrom dplyr left_join group_by summarise arrange mutate as.data.frame
#' @importFrom ggplot2 ggplot aes geom_line geom_abline xlim ylim scale_color_tableau labs theme_minimal annotation_custom
#' @importFrom ggthemes scale_color_tableau theme_minimal
#' @importFrom gridExtra tableGrob
#' @examples
#' score1 = runif(1000)
#' response1 = (score1 + rnorm(1000,0,0.1)) > 0.5
#' ROC1 = getROC(score1,response1)
#' score2 = runif(1000)
#' response2 = (score2 + rnorm(1000,0,0.3)) > 0.5
#' ROC2 = getROC(score2,response2)
#' rocs = list(model1 = ROC1, model2 = ROC2)
#' plotROC(rocs)
#' #or
#' plotROC(model1 = ROC1, model2 = ROC2)
#' # or both
#' plotROC(rocs,model3 = ROC1, model4 = ROC2)
#'
#' @author Daniel Fischer, fancy mode developed by Ruben
#' @seealso \code{\link{getROC}}
#' @export

plotROC <- function(rocs = list(),
                    ..., 
                    show_auc = TRUE, 
                    fancy = TRUE) {
                # If rocs is not a list, make it a named list
                if (!is.list(rocs)) {
                                rocs <- list(model = rocs)
                }
                
                # Include extra models provided through ...
                extra_rocs <- list(...)
                rocs <- c(rocs, extra_rocs)
                
                # Prepare the dataset in tidy format
                dataset <- purrr::map2_dfr(names(rocs), rocs, function(model, values) {
                                values$model <- model
                                return(values)
                })
                
                # If fancy mode is enabled, get AUC data
                if (fancy) {
                                auc_data <- getAUC(rocs)
                                dataset <- dplyr::left_join(dataset, auc_data, by = "model")
                }
                
                # Plot ROC curve
                if (fancy) {
                                gr <- ggplot2::ggplot(dataset, ggplot2::aes(x = false_positive, y = true_positive)) +
                                                ggplot2::geom_line(ggplot2::aes(color = model), size = 1.5, alpha = 0.6) +
                                                ggplot2::geom_abline(slope = 1, intercept = 0, size = 1, linetype = 4) +
                                                ggplot2::xlim(0, 1) + ggplot2::ylim(0, 1) +
                                                ggplot2::scale_color_tableau() +
                                                ggplot2::labs(color = "Modelo", x = "FPR", y = "TPR") +
                                                ggplot2::theme_minimal()
                } else {
                                gr <- ggplot2::ggplot(dataset, ggplot2::aes(x = false_positive, y = true_positive, color = model)) +
                                                ggplot2::geom_line(size = 1.5) +
                                                ggplot2::geom_abline(slope = 1, intercept = 0, size = 1.5)
                }
                
                # If AUC should be displayed
                if (show_auc) {
                                auc_data <- getAUC(rocs)
                                gr <- gr +
                                                ggplot2::annotation_custom(gridExtra::tableGrob(auc_data, rows = NULL), xmin = 0.5, xmax = 1, ymin = 0, ymax = 0.5)
                }
                
                return(gr)
}
