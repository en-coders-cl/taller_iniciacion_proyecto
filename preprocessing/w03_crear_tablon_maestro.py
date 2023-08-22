import pandas as pd
import pyarrow.feather as feather
import pyarrow.dataset as ds
from epipe import epipe
import argparse
import pyarrow.parquet as pq

#----- PARAMETROS -------------------------

config = epipe.read_config("config.yaml")

parser = argparse.ArgumentParser(description="Autocoders")
parser.add_argument(
    "--fecha_inicio",
    type=str,
    default=config["periodo_inicio"],
    help="raw cities_info",
)
parser.add_argument(
    "--fecha_final",
    type=str,
    default=config["periodo_final"],
    help="raw cities_info",
)
parser.add_argument(
    "--i_atributos",
    type=str,
    default=config["io_master"]["tablon_atributos"],
    help="raw cities_info",
)
parser.add_argument(
    "--i_fenomeno",
    type=str,
    default=config["io_primary"]["fenomeno_cliente"],
    help="raw cities_info",
)
parser.add_argument(
    "--o_tablon_master",
    type=str,
    default=config["io_master"]["tablon_master"],
    help="raw cities_info",
)

args, _ = parser.parse_known_args()

#----- READ -------------------------


df_atributos = pq.read_table(args.i_atributos, filters=[
    ('periodo', '>=', args.fecha_inicio),
    ('periodo', '<=', args.fecha_final)
]).to_pandas()


df_fenomeno = pq.read_table(args.i_fenomeno, filters=[
    ('periodo', '>=', args.fecha_inicio),
    ('periodo', '<=', args.fecha_final)
]).to_pandas()


#--- JOIN ----------------------------

df_tablon_master = pd.merge(df_fenomeno, df_atributos, on=['periodo', 'id_client'], how='left')


#----- WRITE -------------------------

feather.write_feather(df_tablon_master, args.o_tablon_master)

