# ParseTune.rb
# 22 Dec 2018
# note on windows explorer
# highlight the file
# press shift and right click
# select copy as path
# paste the results here
# change the '\' characters to '/'
Path="C:/Users/jj/Documents/MuseScore2/Plugins/testtune3.txt"

tuneTxt = File.open(Path, "r") {|io| io.read}
#tuneTxt="3,8,60;1,4,-1;1,4,64;1,4,67;1,4,60,64,67;1,4,60;1,8,61;1,16,64;1,32,67;1,4,60,64,67
#"
# tuneTxt protocol
# numerator,denominator,-1 for rest or positive midi pitch, more comma separated
# midi pitches... and end the entry with a ';'
# numerator =1, denominator=4 gives a 1/4 note
# The pattern repeats for more notes, chords or rests

puts tuneTxt
tune=tuneTxt.split(";")
puts tune[tune.length-1]
i=0
use_synth :piano
while i<tune.length-1
  nt=[]
  ichord=[]
  puts tune[i]
  x=tune[i].split(",")
  nt.push(x[0].to_f)
  nt.push(x[1].to_f)
  j=2
  while j<x.length
    ichord.push(x[j].to_i)
    j+=1
  end
  if ichord[0]>-1
    
    play ichord
  end
  sleep nt[0]/nt[1]
  i+=1
end

