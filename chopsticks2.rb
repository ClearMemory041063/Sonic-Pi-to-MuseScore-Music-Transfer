# chopsticksa.rb
# 26 Sep 2017
### fix :r problem
# 25 sep 2017
# Bach's 2nd cousin plays chopsticks
## Helper functions
outText=""
rel=1.5
amplitude= 0.3
use_synth :fm
ichord=[]

define :playit do|a|
  ichord.push(a)
end #playit

define :sleepit do |b|
  denom=1/b
  numer=b*denom
  outText+=numer.to_s+","+denom.to_s
  play(ichord,release: b*rel)
  sleep b
  i=0
  if ichord[0]==nil then ichord[0]=-1 end
  while i<ichord.length
    outText+=","+ichord[i].to_s
    i+=1
  end #while i
  outText+=";"
  ichord=[]
end #sleepit


###############
## a function to copy a one dimensional array
def array_copy(x)
  y=[]
  i=0
  while i<x.length
    y.push(x[i])
    i+=1
  end
  return y
end
###############

def midi2note(n)
  nn=note(n)
  if nn==nil
    #    puts "nil seen",nn
    return nn
  else
    nn= note_info(nn)
    #    puts nn
    nnn=nn.to_s.split(":")
    #  puts nnn
    mmm= nnn[3].chop
    return mmm
  end
end # midi2note
#####
def listit(list)
  i=0
  while i<list.length
    puts i,list[i]
    i+=1
  end
end # listit
#####
def midi2noteList(list)
  rval=[]
  i=0
  while i<list.length
    rval.push [list[i], midi2note(list[i])]
    i+=1
  end
  return rval
end #midi2noteList
##### Starting function for shiftOnScale and invertNote
##### gets the index of a note in a scale
def getScaleIndex(tone,scal)
  #  puts tone,scal
  aoct=0
  octshift=0
  #  scal.pop #remove the last element of scale
  base=scal[0] # the MIDI number of the scale start
  a=note(tone) # is the MIDI number of the note to harmonize
  #  puts "note(tone)=",a
  if a==nil then return a end
  #  aa=note(tone)
  # puts "a aa=",a,aa
  #adjust the value to fall in the range of the scale
  while a<base # note is lower
    a+=12
    octshift-=12
  end
  while a>(base+12) # note is higher
    a-=12
    octshift+=12
  end
  b=a
  # puts "b=",b
  #see if the adjusted note is in the scale
  e=0
  if scal.include?(b)
    #    puts "b in scal"
    e=0
  else
    if scal.include?(b+1)
      e=1
    else
      if scal.include?(b-1)
        e=-1
      else
        return :C7 #signal an error
      end
    end
  end
  #  puts "e=",e
  c=scal.index(b+e) # cis the index of the note
  #  puts "onote=",c,midi2note(scal[c])
  #  puts "z",c,octshift,e
  retval=[c,octshift,e]
  #  puts retval
  return retval
end # getScaleIndex
##### Finishing function for shiftOnScale and invertNote
def gScaleI2(ref,keyscale,d,octshift,e)
  aoct=0
  n=d
  #  octshift=refindex[1]-toneindex[1]
  #  e=refindex[2]-toneindex[2]
  aa=note(ref)
  while d>6
    #    puts "D>>"
    aoct=1 #flag it for later
    d=d-7
  end
  while d<0
    #    puts "D<<"
    aoct=-1 #flag it for later
    d=d+7
  end
  #puts "d=",d,keyscale[d],aoct
  d=keyscale[d]+aoct*12+octshift
  #  puts "DD",aa,d,aa-d
  if (d < aa)  && (n<0)
    #   puts "DDD",aa,d,aa-d
    while (aa-d) > 12
      #     puts "UP"
      d+=12
    end
  end
  #  puts d,midi2note(d)
  return d
end # gScaleI2
##### The shifting function
def shiftOnScale(tone,keyscale,n)
  #  puts tone,keyscale,n
  xxx=getScaleIndex(tone,keyscale)
  #  puts "XXX=",xxx
  if xxx==nil then return :r end
  d=xxx[0]+n
  octshift=xxx[1]
  e=xxx[2]
  retval=gScaleI2(tone,keyscale,d,octshift,e)
  retval=midi2note(retval)
  return retval
