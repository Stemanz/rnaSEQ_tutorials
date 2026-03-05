import pandas as pd
from glob import glob

files = sorted(glob("*.txt"))

building = []
for f in files:
    df = pd.read_csv(f, sep="\t", skiprows=1)

    first_col_name = df.columns[0]
    last_col_name = df.columns[-1]
    df = df[[first_col_name, last_col_name]].set_index(first_col_name)
    df = df.rename(columns={last_col_name: f})
    print(f"Done: {f}")

    building.append(df)

final = pd.concat(building, axis=1)
final.to_csv("countData.csv", sep=",")

