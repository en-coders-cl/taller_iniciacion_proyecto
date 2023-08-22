pipe::clean_workspace()

# Librerias ---------------------------------------------------------------
library(h2o)

# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")

argumentos <- list(
                make_option("--i_tablon_maestro",default = config$io_master$tablon_master ,type = 'character' ,help = 'tiempo dedicado a entrenar'),
                make_option("--o_tablon_maestro_train",default = config$io_master$tablon_master_train ,type = 'character' ,help = 'tiempo dedicado a entrenar'),
                make_option("--o_tablon_maestro_test",default = config$io_master$tablon_master_test ,type = 'character' ,help = 'tiempo dedicado a entrenar'),
                make_option("--o_fited_model",default = config$io_master$fited_model ,type = 'character' ,help = 'tiempo dedicado a entrenar'),
                make_option("--horas_entrenamiento",default = config$horas_entrenamiento ,type= 'numeric', help = 'tiempo dedicado a entrenar'),
                make_option("--split",default = config$split ,type = 'numeric' ,help = 'tiempo dedicado a entrenar')
)

# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)




# Cargar Datos ------------------------------------------------------------
df <- arrow::read_feather(param$i_tablon_maestro)

# Definir variable objetivo -----------------------------------------------

variable_objetivo <- "target_label_bad_1"

df$target_label_bad_1 <- as.factor(df$target_label_bad_1)


# Inicializar h2o
h2o.init()

# Samplear ----------------------------------------------------------------
# df a h2o
df_h2o <- as.h2o(df, destination_frame = "df_h2o")

# División cjtos
sets_h2o<-h2o.splitFrame(df_h2o,ratios = param$split, destination_frames = c("train","test"), seed = 1234)


# AutoML
tic("AutoML")

aml <- h2o.automl(
                x = setdiff(names(df_h2o), variable_objetivo),
                y = variable_objetivo,
                training_frame = sets_h2o[[1]],
                max_runtime_secs = param$horas_entrenamiento*3600,
                stopping_metric = "AUC",
                stopping_rounds = 10,
                stopping_tolerance = 0.001,
                seed = 1234,
                nfolds = 10,
                sort_metric = "auc",
                balance_classes = TRUE,
                max_models = 10
)

best_model <- aml@leader

# Obtener mejor modelo y guardar
# best_model <- h2o.getModel(lb@model_ids[[1]]) 

system(paste0('rm -rf ',param$o_fited_model))
h2o.saveModel(best_model, param$o_fited_model)

system(paste0('rm -rf ',param$o_fited_model))
h2o.save_mojo(best_model, param$o_fited_model)

# Guardar Split
system(paste0('rm -rf ',param$o_tablon_maestro_train))
h2o.exportFile(sets_h2o[[1]],param$o_tablon_maestro_train,force = TRUE)

system(paste0('rm -rf ',param$o_tablon_maestro_test))
h2o.exportFile(sets_h2o[[2]],param$o_tablon_maestro_test,force = TRUE)

# Cerrar h2o
h2o.shutdown(prompt = FALSE)


print('w02 Done')
