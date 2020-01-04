use v6.c;

unit package GLib::Raw::Exports;

our @glib-exports is export;

BEGIN {
  @glib-exports = <
    GLib::Raw::Definitions
    GLib::Raw::Enums
    GLib::Raw::Structs
    GLib::Raw::Subs
    GLib::Raw::Exports
  >;
}
