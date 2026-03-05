import pandas as pd
filename = "countData.csv"

def fixgeneid(stringlike):
    if not "." in stringlike:
        return stringlike

    pos = stringlike.find(".")
    return stringlike[:pos]
        

df = pd.read_csv(filename, index_col=0)
newindex = df.index.map(fixgeneid)

df.index = newindex
df.to_csv(filename, sep=",")

