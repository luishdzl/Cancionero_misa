import 'package:flutter/material.dart';

class SelectChord extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  static const List<String> chordOptions = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm', 'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm'
  ];

  const SelectChord({
    super.key,
    this.value,
    this.onChanged,
    required this.labelText,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      items: chordOptions.map((String chord) {
        return DropdownMenuItem<String>(
          value: chord,
          child: Text(chord),
        );
      }).toList(),
    );
  }
}