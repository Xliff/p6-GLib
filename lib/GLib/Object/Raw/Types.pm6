use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

unit package GLib::Object::Raw::Types;

sub g_strv_get_type
  returns GType
  is native(gobject)
  is export
{ * }
