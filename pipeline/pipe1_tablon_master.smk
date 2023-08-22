configfile: 'config.yaml'

#----------LIBRERIAS---------------------
import pandas as pd
from epipe import epipe

#---------ADAPTAR CONFIG.YAML-------------

#Para no estar cambiando la version cada vez cuando se trabaja entre más persona
config['version'] = epipe.read_env_variable('.env','version',config['version'])

#Hacer interpolacion de {version} por el valor de version
config = epipe.replace_placeholder_in_config(config, '{version}', config['version'])


#---------PARAMETROS ADICIONALES  ------------

fechas = pd.date_range(start=config['periodo_inicio'],
                       end=config['periodo_final'],
                       freq='MS').strftime('%Y-%m-01').tolist()

#--------- REGLA DE TEST  ------------

rule test:
    shell: "echo hello " + config['version']


rule etl_cities_info:
    input:
        script = 'etl/cities_info/w00_etl_cities_info.py',
        i_cities_info_raw = config['io_raw']['cities_info_raw'],
        i_merged_cities_raw = config['io_raw']['merged_cities_raw']
    output:
        o_cities_info = config['io_primary']['cities_info']
    run:  epipe.run_cmd(f"venv/bin/python {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule etl_forest:
    input:
        script = 'etl/forest/w00_etl_forest_fires.py',
        i_forest_fire_raw = config['io_raw']['forest_fire_raw'],
        i_brazil_states_raw = config['io_raw']['brazil_states_raw']
    output:
        o_forest_fire = config['io_primary']['forest_fire']
    run:  epipe.run_cmd(f"venv/bin/python {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule sql_magic_data_python:
    input:
        script = 'preprocessing/w01_get_datalake_with_python.py',
    output:
        o_sql_magic_number = config['io_primary']['magic_number']
    run:  epipe.run_cmd(f"venv/bin/python {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule sql_magic_data_r:
    input:
        script = 'preprocessing/w01_get_datalake_with_R.R',
    output:
        o_magic_number_r = config['io_primary']['magic_number_r']
    run:  epipe.run_cmd(f"Rscript {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule sql_info_cliente_mes:
    params:
        periodo = "{fecha}"
    input:
        script = 'preprocessing/w01_prep_client_info.R',
        i_merged_cities_raw = config['io_raw']['merged_cities_raw']
    output:
        o_cliente_info = directory(config['io_primary']['cliente_info']  +"/periodo={fecha}")
    run:  epipe.run_cmd(f"Rscript {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule all_sql_info_cliente_mes:
    input:
        directory(expand(rules.sql_info_cliente_mes.output.o_cliente_info, fecha=fechas))


rule sql_fenomeno_cliente_mes:
    params:
        periodo = "{fecha}"
    input:
        script = 'preprocessing/w01_prep_fenomeno_cliente.R'
    output:
        o_fenomeno_cliente = directory(config['io_primary']['fenomeno_cliente']  +"/periodo={fecha}")
    run:  epipe.run_cmd(f"Rscript {input.script} {epipe.prepare_cmd_args(params=params,output=output,input=input)}")

rule all_sql_fenomeno_cliente_mes:
    input:
        directory(expand(rules.sql_fenomeno_cliente_mes.output.o_fenomeno_cliente, fecha=fechas))


rule pre_tablon_atributo_mes:
    params:
        periodo = "{fecha}"
    input:
        script = 'preprocessing/w02_create_tablon_atributo.R',
        i_cliente_info = rules.sql_info_cliente_mes.output.o_cliente_info,
        i_cities_info = rules.etl_cities_info.output.o_cities_info,
        i_magic_number = rules.sql_magic_data_python.output.o_sql_magic_number,
        i_forest_fire = rules.etl_forest.output.o_forest_fire,
        i_magic_number_r = rules.sql_magic_data_r.output.o_magic_number_r
    output:
        o_tablon_atributos = directory(config['io_master']['tablon_atributos']  +"/periodo={fecha}")
    run:  epipe.run_cmd(f"Rscript {input.script} {epipe.prepare_cmd_args(params=params,output=output)}")

rule all_pre_tablon_atributo_mes:
    input:
        directory(expand(rules.pre_tablon_atributo_mes.output.o_tablon_atributos, fecha=fechas))

rule prep_tablon_maestro:
    params:
        fecha_inicio = fechas[0],
        fecha_final = fechas[-1]
    input:
        script = 'preprocessing/w03_crear_tablon_maestro.py',
        i_atributos = directory(expand(rules.pre_tablon_atributo_mes.output.o_tablon_atributos, fecha=fechas)),
        i_fenomeno = directory(expand(rules.sql_fenomeno_cliente_mes.output.o_fenomeno_cliente, fecha=fechas))
    output:
        o_tablon_master = config['io_master']['tablon_master']
    run:  epipe.run_cmd(f"venv/bin/python {input.script} {epipe.prepare_cmd_args(params=params,output=output)}")

