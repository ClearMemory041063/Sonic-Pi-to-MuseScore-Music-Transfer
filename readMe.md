### Sonic Pi to MuseScore Music Transfer

#### A simple text file protocol

Noteitems are inserted into a text file.
A noteitem has the following format:
A series of comma separated integer numbers
and ending with a semicolon.
Note timing is commonly expressed as a fraction
such as 1/4, 1/2 etc.
The sequence of numbers in the noteitem follow this convention:
1. the timing numerator ( the 1 in 1/4 for a quater note)
2. the timing denominator ( the 4 in 1/4 for a quarter note)
3. a positive midi pitch number or a -1 for a Rest note
4. additional midi pitch numbers to form chords
5. a semicolon ends the noteitem.
 
For example:

` 1,4,60;1,4,62;1,4,64;1,4,67;1,1,60,64,67
`
##### The Sonic Pi program Chopsticks1.rb was used to create the text file qchop2.txt

##### The Sonic Pi program ParseTune.rb will read the text file and play the tune

##### The MuseScore plug-in readtune.qml was used to import the qchop2.txt file into a score.

##### Excess measures were removed from the score and some other editing was performed.

##### The score was saved and exported as seen in the remaining qchop2 files.
