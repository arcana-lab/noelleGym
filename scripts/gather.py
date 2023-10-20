import pandas
import numpy
import os
import sys
import pathlib

def get(what, path):
    found = os.listdir(path)
    found = map(lambda x: f"{path}/{x}", found)
    found = filter(what, found)
    return found

if len(sys.argv) < 2:
    print(f"Usage: python {sys.argv[0]} PATH")
    exit(1)

base = sys.argv[1]

items = []
for suite in get(os.path.isdir, f"{base}/time"):
    for method in get(os.path.isdir, suite):
        for file in get(os.path.isfile, method):
            median = numpy.median(numpy.loadtxt(file))
            benchmark = pathlib.Path(file).stem
            method    = pathlib.Path(method).stem
            suite     = pathlib.Path(suite).stem
            benchmark = pathlib.Path(benchmark).stem
            items.append(iter((method, suite, benchmark, median)))

df = pandas.DataFrame(items, columns=["Method", "Suite", "Benchmark", "Time"])

def pivot(df):
    return df.pivot(index=["Suite", "Benchmark"],
                    columns="Method",
                    values="Time")

dfp = pivot(df)

# zeros are a red flag
zeros = (dfp==0.0).any(axis=1)
if zeros.any():
    print("WARNING: There are zeros!")
    print()
    print(dfp[zeros])

# NaNs are a red flag
nans = (dfp.isna()).any(axis=1)
if nans.any():
    print("WARNING: There are NaNs!")
    print()
    print(dfp[nans])
    print()
    print("WARNING: These rows will be discarded")

# exporing all suites in one file
dfp \
  .fillna(1000000) \
  .to_csv(os.path.dirname(base) + f".csv", index=False)

# exporting one file per suite
for suite in df["Suite"].unique():
    pivot(df[df["Suite"] == suite]) \
      .dropna() \
      .to_csv(os.path.dirname(base) + f".{suite}.csv", index=False)
