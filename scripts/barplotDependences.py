import sys
import numpy as np
import math
import matplotlib
import matplotlib.pyplot as plt
from scipy import stats as scistats


def getArgs():
  args = {}
  numOfArgs = 1

  lenArgv = len(sys.argv)
  if (lenArgv <= numOfArgs):
    print('USAGE: $ python ' + sys.argv[0] + ' [path/to/file.txt]+')
    sys.exit(1)

  args['pathToFiles'] = sys.argv[1:]

  return args

def readData(pathToFile):
  data = []
  benchmarkNames = []
  with open(pathToFile, 'r') as f:
    for line in f:
      lineAsList = line.split()
      noelle = float(lineAsList[1])
      llvm = float(lineAsList[2])

      benchmarkName = str(lineAsList[0])
      if (benchmarkName.endswith(".txt")):
        benchmarkName = benchmarkName[:-4]

      if (benchmarkName in benchmarkNames):
        print('Benchmark ' + benchmarkName + ' is already in data. Cleanup duplicates first, I don\'t know which value to use. Abort.')
        sys.exit(1)

      benchmarkNames.append(benchmarkName)
      data.append((benchmarkName, llvm, noelle))

  return sorted(data), sorted(benchmarkNames)

def process(pathToFiles):
  data = {}
  compilers = []
  bsuites = []
  benchmarks = []
  benchmarksPerBsuite = {}
  for pathToFile in pathToFiles:
    bsuite = pathToFile.split("/")[-2]
    if (bsuite not in bsuites):
      bsuites.append(bsuite)

    if (bsuite not in data):
      data[bsuite] = []

    data[bsuite], benchmarkNames = readData(pathToFile)

    if (bsuite not in benchmarksPerBsuite):
      benchmarksPerBsuite[bsuite] = []

    for benchmarkName in benchmarkNames:
      if (benchmarkName not in benchmarks):
        benchmarks.append(benchmarkName)
      if (benchmarkName not in benchmarksPerBsuite[bsuite]):
        benchmarksPerBsuite[bsuite].append(benchmarkName)

  dataAll = {"LLVM" : [], "NOELLE" : []}
  for bsuite in bsuites:
    for elem in data[bsuite]:
      dataAll["LLVM"].append(elem[1] - elem[2]) # it's relative
      dataAll["NOELLE"].append(elem[2])

  return dataAll, bsuites, benchmarks, benchmarksPerBsuite

def plot(data, bsuites, benchmarks, benchmarksPerBsuite):
  compilers = ["NOELLE", "LLVM" ]
  colorsMap = {"LLVM" : "black", "NOELLE" : "red"}

  # Create plot
  fig = plt.figure()
  ax = fig.add_subplot(111)

  # Plot bars
  barWidth = 0.6
  xTicks = range(len(benchmarks))
  rects = []
  acc = [0]*len(benchmarks)
  for compiler in compilers:
    rects.append(ax.bar(xTicks, data[compiler], barWidth, color = colorsMap[compiler], label = compiler, bottom = acc))
    acc = np.add(acc, data[compiler]).tolist()

  # Create x ticks
  x = xTicks

  # Set font size for the whole plot
  fontSize = 8
  matplotlib.rcParams.update({'font.size': fontSize})

  # Set y label
  ax.set_ylabel('Dependences [%]', fontsize = fontSize)

  # Set y values
  ymin = 0
  ymax = 100
  ystep = 20
  ygap = 30

  # Set plot ticks
  plt.xticks(x, benchmarks, fontsize = fontSize, rotation = 45, ha = 'right')
  yticks = range(ymin, ymax + 1, ystep)
  yticksLabels = [str(elem) for elem in yticks]
  plt.yticks(yticks, yticksLabels, fontsize = fontSize)
  ax.tick_params(axis = 'x', direction = 'out', top = False)

  # Set plot limits
  xgap = barWidth
  mul = 1
  xmin = x[0] - xgap*mul
  xmax = x[-1] + xgap*mul
  ax.set_xlim(xmin = xmin, xmax = xmax)
  ax.set_ylim(ymin = ymin, ymax = ymax + ygap)

  # Lines
  numOfLines = 0
  numOfBenchmarks = 0
  for bsuite in benchmarksPerBsuite:
    if (numOfLines == (len(benchmarksPerBsuite) - 1)): # esclude last, there are not geo means here
      continue
    numOfLines += 1
    numOfBenchmarks += len(benchmarksPerBsuite[bsuite])
    xLine0 = x[numOfBenchmarks - 1]
    xLine1 = x[numOfBenchmarks]
    xLine = xLine0 + (xLine1 - xLine0)/2.0
    ax.plot([xLine, xLine], [ymin, ymax + ygap], '--', color = 'gray', linewidth = 1.0, zorder = 0)

  # Grid
  ax.yaxis.grid(True, color = 'gray', ls = '--', linewidth = 1.0)
  ax.set_axisbelow(True)

  # Legend
  ax.legend(fontsize = fontSize, fancybox = False, framealpha = 1, ncol = len(data), loc = 'upper right', borderpad = 0.3)

  # Change font type (useful for papers)
  matplotlib.rcParams['pdf.fonttype'] = 42
  matplotlib.rcParams['ps.fonttype'] = 42

  # Set aspect
  ax.set_aspect(0.04)
  plt.tight_layout()

  # Save figure
  plt.savefig('./barplotDependences.pdf', format = 'pdf')

  return


args = getArgs()
data, bsuites, benchmarks, benchmarksPerBsuite = process(args["pathToFiles"])
plot(data, bsuites, benchmarks, benchmarksPerBsuite)

