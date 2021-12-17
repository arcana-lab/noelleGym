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
      benchmarkName = str(lineAsList[0])
      speedup = 0.0
      if (len(lineAsList) >= 2):
        speedup = float(lineAsList[1])

      if (benchmarkName.endswith(".txt")):
        benchmarkName = benchmarkName[:-4]

      if (benchmarkName in benchmarkNames):
        print('Benchmark ' + benchmarkName + ' is already in data. Cleanup duplicates first, I don\'t know which value to use. Abort.')
        sys.exit(1)

      benchmarkNames.append(benchmarkName)
      data.append((benchmarkName, speedup))

  return sorted(data), sorted(benchmarkNames)

def process(pathToFiles):
  data = {}
  compilers = []
  bsuites = []
  benchmarks = []
  benchmarksPerBsuite = {}
  for pathToFile in pathToFiles:
    compiler = pathToFile.split("/")[-1].strip(".txt")
    if (compiler not in compilers):
      compilers.append(compiler)

    bsuite = pathToFile.split("/")[-2]
    if (bsuite not in bsuites):
      bsuites.append(bsuite)

    if (bsuite not in data):
      data[bsuite] = {}

    if (compiler not in data[bsuite]):
      data[bsuite][compiler] = []

    data[bsuite][compiler], benchmarkNames = readData(pathToFile)

    if (bsuite not in benchmarksPerBsuite):
      benchmarksPerBsuite[bsuite] = []

    for benchmarkName in benchmarkNames:
      if (benchmarkName not in benchmarks):
        benchmarks.append(benchmarkName)
      if (benchmarkName not in benchmarksPerBsuite[bsuite]):
        benchmarksPerBsuite[bsuite].append(benchmarkName)

  return data, compilers, bsuites, benchmarks, benchmarksPerBsuite

def getDataWithGeoMean(data, compilers, bsuites):
  bars = {}
  for compiler in compilers:
    geomeans = []
    if (compiler not in bars):
      bars[compiler] = []
    dataAllCompiler = []
    for bsuite in bsuites:
      dataAllCompilerForBsuite = []
      for elem in data[bsuite][compiler]:
        speedup = elem[1]
        if speedup != 0.0:
          dataAllCompiler.append(speedup)
          dataAllCompilerForBsuite.append(speedup)
        bars[compiler].append(speedup)
      geoMeanAllCompilerForBsuite = scistats.mstats.gmean(dataAllCompilerForBsuite)
      geomeans.append(geoMeanAllCompilerForBsuite)
    geoMeanAllCompiler = scistats.mstats.gmean(dataAllCompiler)
    geomeans.append(geoMeanAllCompiler)

    for geomean in geomeans:
      bars[compiler].append(geomean)
    
  return bars

