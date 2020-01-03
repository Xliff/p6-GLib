use v6;

use CompUnit::Util :re-export;

unit package GLib::Raw::Types;

need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Structs;
need GLib::Raw::Subs;

our @glib-exports is export;

BEGIN {
  @glib-exports = <
    GLib::Raw::Definitions
    GLib::Raw::Enums
    GLib::Raw::Structs
    GLib::Raw::Subs
  >;
  re-export($_) for @glib-exports;
}
