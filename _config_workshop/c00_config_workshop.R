pipe::clean_workspace()

# Librerias ---------------------------------------------------------------
source('init.R')


# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")

argumentos <- list(
                make_option("--i_cliente_data", default = config$config$i_datos ,type='character' ,help='identificación unica de iteración'),
                make_option("--i_variable_list", default = config$config$i_Var ,type='character' ,help='identificación unica de iteración'),
                make_option("--o_cliente_info", default = config$io_raw$riesgo_cliente_raw ,type='character' ,help='identificación unica de iteración')
                
                
)

# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)


# Cargar datos ------------------------------------------------------------

df <- readr::read_delim(param$i_cliente_data,delim="\t",col_names = FALSE)
variables <- readxl::read_xls(param$i_variable_list)

# Agregar nombre a las columnas -------------------------------------------

names(df)<-variables$Var_Title

#esta columna estaba danbdo problemas
df$EDUCATION_LEVEL <- NULL



# Agregar fechas ----------------------------------------------------------

set.seed(123)
date_vector <- c('2023-01-01', '2023-02-01', '2023-03-01', '2023-04-01', '2023-05-01','2023-06-01','2023-07-01')


df <- df %>% mutate(PERIODO = sample(date_vector, size = n(), replace = TRUE))

df <- df %>% mutate(PERIODO=as.Date(PERIODO))


# Transformacion ----------------------------------------------------------

names(df) <- tolower(names(df))
names(df) <- gsub("=", "_", names(df))


# Separar entre atributo y fenomeno ---------------------------------------

variable_y <- 'target_label_bad_1'



df_x <- df %>% 
                select(-all_of(variable_y)) %>%
                arrange(periodo,id_client ) %>%
                select(periodo,id_client, everything()) %>%
                mutate(periodo=format(periodo, "%Y-%m-%d"))

df_y <- df %>% select(periodo, id_client, variable_y) %>% 
                arrange(periodo, id_client) %>%
                mutate(periodo=format(periodo, "%Y-%m-%d"))


# Save in sqllite ---------------------------------------------------------

library('RSQLite')
library('DBI')

con <- dbConnect(RSQLite::SQLite(), dbname = "workshop.sqlite")


dbWriteTable(con, "atributos", df_x)


new_dfs <- split(df_x, df_x$periodo)

# Insert data into the table partition by partition
for(partition_name in names(new_dfs)){
                
                partition <- new_dfs[[partition_name]]
                
                # Delete existing data for this partition
                dbExecute(con, paste0("DELETE FROM atributos WHERE periodo = '", partition_name, "'"))
                
                # Insert new data
                dbWriteTable(con, "atributos", partition, append=TRUE)
}

# Disconnect from the database
dbDisconnect(con)



# Save in sqllite ---------------------------------------------------------

library('RSQLite')
library('DBI')

con <- dbConnect(RSQLite::SQLite(), dbname = "workshop.sqlite")


dbWriteTable(con, "fenomeno", df_y)


new_dfs <- split(df_y, df_y$periodo)

# Insert data into the table partition by partition
for(partition_name in names(new_dfs)){
                
                partition <- new_dfs[[partition_name]]
                
                # Delete existing data for this partition
                dbExecute(con, paste0("DELETE FROM fenomeno WHERE periodo = '", partition_name, "'"))
                
                # Insert new data
                dbWriteTable(con, "fenomeno", partition, append=TRUE)
}

# Disconnect from the database
dbDisconnect(con)



# Create a connection to the SQLite database (it will be created if it doesn't exist)
con <- dbConnect(RSQLite::SQLite(), dbname = "workshop.sqlite")

# Run a SQL query
result <- dbGetQuery(con, "SELECT * FROM fenomeno")
atributos <- dbGetQuery(con, "SELECT * FROM atributos")

# Disconnect from the database
dbDisconnect(con)



