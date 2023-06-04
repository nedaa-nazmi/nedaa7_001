import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:piano/piano.dart';

void main() {
  runApp(MaterialApp(
    home: piano(),
    debugShowCheckedModeBanner: false,
  ));
}

class piano extends StatefulWidget {
  @override
  State<piano> createState() => _pianoState();
}

class _pianoState extends State<piano> {
  final _flutterMidi = FlutterMidi();

  @override
  void initState() {
    if (!kIsWeb) {
      load(_value);
    } else {
      _flutterMidi.prepare(sf2: null);
    }
    super.initState();
  }

  void load(String asset) async {
    _flutterMidi.unmute();
    ByteData _byte = await rootBundle.load(asset);

    _flutterMidi.prepare(sf2: _byte, name: _value.replaceAll('assets/', ''));
  }

  String _value = 'assets/Piano.sf2';
  String _value1 = 'assets/Best of Guitars-4U-v1.0.sf2';
  // String _value2 = 'assets/Piano.sf2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Piano Demo'),
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
            icon: Icon(Icons.published_with_changes_outlined),
            onPressed: () {
              load(_value1);
              print("0000");
            },
          )
        ],
      ),
      body: InteractivePiano(
        highlightedNotes: [NotePosition(note: Note.C, octave: 3)],
        naturalColor: Colors.white,
        accidentalColor: Colors.black,
        keyWidth: 60,
        noteRange: NoteRange.forClefs([
          Clef.Treble,
        ]),
        onNotePositionTapped: (position) {
          int midiNote = calculateMidiNoteNumber(position);

          _playPiano(midiNote);
          print("1111");
          Future.delayed(Duration(seconds: 1), () {
            _stopPiano(midiNote);
          });
        },
      ),
    );
  }

  void _playPiano(int midi) {
    _flutterMidi.playMidiNote(midi: midi);
  }

  void _stopPiano(int midi) {
    _flutterMidi.stopMidiNote(midi: midi);
  }

  int calculateMidiNoteNumber(NotePosition notePosition) {
    int baseNote = 60; // MIDI note number for middle C
    int octaveOffset = (notePosition.octave - 3) * 12;
    int noteOffset = notePosition.note.index;
    return baseNote + octaveOffset + noteOffset;
  }
}
