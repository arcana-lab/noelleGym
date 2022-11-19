import sys
import os
import numpy as np
import math
import matplotlib
import matplotlib.pyplot as plt

def getArgs():
  argLength = len(sys.argv)
  if (argLength <= 2):
    print('USAGE: $ python3 ' + sys.argv[0] + ' path/to/time/directory path/to/plots/directory techniques(i.e, "DOALL DSWP HELIX")')
    sys.exit(1)
  elif (argLength == 3):
    return sys.argv[1], sys.argv[2], ['all']
  else:
    return sys.argv[1], sys.argv[2], sys.argv[3:]

def collectBenchmarkSuites(pathToTimeDir):
  benchSuites = []
  for benchSuite in os.listdir(pathToTimeDir):
    benchSuites.append(benchSuite)

  return benchSuites

def collectTechniques(pathToTimeDir, benchSuite):
  techniques = []
  for file in os.listdir(pathToTimeDir + '/' + benchSuite):
    if file.endswith('.txt'):
      techniques.append(file[:-4])
  
  return techniques

def collectBenchmarks(pathToTimeDir, benchSuite, referenceFile):
  benchmarks = []
  with open(pathToTimeDir + '/' + benchSuite + '/' + referenceFile, 'r') as file:
    lines = file.readlines()
    for line in lines:
      benchmarks.append(line.split(' ')[0].strip('.txt'))

  return benchmarks

def collectResults(pathToTimeDir, benchSuite, techniques, benchmarks):
  results = {}
  for technique in techniques:
    resultsFile = pathToTimeDir + '/' + benchSuite + '/' + technique + '.txt'
    results[technique] = []

    # set the default value
    for benchmark in benchmarks:
      results[technique].append(0.0)

    if os.path.isfile(resultsFile):
      with open(resultsFile, 'r') as file:
        lines = file.readlines()
        for line in lines:
          benchmarkAndSpeedUp = line.split(' ')
          if benchmarkAndSpeedUp[1].strip('\n') != '' and benchmarkAndSpeedUp[1].strip('\n') != 'NONE': 
            results[technique][benchmarks.index(benchmarkAndSpeedUp[0].strip('.txt'))] = float(benchmarkAndSpeedUp[1].strip('\n'))

  # Sort the speedup result if only interested in NOELLE's result
  if len(techniques) == 1 and techniques[0] == 'NOELLE':
    results['NOELLE'], benchmarks = (list(bench) for bench in zip(*sorted(zip(results['NOELLE'], benchmarks), reverse=True)))

  return results, benchmarks

def plot(benchSuite, techniques, benchmarks, results, pathToPlotsDir):
  colors = {
    "NONE": "black",
    "DOALL": "green",
    "HELIX": "orange",
    "DSWP": "blue",
    "NOELLE": "red",
  }
  # Backup colors if not predefined
  # Available colors can be found: https://matplotlib.org/3.5.0/gallery/color/named_colors.html
  back_up_colors = ["lightgrey", "lightcoral", "lightseagreen", "lightblue", "lightpink"]

  lineWidth = 0.5
  fontSize = 6

  fig = plt.figure()
  ax = fig.add_subplot(111)

  matplotlib.rcParams.update({'font.size': fontSize})
  ax.set_ylabel('Program speedup', fontsize = fontSize)

  gap = 0.01
  numBars = float(len(techniques))
  barWidth = 0.5/(numBars + numBars*gap)
  barIncrement = barWidth + gap
  xTicks = range(len(benchmarks))
  xTicksShifted = [elem - barWidth/2 - gap/2 for elem in xTicks]
  xTicksAcc = []
  xTicksAcc.append(xTicksShifted)
  rects = []
  i = 0
  for technique in techniques:
    if technique in colors:
      color = colors[technique]
    else:
      color = back_up_colors[i]
      i += 1
    rects.append(ax.bar(xTicks, results[technique], barWidth, color = color, label = technique))
    xTicks = [elem + barIncrement for elem in xTicks]
    xTicksShifted = [elem - barWidth/2 - gap/2 for elem in xTicks]
    xTicksAcc.append(xTicksShifted)

  x = []
  for i in range(len(benchmarks)):
    x.append(np.median([elem[i] for elem in xTicksAcc]))

  ymin = 0
  ymax = 8
  ystep = 2

  plt.xticks(x, benchmarks, fontsize = 5, rotation = 45, ha = 'right')
  plt.yticks(range(ymin, ymax + 1, ystep), fontsize = fontSize)

  mul = 50
  xmin = xTicksAcc[0][0] - gap*mul
  xmax = xTicksAcc[-1][-1] + gap*mul

  ax.set_xlim(xmin = xmin, xmax = xmax)
  ax.set_ylim(ymin = ymin, ymax = ymax + 1)

  # Lines
  ax.plot([xmin, xmax], [1, 1], '-', color = 'red', linewidth = lineWidth + 0.1, zorder = 0)
  ax.plot([xmin, xmax], [ymax, ymax], '-', color = 'red', linewidth = lineWidth + 0.1, zorder = 1)

  ax.yaxis.grid(True, color = 'gray', ls = '--', lw = lineWidth)
  ax.set_axisbelow(True)

  ax.tick_params(axis = 'x', direction = 'out', top = False)

  ax.legend(fontsize = fontSize - 1.5, fancybox = False, framealpha = 1, ncol = int(math.ceil(len(techniques)/3)), loc = 'upper right', borderpad = 0.2)

  matplotlib.rcParams['pdf.fonttype'] = 42
  matplotlib.rcParams['ps.fonttype'] = 42

  ax.set_aspect(0.3)

  plt.tight_layout()
  if len(techniques) == 1 and techniques[0] == 'NOELLE':
    plt.savefig(pathToPlotsDir + '/' + benchSuite + '_' + techniques[0] + '.pdf', format = 'pdf')
  else:
    plt.savefig(pathToPlotsDir + '/' + benchSuite + '.pdf', format = 'pdf')

  return


# Step 1: determine time directory and techniques to plot
pathToTimeDir, pathToPlotsDir, techniques = getArgs()

# Step 2: collect all benchark suites
benchSuites = collectBenchmarkSuites(pathToTimeDir)

# Step 3: plot time result per benchmark suite
for benchSuite in benchSuites:
  # collect all available techniques
  if techniques[0] == 'all':
    techniques = collectTechniques(pathToTimeDir, benchSuite)

  # collect all benchmarks in the suite
  # assuming NONE.txt is available
  benchmarks = collectBenchmarks(pathToTimeDir, benchSuite, 'NONE.txt')

  # collect speedup results per benchmark per technique in the suite
  results, benchmarks = collectResults(pathToTimeDir, benchSuite, techniques, benchmarks)

  # plot and save the speedup results
  plot(benchSuite, techniques, benchmarks, results, pathToPlotsDir)
