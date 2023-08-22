pipe::clean_workspace()

source('init.R')

config <- pipe::readConfig("config.yaml")


# Ejecución ETL ---------------------------------------------------------------

pipe::run('venv/bin/python','etl/cities_info/w00_etl_cities_info.py',config)


pipe::run('venv/bin/python','etl/forest/w00_etl_forest_fires.py',config)


pipe::run('venv/bin/python','preprocessing/w01_get_datalake_with_python.py',config)


pipe::run('Rscript','preprocessing/w01_get_datalake_with_R.R',config)



# Procesos Mensuales ------------------------------------------------------


lista_fechas = seq(from=as.Date(config$periodo_inicio), to=as.Date(config$periodo_final), by="month")

for (fecha in lista_fechas) {
                fecha = format(as.Date(fecha,origin="1970-01-01"),"%Y-%m-%d")
                config$periodo <- fecha
                print(config$periodo)
                
                pipe::run('Rscript','preprocessing/w01_prep_client_info.R',config)
 
                pipe::run('Rscript','preprocessing/w01_prep_fenomeno_cliente.R',config)
                
                pipe::run('Rscript','preprocessing/w02_create_tablon_atributo.R',config)
}



pipe::run('venv/bin/python','preprocessing/w03_crear_tablon_maestro.py',config)