def plot(bars, compilers, bsuites, benchmarks, benchmarksPerBsuite):
  colors = ["red", "black", "orange", "blue", "lightblue", "green", "lightgreen"]

  for bsuite in bsuites:
    benchmarks.append(bsuite)
  benchmarks.append("Overall")

  fontSize = 6

  fig = plt.figure()
  ax = fig.add_subplot(111)

  matplotlib.rcParams.update({'font.size': fontSize})
  ax.set_ylabel('Program speedup', fontsize = fontSize)

  gap = 0.01
  numBars = float(len(compilers))
  barWidth = 0.5/(numBars + numBars*gap)
  barIncrement = barWidth + gap
  xTicks = range(len(benchmarks))
  xTicksShifted = [elem - barWidth/2 - gap/2 for elem in xTicks]
  xTicksAcc = []
  xTicksAcc.append(xTicksShifted)
  rects = []
  i = 0
  for compiler in compilers:
    rects.append(ax.bar(xTicks, bars[compiler], barWidth, color = colors[i], label = compiler))
    xTicks = [elem + barIncrement for elem in xTicks]
    xTicksShifted = [elem - barWidth/2 - gap/2 for elem in xTicks]
    xTicksAcc.append(xTicksShifted)
    i += 1

  x = []
  for i in range(len(benchmarks)):
    x.append(np.median([elem[i] for elem in xTicksAcc]))

  ymin = 0
  ymax = 14
  ystep = 2

  plt.xticks(x, benchmarks, fontsize = fontSize, rotation = 45, ha = 'right')
  plt.yticks(range(ymin, ymax + 1, ystep), fontsize = fontSize)

  mul = 50
  xmin = xTicksAcc[0][0] - gap*mul
  xmax = xTicksAcc[-1][-1] + gap*mul

  ax.set_xlim(xmin = xmin, xmax = xmax)
  ax.set_ylim(ymin = ymin, ymax = ymax + 1)

  # Lines
  ax.plot([xmin, xmax], [1, 1], '-', color = 'red', linewidth = 1.0, zorder = 0)
  ax.plot([xmin, xmax], [ymax, ymax], '-', color = 'red', linewidth = 1.0, zorder = 1)
  numOfBenchmarks = 0
  for bsuite in benchmarksPerBsuite:
    numOfBenchmarks += len(benchmarksPerBsuite[bsuite])
    xLine0 = x[numOfBenchmarks - 1]
    xLine1 = x[numOfBenchmarks]
    xLine = xLine0 + (xLine1 - xLine0)/2.0
    ax.plot([xLine, xLine], [ymin, ymax + 1], '--', color = 'gray', linewidth = 1.0, zorder = 0)

  # Annotations and arrows
  ax.annotate('Number of cores', fontsize=fontSize, xy=(x[0], ymax - 1), color = 'black', bbox = dict(ec='none', fc = 'none', alpha = 1))
  ax.annotate('clang -O3 -march=native', fontsize=fontSize, xy=(x[1], ymin + 6.3), color = 'black', bbox = dict(ec='none', fc = 'none', alpha = 1))
  ax.annotate('', xy=(x[1] + (x[2] - x[1])/2, ymin + 6.3), xytext=(x[1] + (x[2] - x[1])/2, ymin + 1), arrowprops = dict(arrowstyle='<-', lw = 1.0))
  ax.annotate('Performance\nobtained by\nthe parallelization\ndone by\na NOELLE custom tool', fontsize=fontSize, xy=(x[5], ymin + 8.3), color = 'black', bbox = dict(ec='none', fc = 'none', alpha = 1))
  ax.annotate('', xy=(x[10] + (x[11] - x[10])/2, ymax), xytext=(x[10] + (x[11] - x[10])/2, ymin + 1), arrowprops = dict(arrowstyle='<->', lw = 1.0))
  ax.annotate('icc did not extract parallelism', fontsize=fontSize, xy=(x[14], ymin + 6.3), color = 'black', bbox = dict(ec='none', fc = 'none', alpha = 1))
  ax.annotate('', xy=(x[19] + 3*barWidth, ymin + 6.3), xytext=(x[19] + 3*barWidth, ymin + 1), arrowprops = dict(arrowstyle='<-', lw = 1.0))
  ax.annotate('gcc did not extract parallelism', fontsize=fontSize, xy=(x[19], ymin + 8.3), color = 'black', bbox = dict(ec='none', fc = 'none', alpha = 1))
  ax.annotate('', xy=(x[24] + barWidth/2, ymin + 8.3), xytext=(x[24] + barWidth/2, ymin + 3.2), arrowprops = dict(arrowstyle='<-', lw = 1.0))

  ax.yaxis.grid(True, color = 'gray', ls = '--')
  ax.set_axisbelow(True)

  ax.tick_params(axis = 'x', direction = 'out', top = False)

  ax.legend(fontsize = fontSize, fancybox = False, framealpha = 1, ncol = int(math.ceil(len(compilers)/3)), loc = 'upper right')

  matplotlib.rcParams['pdf.fonttype'] = 42
  matplotlib.rcParams['ps.fonttype'] = 42

  ax.set_aspect(0.5)

  plt.tight_layout()
  plt.savefig('./barplotSpeedup.pdf', format = 'pdf')

  return


args = getArgs()
data, compilers, bsuites, benchmarks, benchmarksPerBsuite = process(args['pathToFiles'])
bars = getDataWithGeoMean(data, compilers, bsuites)
plot(bars, compilers, bsuites, benchmarks, benchmarksPerBsuite)

