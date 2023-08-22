
import pandas as pd
import pyarrow.feather as feather
import argparse
from epipe import epipe

# ------------- Arguments---------------------------------
config = epipe.read_config("config.yaml")

parser = argparse.ArgumentParser(description="etl_forest_fires")
parser.add_argument(
    "--i_forest_fire_raw",
    type=str,
    default=config["io_raw"]["forest_fire_raw"],
    help="raw cities_info",
)
parser.add_argument(
    "--i_brazil_states_raw",
    type=str,
    default=config["io_raw"]["brazil_states_raw"],
    help="raw cities_info",
)
parser.add_argument(
    "--o_forest_fire",
    type=str,
    default=config["io_primary"]["forest_fire"],
    help="primary cities_info",
)

args, _ = parser.parse_known_args()

# ------------- READ DATA ---------------------------------

# Load the dataset
df = pd.read_csv(args.i_forest_fire_raw, encoding='latin1')
df_state = pd.read_csv(args.i_brazil_states_raw, sep=",")

#------------- TRANSFORM DATA ---------------------------------

# Convert 'date' column to datetime
df['date'] = pd.to_datetime(df['date'])

# Convert 'state' and 'month' to categorical
df['state'] = df['state'].astype('category')
df['month'] = df['month'].astype('category')

# Filter the data for the last 10 years
df_last_10_years = df[df['year'] > df['year'].max() - 10]

# Calculate the annual mean of forest fires by state
summary = df_last_10_years.groupby('state')['number'].mean().reset_index()

# Rename the columns
summary.columns = ['state', 'mean_forest_fire']

#Reset the index
summary = summary.reset_index(drop=True)

#------------- ADD Abbrebiation ---------------------------------

# Merge the dataframes
summary_with_code = pd.merge(summary, df_state, how='left', left_on='state', right_on='name_as_shown')

#Drop name_as_shown column and name_corrected

summary_with_code = summary_with_code.drop(['name_as_shown', 'name_corrected'], axis=1)

#------------- WRITE DATA ---------------------------------

# Save the DataFrame as a feather file
feather.write_feather(summary_with_code, args.o_forest_fire)