end # shiftOnScale
##### The inversion function
def invertNote(ref,tone,keyscale)
  #  puts "IN",ref,tone
  refindex=getScaleIndex(ref,keyscale)
  toneindex=getScaleIndex(tone,keyscale)
  puts "Tone index=",toneindex
  puts "Ref index=",refindex
  if toneindex==nil then return :r end
  if refindex==nil then return :r end
  d=refindex[0]-toneindex[0]
  octshift=refindex[1]-toneindex[1]
  e=refindex[2]-toneindex[2]
  retval=gScaleI2(ref,keyscale,d,octshift,e)
  retval=midi2note(retval)
  return retval
end # invertNote
###########################
## Tests for shiftOnScale
#############
## Test1 runs all 12 major scales with notes from the scale in octave 4
define :test1 do |amplitude|
  start = 60
  size=12
  stop=start+size
  ### play a tune with a 2nd note at an interval
  with_fx :level, amp: amplitude do
    i=start
    while i<stop
      scal1=scale i, :major
      puts "Scale=",i,midi2note(i)
      listit(midi2noteList(scal1))
      j=0
      while j< scal1.length
        nn=shiftOnScale(scal1[j],scal1,interval)
        puts midi2note(scal1[j]),midi2note(nn)
        playit(scal1[j])
        playit(nn)
        sleepit 0.25
        j+=1
      end
      i+=1
    end
  end
end #test1

##################################################################
## New Stuff
##################
##### things to twiddle
amplitude= 0.3
use_synth :fm
#use_synth :beep
key = :C5
mode= :major
#mode= :minor
#mode= :augmented
#mode= :augmented2
#mode= :diminished
#puts scale_names
rel= 1.5 # note release
refn=0
interval=2
#####################################
nle=[0.25,0.25,0.125,0.25] # note length
nle=nle.ring
top1=[4,5,6,7]
bot1=[3,2,1,0]
define :tune2 do |amplitude|
  keyscale=scale key, mode
  ref= note keyscale[refn]
  ref=ref-12
  ks=array_copy(keyscale)
  ks1= ks.slice(0,4)+(ks.slice(4,7)).reverse
  puts keyscale
  puts ks
  puts ks1
  with_fx :level, amp: amplitude do
    k=0
    while k<3
      j=0
      while j<top1.length
        i=0
        while i<nle.length
          v1a=keyscale[top1[j]]
          v1b=keyscale[bot1[j]]
          v2a=shiftOnScale(v1a,keyscale,interval)
          v2b=shiftOnScale(v1b,keyscale,-interval)
          v3a=invertNote(ref,v1a,keyscale)
          v3b=invertNote(ref,v1b,keyscale)
          playit(v1a) #,release: nle[i]*rel)
          playit(v1b) #,release: nle[i]*rel)
          
          if(k>0)
            playit(v2a) #,release: nle[i]*rel)
            playit(v2b) #,release: nle[i]*rel)
          end
          if(k==2)
            playit(v3a) #,release: nle[i]*rel)
            playit(v3b) #,release: nle[i]*rel)
          end
          sleepit nle[i]
          i+=1
        end
        j+=1
      end
      j=3
      while j>0
        i=0
        while i<ks1.length
          v1=shiftOnScale(ks1.reverse[i],keyscale,j)
          v2=shiftOnScale(v1,keyscale,-interval) #-5)
          v3=invertNote(ref,v1,keyscale)
          playit(v1) #,release: nle[i]*rel)
          if(k>0)then playit(v2) end # ,release: nle[i]*rel)
          if(k==2)then playit(v3) end # ,release: nle[i]*rel)
          sleepit nle[i]
          i+=1
        end #next i
        j-=1
      end #next j
      puts keyscale
      playit(76) #,release: 0.25*rel)
      sleepit 0.25
      playit(72) #,release: 0.25*rel)
      sleepit 0.25
      k+=1
    end #next k
    i=0
    et=[0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.5]
    while i<keyscale.length
      playit(keyscale[i]) #,release: et[i]*rel)
      sleepit et[i]
      i+=1
    end
    
  end # with_fx
end #tune2

mode= :major
tune2 0.25


keyscale=scale key, mode
puts shiftOnScale(:r,keyscale,2)
puts shiftOnScale(:E4,keyscale,2)
puts invertNote(:r,:G4,keyscale)
puts invertNote(:C4,:r,keyscale)
puts invertNote(:r,:r,keyscale)
puts invertNote(:C4,:G4,keyscale)

playit(:r)
sleepit 0.25

puts "ot= "+outText
