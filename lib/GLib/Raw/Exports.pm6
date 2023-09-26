use v6.c;

unit package GLib::Raw::Exports;

use CompUnit::Util :re-export;

our @glib-exports is export = <
  GLib::Raw::Debug
  GLib::Raw::Definitions
  GLib::Raw::Object
  GLib::Raw::Enums
  GLib::Raw::Exceptions
  GLib::Raw::Structs
  GLib::Raw::Subs
  GLib::Raw::Struct_Subs
  GLib::Roles::Pointers
  GLib::Roles::Implementor
>;

our %exported;

sub glib-re-export ($compunit) is export {
  return if %exported{$compunit}:exists;

  re-export-everything($compunit);
  %exported{$compunit} = True;
}
