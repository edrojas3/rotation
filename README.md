# Rotation
MATLAB code to analyze spike activity of the rotation task.

We trained monkeys to feel the rotation of an object and to communicate their decision. We recorded neurons while they performed this task from the anterior parietal sulcus, area 5, area 7, and S2. The code in this repository is for analyzing behavioral and neuronal data. 

## From BlackRock files to matlab structure

All the data was recorded with BlackRock Microsystems software. From each session we obtained three file types:
1. nev: action potentials and event time stamps.
2. ns1: continuous signal of the rotation of the stimulus (sampling frequency = 500 Hz).
3. ns2: local field potential (lfp; sampling frequency = 1000 Hz).

Example data can be found in this repository. The name of the files is coded by the initial of the monkey's name and the date of the session.

MATLAB can read these files but first you need to download the NPMK toolbox from BlackRock's github page or mine. Add the directory to your MATLAB's search path and run installNPMK.m. Once you did this you can access the raw data of the recording session with the 'openNEV' or 'openNSx' functions.

To obtain a structure with all the information separated by trials type:

```
e = getSessionStruct(id)
```

Where 'e' is a structure with all the information and 'id' is the identifier (file name without the extension).
Within 'e' the important fields are:
* trial: event timestamps, LFP, and stimulus signal for each trial
* spikes: timestamps of the action potentials separated by trial. The name of each subfield is a code for the channel we used and the recorded unit (ex. spike13 means channel 1 unit 3).
