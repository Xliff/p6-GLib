use v6.c;

unit class GLib::Raw::ReturnedValue is export;

has $.val is rw;

method r is rw { $!val }
