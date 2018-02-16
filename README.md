# Rotation
MATLAB code to analyze spike activity of the rotation task.

We trained monkeys to feel the rotation of an object and to communicate their decision. We recorded neurons while they performed this task from the anterior parietal sulcus, area 5, area 7, and S2. The code in this repository is for analyzing behavioral and neuronal data. 

## Data from recording sessions
Example data can be found in this repository in the datafiles/mat directory. Just load them in your MATLAB workspace. You will get a structure array called 'e'. The most important fields are:
* trial: event timestamps, LFP, and stimulus signal for each trial
* spikes: cell arrays with the timestamps of the action potentials separated by trial. The name of each subfield is a code for the channel we used and the recorded unit (ex. _spike13_ means channel 1 unit 3).

### Raw data directly from BlackRock
All the data was recorded with BlackRock Microsystems software. From each session we obtained three file types:
1. nev: action potentials and event time stamps.
2. ns1: continuous signal of the rotation of the stimulus (sampling frequency = 500 Hz).
3. ns2: local field potential (lfp; sampling frequency = 1000 Hz).

_There are example files in the datafiles/nev (ns1, or ns2) directories._

MATLAB can read these files but first **you need to download the NPMK toolbox** from BlackRock's github page or mine. Add the directory to your MATLAB's search path and run: 

```
installNPMK.m
```

Once you did this you can access the raw data of the recording session with the _openNEV_ or _openNSx_ functions. If you want to know more about the NPMK toolbox check out the NPMK user's guide.

To get a structure array similar to the ones in _datafiles/mat_ run:

```
e = getSessionStruct(id)
```

Where 'e' is a structure with all the information and 'id' is the file identifier with the full path (ex. C:\Data\d1608091032). Notice that there is no file extension.

## Pyschophysics
In each trial, the stimulus rotation was randomly selected from a set of 12 possible magnitudes: -3.2,-1.6,-0.8,-0.4,-0.2-0.1,0.1,0.2,0.4,0.8,1.6,3.2 (degrees of rotation, positive numbers represent left rotations). The way we evaluated behavioral data is by plotting how many 'left' choices the monkeys emitted as a function of stimulus magnitude. 

For a single session run the following line:

```
psicofis(e,'anguloRotacion')
```
To pool the data run:

```
psicofisica(dir)
```
This will plot a psychophysics curve pooling the information of all the .mat files inside _dir_. The mat files must contain _e_ structures.

**The log axis is still missing**

## Raster Plots and Firing Rates
To visualize a neuron's activity we found convenient to plot its raster and firing rate in one figure. To do this you can use:

```
rasterAndFiringRates(e,unit)
```

Where _e_ is the structure with the session info, and unit is the string of the neuron's code name as described before (ex. spike13).

Once you run the function from above, you will get a figure divided in two. The upper part is the raster plot of the neuron aligned to three events of the task:
	1. Wait
	2. Touch object
	3. Stimulus onset
In the raster plot time is in the _x_ axis and in the _y_ axis are the trials ordered by stimulus magnitude. The trials where the stimulus rotated to the right are in the bottom half of the raster plot. The black marks are the times where an action potential occurred time locked to the 3 aligning events (green straight lines). The other colored markers are the events that happend near the aligning events.

The firing rate is plotted at the bottom of the figure separated by left (blue traces) and right (red traces) rotations. To obtained the firing rate we used an exponential window with a decay constant (tau) of 0.05 ms and step movements 0f 0.1 ms.

Only correct trials were used for both plots.

## Normalization of firing rate
For normalizing (z-score) the firing rates run:

```
[frnorm, timesec] = fratenorm(e,spk);
```
