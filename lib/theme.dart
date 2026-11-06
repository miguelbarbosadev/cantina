import 'package:flutter/material.dart';

const kLaranja = Color(0xFFE65100);

/// AppBar padrão do app (title, centerTitle, backgroundColor) — aula 02.
AppBar cantinaAppBar(String titulo, {List<Widget>? actions}) {
  return AppBar(
    title: Text(
      titulo,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    backgroundColor: kLaranja,
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions,
  );
}
