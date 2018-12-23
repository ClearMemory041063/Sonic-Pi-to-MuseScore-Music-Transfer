//readTune.qml

import QtQuick 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import MuseScore 1.0
import FileIO 1.0

MuseScore {
 menuPath: "Plugins.readTune"
 version: "2.0"
 description: qsTr("This plugin imports 
text from a file or the clipboard.") 
 pluginType: "dialog"
 id:window
 width:  800; height: 500;
 onRun: {
 }//end onRun

 FileIO {
  id: myFile
  onError: console.log(msg + "  Filename = " + myFileAbc.source)
 }//end FileIO

 FileDialog {
  id: fileDialog
  title: qsTr("Please choose a file")
  onAccepted: {
   var filename = fileDialog.fileUrl
   if(filename){
    myFile.source = filename;
    //read file and put it in the TextArea
    aText.text = myFile.read();
   }//end if filename
  }//end onAccepted
 }//end FileDialog

 Label {
  id: textLabel
  wrapMode: Text.WordWrap
  text: qsTr("Paste your tune here (or click button to load a file)\n")
  font.pointSize:12
  anchors.left: window.left
  anchors.top: window.top
  anchors.leftMargin: 10
  anchors.topMargin: 10
 }//end Label

// Where people can paste their tune or where an file is put when opened
 TextArea {
  id:aText
  anchors.top: textLabel.bottom
  anchors.left: window.left
  anchors.right: window.right
  anchors.bottom: buttonOpenFile.top
  anchors.topMargin: 10
  anchors.bottomMargin: 10
  anchors.leftMargin: 10
  anchors.rightMargin: 10
  width:parent.width
  height:400
  wrapMode: TextEdit.WrapAnywhere
  textFormat: TextEdit.PlainText
 }//end TextArea

 Button {
  id : buttonOpenFile
  text: qsTr("Open file")
  anchors.bottom: window.bottom
  anchors.left: aText.left
  anchors.topMargin: 10
  anchors.bottomMargin: 10
  anchors.leftMargin: 10
  onClicked: {
   fileDialog.open();
  }//end on clicked
 }//end Button

 Button {
  id : buttonConvert
  text: qsTr("Import")
  anchors.bottom: window.bottom
  anchors.left: buttonOpenFile.right //aText.right
  anchors.topMargin: 10
  anchors.bottomMargin: 10
  anchors.rightMargin: 10
  onClicked: {
var tune=aText.text.split(";");
 rflag=false;
 var nt=[];
 var ichord=[];
 var a,b; 
 var i,j;
for(i=0;i<tune.length-1;i++){
 a=tune[i].split(",");
 nt=[];
 nt.push(a[0]);nt.push(a[1]);
 ichord=[];
 for(j=2;j<a.length;j++)ichord.push(a[j]);
 console.log("xxxa= ",i,nt,ichord);
 apply(nt,ichord);
}
   Qt.quit();
  }//end onClick
 }//end Button

 Button {
  id : buttonCancel
  text: qsTr("Cancel")
  anchors.bottom: window.bottom
  anchors.left: buttonConvert.right
  anchors.topMargin: 10
  anchors.bottomMargin: 10
  onClicked: {
   Qt.quit();
  }//end onClicked
 }//end button
// }
////////////////////
// function to create and return a new Note element with given (midi) pitch, tpc1, tpc2 and headtype
 function createNote(pitch, tpc1, tpc2, head){
  var note = newElement(Element.NOTE);
  console.log("pitch= ",pitch);
  note.pitch = pitch;
  var pitch_mod12 = pitch%12; 
  var pitch2tpc=[14,21,16,23,18,13,20,15,22,17,24,19]; //get tpc from pitch... yes there is a logic behind these numbers :-p
  if (tpc1){
   note.tpc1 = tpc1;
   note.tpc2 = tpc2;
  }else{
   note.tpc1 = pitch2tpc[pitch_mod12];
   note.tpc2 = pitch2tpc[pitch_mod12];
  }//endif
  if (head) note.headType = head; 
  else note.headType = NoteHead.HEAD_AUTO;
   console.log("  created note with tpc: ",note.tpc1," ",note.tpc2," pitch: ",note.pitch);
  return note;
 }//end createNote  
 function setCursorToTime(cursor, time){
  cursor.rewind(0);
  while (cursor.segment) { 
   var current_time = cursor.tick;
   if(current_time>=time){
    return true;
   }//endif
   cursor.next();
  }//end while
  cursor.rewind(0);
  return false;
 }//end setCursorTo Time

// global variables to allow apply to repeat
 property var rflag: false
 property var cursor: 0
 property var cscore: 0 

// Apply the given function to all notes in selection
// or, if nothing is selected, in the entire score
 function apply(nt,ichord){
// console.log("nt= ",nt,nt[0],nt[1]);
// return;
  //var nt=[1,1];
  //var st;
  //var pn;
  //var oct;
  //var inv;
  var slen; 
  var i=0;
  var staff=0;
  var voice=0;
  var next_time;
  var chord; 
  var cur_time;
  var rest; 
  var startStaff;
  var endStaff;
  var endTick;
  //var ichord;
  var fullScore = false;
  cscore=curScore;
  cscore.startCmd();

  if(!rflag){ // do this on first call
   cscore=curScore;
   cursor = curScore.newCursor();
   cursor.rewind(1);
   cursor = curScore.newCursor();
   cursor.rewind(1);
   if (!cursor.segment) { // no selection
    fullScore = true;
    startStaff = 0; // start with 1st staff
    endStaff = curScore.nstaves - 1; // and end with last
   } else {
    startStaff = cursor.staffIdx;
    cursor.rewind(2);
    if (cursor.tick == 0) {
// this happens when the selection includes
// the last measure of the score.
// rewind(2) goes behind the last segment (where
// there's none) and sets tick=0
     endTick = curScore.lastSegment.tick + 1;
    } else {
     endTick = cursor.tick;
    }//end if cursor.tick
    endStaff = cursor.staffIdx;
   }//end cursor.segment
   console.log(startStaff + " - " + endStaff + " - " + endTick)
   staff=startStaff
   voice=0;
   cursor.rewind(1); // sets voice to 0
   cursor.voice = voice; //voice has to be set after goTo
   cursor.staffIdx = staff; //staff 0=treble, 1=bass
   if (fullScore)cursor.rewind(0) // if no selection, beginning of score
   rflag=true;
  }//end if !rflag
/// this code runs for all calls to apply
// get data from interface widgets
//  nt=notetime[noteType.model.get(noteType.currentIndex).note];
//  st=chordType.model.get(chordType.currentIndex).note
//  pn=pivotNote.model.get(pivotNote.currentIndex).note;
//  oct=octave.model.get(octave.currentIndex).note;
//  inv=cInversion.model.get(cInversion.currentIndex).note;
// now work with it
  if(ichord[0]>-1){//if(st> -1){
//ichord=invertChord(chords[st],inv);
   slen=ichord.length;
   cur_time=cursor.tick;
console.log("chord= ",nt,ichord);   
   cursor.setDuration(nt[0],nt[1]);
///
// if (cursor.element.type == Element.CHORD) //console.log("CHORD");
// if (cursor.element.type == Element.REST) console.log("REST");
///
// https://github.com/musescore/MuseScore/tree/master/libmscore
//console.log("Element duration //",chord.duration.numerator,chord.duration.denominator);
///
   cursor.addNote(ichord[0]); //add 1st note
   next_time=cursor.tick;
   setCursorToTime(cursor, cur_time); //rewind to this note
//get the chord created when 1st note was inserted
   chord = cursor.element; 
   for(var i=1; i<ichord.length; i++){
   //add notes to the chord
    chord.add(createNote(ichord[i])); 
   }//next i
   setCursorToTime(cursor, next_time);
  }else{ // add a rest
   // add a note to beep
   cur_time=cursor.tick;
   cursor.setDuration(nt[0],nt[1]);
   cursor.addNote(60); //add 1st note
   next_time=cursor.tick;
   setCursorToTime(cursor, cur_time); //rewind to this note
   //replace note with rest
   rest = newElement(Element.REST);
   rest.durationType = cursor.element.durationType;
   rest.duration = cursor.element.duration;cursor.add(rest);
   cursor.next();
  }//end if st> -1 else
  cscore.endCmd();
 }//end apply function

/////////////////
}//end Musescore
