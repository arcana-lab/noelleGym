import matplotlib.pyplot as plt
import argparse
import pathlib
import pandas
import numpy
import sys

# Dolan E.D., Moŕe J.J.
# 2002
# Benchmarking Optimization Software with Performance Profiles.
# Mathematical Programming 91(2):201–213
# https://link.springer.com/article/10.1007/s101070100263

# ===== COMMAND LINE ARGUMENTS ==========================================================

parser = argparse.ArgumentParser(description=
    "Cumulative Distribution Function plotter. Useful to compare performance on "
    "different methods of the same set of problems.")

parser.add_argument("-t", "--problem-type", type=str, choices=["min", "max"],
    help="Maximization or minimization problem. Default is 'min'", default="min")

parser.add_argument("filename", metavar="CSV_FILE", type=str,
    help="Input CSV file containing a column per method")

parser.add_argument("-x", "--xlimit", type=float, default=10,
    help="Right limit of x-axis. Default is 10")

parser.add_argument("-s", "--save", action="store_true",
    help="Dump plot to file")

parser.add_argument("-r", "--reverse", action="store_true",
    help="Reverse x-axis")

parser.add_argument("-m", "--marker", type=str, default=".",
    help="Set which marker to use. Try '$X$'. Default is '.'")

parser.add_argument("-z", "--marker-size", type=int, default=10,
    help="Set the size of the marker. Default is 10")

parser.add_argument("-o", "--output", type=str,
    help="Dump plot to a specified file")

args = parser.parse_args()

plt.style.use("dark_background")
#plt.style.use("bmh")
fig, axs = plt.subplots(1)

if args.problem_type == "min":
    get_best = pandas.DataFrame.min
else:
    get_best = pandas.DataFrame.max

data = pandas.read_csv(args.filename)
best = get_best(data, axis=1)

N = len(data)
y = numpy.linspace(0.0, 1.0, N+1)[1:]

for method in data.columns:
    vals = data[method]
    x = (vals / best).sort_values()
    x = 1 / x if args.reverse else x
    plt.step(x, y, where="post", label=method,
             marker=args.marker, markersize=args.marker_size)

fig.suptitle("Performance Profile")
plt.xlabel("Ratio to best")
plt.ylabel("How many")
ticks = numpy.linspace(0, 1, 11)
tick_names = [f"{t*100:.0f}%" for t in ticks]

plt.yticks(ticks, tick_names)
if not args.reverse:
    plt.xlim(left=1, right=args.xlimit)
plt.grid(True, linewidth=0.1)

if args.problem_type == "min":
    if args.reverse:
        plt.legend(loc="lower left")
    else:
        plt.legend(loc="lower right")
else:
    if args.reverse:
        plt.legend(loc="upper right")
    else:
        plt.legend(loc="upper left")

if args.output is not None:
    plt.savefig(args.output)
elif args.save:
    plt.savefig(pathlib.Path(args.filename).stem + ".pdf")
else:
    plt.show()
