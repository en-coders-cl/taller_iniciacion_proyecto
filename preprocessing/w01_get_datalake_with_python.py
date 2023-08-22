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




#----- TRANSFORMACION -------------------------

magic_number = 10

#converto a dataframe
magic_number = pd.DataFrame([[magic_number]], columns=['magic_number'])


#----- WRITE -------------------------

feather.write_feather(magic_number, args.o_sql_magic_number)





