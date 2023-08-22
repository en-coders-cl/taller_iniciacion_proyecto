import pandas as pd
import awswrangler as wr
from epipe import epipe
import pyarrow.feather as feather
import pickle
import argparse

#----- PARAMETROS -------------------------

config = epipe.read_config("config.yaml")

parser = argparse.ArgumentParser(description="Autocoders")
parser.add_argument(
    "--o_sql_magic_number",
    type=str,
    default=config["io_primary"]["magic_number"],
    help="raw cities_info",
)

args, _ = parser.parse_known_args()


#----- CONSULTA -------------------------

QUERY = (
    f"select semana_anio,  count(semana_anio) as count from {config['tabla_de_test']} group by semana_anio limit 10"
)

wr.s3.delete_objects(f"{config['s3_staging_dir'] + config['s3_output_directory']}")  # dropfiles from folder

df = wr.athena.read_sql_query(
    sql=QUERY,
    database=config['schema_name'],
    s3_output=config['s3_staging_dir'] + config['s3_output_directory'],
    ctas_approach=False,
    unload_approach=True
)


#----- TRANSFORMACION -------------------------

magic_number = df['count'].sum()

#converto a dataframe
magic_number = pd.DataFrame([[magic_number]], columns=['magic_number'])


#----- WRITE -------------------------

feather.write_feather(magic_number, args.o_sql_magic_number)





