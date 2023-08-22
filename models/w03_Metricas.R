pipe::clean_workspace()


# librerias ---------------------------------------------------------------
library(h2o)

source('functions/plotConfusionMatrix.R')
source('functions/getROC.R')
source('functions/plotROC.R')


# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")


argumentos <- list(
                make_option("--i_tablon_maestro_test",default = config$io_master$tablon_master_test ,type = 'character' ,help = 'tiempo dedicado a entrenar'),
                make_option("--i_fited_model",default = config$io_master$fited_model ,type = 'character' ,help = 'tiempo dedicado a entrenar')
)


# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)


# Ruta Inputs -------------------------------------------------------------


# Cargar archivos ---------------------------------------------------------
# inicializar h2o
h2o.init()

# modelo
modelo_rf <- h2o.import_mojo(param$i_fited_model)

# Sets de datos
test_set <- h2o.importFile(param$i_tablon_maestro_test)

# Evaluar desempeño conjunto de test --------------------------------------
# Valores predichos por el modelo
test_pred <- h2o.predict(modelo_rf, newdata=test_set) %>%  as.data.frame() 

# Valores reales
test_pred$real <- test_set %>%  as.data.frame() %>%  select(target_label_bad_1) %>%  pull() %>%  as.factor()

# Matriz de Confusion
plotConfusionMatrix(predict=test_pred$predict,response=test_pred$real, positive=TRUE)

# ROC - AUC
rocs <- getROC(score = test_pred$p1, response = as.numeric(as.character(test_pred$real)))


print('w03 Done')
