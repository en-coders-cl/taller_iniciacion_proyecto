pipe::clean_workspace()

# Librerias ---------------------------------------------------------------
source('init.R')
library(DBI)
library(RSQLite)


# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")

argumentos <- list(
                make_option("--periodo" , default = config$periodo ,type='character' ,help='identificación unica de iteración'),
                make_option("--o_fenomeno_cliente", default = config$io_primary$fenomeno_cliente ,type='character' ,help='identificación unica de iteración')
                
                
)

# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)


# Cargar datos ------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), dbname = "workshop.sqlite")
fenomeno <- dbGetQuery(con, glue("SELECT * FROM fenomeno where periodo='{param$periodo}'"))
dbDisconnect(con)

# Guardar -----------------------------------------------------------------


arrow::write_dataset(fenomeno,param$o_fenomeno_cliente, format = "parquet", partitioning = "periodo")

print('w00 Done')





