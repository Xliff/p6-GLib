use v6;

use CompUnit::Util :re-export;

use GLib::Raw::Exports;

unit package GLib::Raw::Types;

need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Exceptions;
need GLib::Raw::Object;
need GLib::Raw::Structs;
need GLib::Raw::Subs;
need GLib::Raw::Struct_Subs;
need GLib::Roles::Pointers;

BEGIN {
  glib-re-export($_) for @GLib::Raw::Exports::glib-exports;
}
