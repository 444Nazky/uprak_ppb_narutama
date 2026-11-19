import 'dart:io';

import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.label,
    this.photoPath,
    this.size = 48,
    this.background,
    this.foreground,
  });

  final String label;
  final String? photoPath;
  final double size;
  final Color? background;
  final Color? foreground;

  static const _palette = <List<Color>>[
    [Color(0xFFDBEAFE), Color(0xFF1E3A8A)],
    [Color(0xFFCCFBF1), Color(0xFF115E59)],
    [Color(0xFFFEF3C7), Color(0xFF92400E)],
    [Color(0xFFFFE4E6), Color(0xFF9F1239)],
    [Color(0xFFEDE9FE), Color(0xFF5B21B6)],
    [Color(0xFFDCFCE7), Color(0xFF166534)],
  ];

  @override
  Widget build(BuildContext context) {
    final pair = _palette[label.hashCode.abs() % _palette.length];
    final bg = background ?? pair[0];
    final fg = foreground ?? pair[1];
    final radius = size / 2;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        label.isEmpty ? '?' : label,
        style: TextStyle(
          color: fg,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );

    final path = photoPath;
    if (path == null || path.isEmpty) {
      return Semantics(label: 'Avatar $label', child: fallback);
    }

    return Semantics(
      label: 'Foto $label',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, _, _) => fallback,
          ),
        ),
      ),
    );
  }
}
