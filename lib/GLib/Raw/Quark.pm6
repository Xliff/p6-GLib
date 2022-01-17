use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Object;
use GLib::Raw::Structs;

unit package GLib::Raw::Quark;

sub g_quark_from_static_string (Str $string)
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_quark_from_string (Str $string)
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_intern_static_string (Str $string)
  returns Str
  is native(glib)
  is export
{ * }

sub g_intern_string (Str $string)
  returns Str
  is native(glib)
  is export
{ * }

sub g_quark_to_string (GQuark $quark)
  returns Str
  is native(glib)
  is export
{ * }

sub g_quark_try_string (Str $string)
  returns GQuark
  is native(glib)
  is export
{ * }
