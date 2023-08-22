import pandas as pd
import pyarrow.feather as feather
import argparse
from epipe import epipe

# ------------- Arguments---------------------------------
config = epipe.read_config("config.yaml")

parser = argparse.ArgumentParser(description="Autocoders")
parser.add_argument(
    "--i_cities_info_raw",
    type=str,
    default=config["io_raw"]["cities_info_raw"],
    help="raw cities_info",
)
parser.add_argument(
    "--i_merged_cities_raw",
    type=str,
    default=config["io_raw"]["merged_cities_raw"],
    help="raw cities_info",
)
parser.add_argument(
    "--o_cities_info",
    type=str,
    default=config["io_primary"]["cities_info"],
    help="primary cities_info",
)

#parse known arguments

args, _ = parser.parse_known_args()

# ------------- READ DATA ---------------------------------

# Load the data
data = pd.read_csv(args.i_cities_info_raw, sep=",")

df_merged = pd.read_csv(args.i_merged_cities_raw, sep=",")
df_merged = df_merged[['standardized_city_name', 'city_name_cities']]
df_merged = df_merged.drop_duplicates()


#---------- TRANSFORM DATA ---------------------------------

# Select the relevant columns
numeric_data = ['GDP_CAPITA', 'COMP_TOT', 'GVA_AGROPEC', 'GVA_INDUSTRY', 'GVA_SERVICES', 'GVA_PUBLIC', 'TAXES', 'ESTIMATED_POP', 'Pr_Agencies', 'Pu_Agencies', 'Pr_Assets', 'Pu_Assets', 'Cars', 'Motorcycles']
categotical = ['CITY','STATE','CAPITAL']

#bind to a list
selected_columns = categotical + numeric_data

# Select the relevant columns
selected_data = data[selected_columns]

# Convert each column to the corresponding type
for column in categotical:
    selected_data.loc[:, column] = selected_data[column].astype('category')

# The rest of the columns are float
for column in numeric_data:
    selected_data.loc[:, column] = selected_data[column].astype('float')

#reset the index
selected_data = selected_data.reset_index(drop=True)

#------- MERGE DATA ---------------------------------

# Merge the data
selected_data = pd.merge(selected_data, df_merged, how='left', left_on='CITY', right_on='city_name_cities')

#------------- WRITE DATA ---------------------------------

# Save the DataFrame as a feather file
feather.write_feather(selected_data, args.o_cities_info)
