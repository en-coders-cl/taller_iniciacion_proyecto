pipe::clean_workspace()

# Librerias ---------------------------------------------------------------
source('init.R')

# Parametros --------------------------------------------------------------

config <- pipe::readConfig("config.yaml")

argumentos <- list(
                make_option("--periodo", default = config$periodo ,type='character' ,help='INPUT'),
                make_option("--i_cliente_info", default = config$io_primary$cliente_info ,type='character' ,help='INPUT'),
                make_option("--i_cities_info", default = config$io_primary$cities_info ,type='character' ,help='INPUT'),
                make_option("--i_forest_fire", default = config$io_primary$forest_fire ,type='character' ,help='INPUT'),
                make_option("--i_magic_number", default = config$io_primary$magic_number ,type='character' ,help='INPUT'),
                make_option("--i_magic_number_r", default = config$io_primary$magic_number_r ,type='character' ,help='INPUT'),
                make_option("--o_tablon_atributos", default= config$io_master$tablon_atributos ,type='character' ,help='INPUT')
                
)

# Argumentos a Parametros
param <- pipe::convert_to_list(argumentos)


# Read data ---------------------------------------------------------------

tic('Datos Info Cliente')
ds <- arrow::open_dataset(param$i_cliente_info, format = "parquet")
ds <- ds %>% dplyr::filter(periodo == param$periodo) 
so <- arrow::Scanner$create(ds)
AT <- so$ToTable()
df_cliente_info <- as.data.frame(AT)
toc()


df_cities_info <- arrow::read_feather(param$i_cities_info)
df_forest_fire <- arrow::read_feather(param$i_forest_fire)
df_magic_number <- arrow::read_feather(param$i_magic_number)
magic_number_r <- readRDS(param$i_magic_number_r)

# Join --------------------------------------------------------------------

tablon_cliente <- df_cliente_info %>% left_join(df_cities_info, by = c('standardized_city_name'))


tablon_cliente_forest <- tablon_cliente %>% left_join(df_forest_fire,by=c('STATE'='abbreviation'))

set.seed(df_magic_number$magic_number)
tablon_cliente_forest_magic <- tablon_cliente_forest %>% mutate(random_col = runif(nrow(.)))


set.seed(magic_number_r)
tablon_cliente_forest_magic <- tablon_cliente_forest_magic %>% mutate(random_col_r = runif(nrow(.)))


tablon_cliente_forest_magic <- tablon_cliente_forest_magic %>% select(periodo, id_client, everything())


# Write -------------------------------------------------------------------

arrow::write_dataset(tablon_cliente_forest_magic,param$o_tablon_atributos, format = "parquet", partitioning = 'periodo')


