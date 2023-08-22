
pipe::clean_workspace()

source('init.R')

# Parámetros ---------------------------------------------------------------
config <- pipe::readConfig("config.yaml")


parametros <- list(
                optparse::make_option(
                                "--o_magic_number_r"    ,
                                default = config$io_primary$magic_number_r,
                                type = "character",
                                help = "Datos de Actix"
                )
)

param <- pipe::convert_to_list(parametros) 



# Configuracion -----------------------------------------------------------


# Transformation -----------------------------------------------------------


magic_number_r <- 11




# Grabar ------------------------------------------------------------------

saveRDS(magic_number_r, param$o_magic_number_r)

