pipe::clean_workspace()

# Librerias ---------------------------------------------------------------
source('init.R')
library(DBI)
library(RSQLite)


# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")

argumentos <- list(
                make_option("--periodo" , default = config$periodo ,type='character' ,help='identificación unica de iteración'),
                make_option("--i_merged_cities_raw", default = config$io_raw$merged_cities_raw ,type='character' ,help='identificación unica de iteración'),
                make_option("--o_cliente_info", default = config$io_primary$cliente_info ,type='character' ,help='identificación unica de iteración')
                
                
)

# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)


# Cargar datos ------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), dbname = "workshop.sqlite")
atributos <- dbGetQuery(con, glue("SELECT * FROM atributos where periodo='{param$periodo}'"))
dbDisconnect(con)


df_cities <- readr::read_csv(param$i_merged_cities_raw) 
df_cities <- df_cities %>% select(city_name_cliente,standardized_city_name) %>% unique()


#esta columna estaba danbdo problemas
atributos$education_level <- NULL

#clean strings for all columns that are character
atributos <- atributos %>% mutate_if(is.character, ~stringr::str_replace_all(.x, "[^[:alnum:]]", ""))





# Junta la info de la cuidad ----------------------------------------------

df_join <- atributos %>% left_join(df_cities, by=c('residencial_city'='city_name_cliente'))


# Guardar -----------------------------------------------------------------

df_join$periodo <- as.Date(df_join$periodo,format = "%Y%m%d")


arrow::write_dataset(df_join,param$o_cliente_info, format = "parquet", partitioning = "periodo")

print('w00 Done')





