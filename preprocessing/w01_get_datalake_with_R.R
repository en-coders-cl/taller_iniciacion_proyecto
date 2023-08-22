
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
s3_staging_dir = paste0(config$s3_staging_dir, config$s3_output_directory)
con <-DBI::dbConnect(RAthena::athena(), s3_staging_dir=s3_staging_dir )


query <- glue("select 
                   semana_anio,
                   count(semana_anio) as count
                   from {config$schema_name }.{config$tabla_de_test}
                   group by semana_anio limit 10 ")

df_magic_number <- DBI::dbGetQuery(con, query)



# Transformation -----------------------------------------------------------


magic_number_r <- max(df_magic_number$count)




# Grabar ------------------------------------------------------------------

saveRDS(magic_number_r, param$o_magic_number_r)

