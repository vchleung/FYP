PEASS Listening Test GUI
Version 1.0, May 12th, 2010.
By Valentin Emiya, INRIA, France.
This is a joint work by Valentin Emiya (INRIA, France), Emmanuel Vincent (INRIA, France), Niklas Harlander (University of Oldenburg, Germany), Volker Hohmann (University of Oldenburg, Germany).

*********
What for?
*********
This Matlab GUI is designed to perform MUSHRA tests in the case of the subjetive evaluation of audio source separation, according to the test protocol proposed by the authors. The guidelines are available in the file guidelines.pdf.

***********************
Installing the software
***********************
Just unzip the file in a new directory.

************************
How to use this software
************************
- configure your listening test by filling the 'mushram_config.txt' file with one audio filename per line; all the files for each experiment (or trial) must be grouped in consecutive lines; leave an empty line between the groups related to different experiments; in each group, the target source must be the first file and the interference anchor/mixture must be the third one (we used the interference anchor as the mixture presented to the subjects). All experiments must have the same number of files.
- run the test by calling the function 'runListeningTest'. Before the first grading phase, the subject is asked to give a filename to store his/her results.
- to collect the results for a given subject as a matrix, use the function 'mushram_results'.

******************
Running an example
******************
Run runListeningTest.m (the configuration file 'mushram_config.txt' is already set to some default settings).

*********
Platforms
*********
This software has been tested under Windows and Linux platforms, with the 2008 and 2009 releases of Matlab.

**************************
How to cite this software?
**************************
When using this software, the following paper must be referred to:

Valentin Emiya, Emmanuel Vincent, Niklas Harlander and Volker Hohmann, Subjective and objective quality assessment of audio source separation, IEEE Transactions on Audio, Speech and Language Processing, submitted.

*************
Miscellaneous
*************
One can start playing a sound by pushing a button at any time, including if another sound is still being played.


*********
Copyright
*********
The files in root directory are under:
Copyright 2010 Valentin Emiya (INRIA).

The code in the current directory is distributed under the terms of the GNU GENERAL PUBLIC LICENSE, Version 2, June 1991. This is a modified version of the original code by Emmanuel Vincent called 'mushram', available at http://www.elec.qmul.ac.uk/digitalmusic/downloads/index.html#mushram.

