use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GLib::Raw::Object;



use GLib::Roles::TypedBuffer;

unit package GLib::Class::Structs;

class GEnumValue is repr<CStruct> does GLib::Roles::Pointers is export {
  has gint $.value;
  has Str  $.value_name;
  has Str  $.value_nick;

  method name { $!value_name }
  method nick { $!value_nick }
}

class GFlagsValue is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint $.value;
  has Str  $.value_name;
  has Str  $.value_nick;

  method name { $!value_name }
  method nick { $!value_nick }
}

role ValueArray {
  method valueArray {
    my $vb = GLib::Roles::TypedBuffer[GFlagsValue].new(self.values);

    $vb.setSize(self.n_values, :force);
    $vb.Array
  }
}

class GFlagsClass is repr<CStruct> does GLib::Roles::Pointers is export {
  also does ValueArray;

  HAS GTypeClass   $.g_type_class;
  has guint        $.mask;
  has guint        $.n_values;
  has Pointer      $.values;        #= Array of GFlagsValue

  method complete_type_info (
    Int() $g_flags_type,
    GTypeInfo $info,
    GFlagsValue $const_values
  ) {
    my GType $ft = $g_flags_type;

    g_flags_complete_type_info($ft, $info, $const_values);
  }

  method get_first_value (Int() $value) {
    my guint $v = $value;

    g_flags_get_first_value(self, $value);
  }

  method get_value_by_name (Str() $name) {
    g_flags_get_value_by_name(self, $name);
  }

  method get_value_by_nick (Str() $nick) {
    g_flags_get_value_by_nick(self, $nick);
  }

  method register_static (
    GFlagsClass:U:
    Str() $name,
    GFlagsValue $const_static_values
  ) {
    g_flags_register_static($name, $const_static_values);
  }

  method to_string (GFlagsClass:U: Int() $flags_type, Int() $value) {
    my GType $ft = $flags_type;
    my guint $v = $value;

    g_flags_to_string($ft, $v);
  }
}

class GEnumClass is repr<CStruct> does GLib::Roles::Pointers is export {
  also does ValueArray;

  HAS GTypeClass  $.g_type_class;
  has gint        $.minimum;
  has gint        $.maximum;
  has guint       $.n_values;
  has Pointer     $.values;        #= Array of GEnumValues

  method complete_type_info (
    Int() $g_enum_type,
    GTypeInfo $info,
    GEnumValue $const_values
  ) {
    my GType $et = $g_enum_type;

    g_enum_complete_type_info($et, $info, $const_values);
  }

  method get_value (Int() $value) {
    my gint $v = $value;

    g_enum_get_value(self, $v);
  }

  method get_value_by_name (Str() $name) {
    g_enum_get_value_by_name(self, $name);
  }

  method get_value_by_nick (Str() $nick) {
    g_enum_get_value_by_nick(self, $nick);
  }

  method register_static (
    GEnumClass:U:
    Str() $name,
    GEnumValue $const_static_values
  ) {
    g_enum_register_static($name, $const_static_values);
  }

  method to_string (
    GEnumClass:U:
    Int() $g_enum_type,
    Int() $value
  ) {
    my GType $t = $g_enum_type;
    my guint $v = $value;

    g_enum_to_string($t, $v);
  }

}

### /usr/include/glib-2.0/gobject/genums.h

sub g_enum_complete_type_info (GType $g_enum_type, GTypeInfo $info, GEnumValue $const_values)
  is native(gobject)
  is export
{ * }

sub g_enum_get_value (GEnumClass $enum_class, gint $value)
  returns GEnumValue
  is native(gobject)
  is export
{ * }

sub g_enum_get_value_by_name (GEnumClass $enum_class, Str $name)
  returns GEnumValue
  is native(gobject)
  is export
{ * }

sub g_enum_get_value_by_nick (GEnumClass $enum_class, Str $nick)
  returns GEnumValue
  is native(gobject)
  is export
{ * }

sub g_enum_register_static (Str $name, GEnumValue $const_static_values)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_enum_to_string (GType $g_enum_type, gint $value)
  returns Str
  is native(gobject)
  is export
{ * }

sub g_flags_complete_type_info (GType $g_flags_type, GTypeInfo $info, GFlagsValue $const_values)
  is native(gobject)
  is export
{ * }

sub g_flags_get_first_value (GFlagsClass $flags_class, guint $value)
  returns GFlagsValue
  is native(gobject)
  is export
{ * }

sub g_flags_get_value_by_name (GFlagsClass $flags_class, Str $name)
  returns GFlagsValue
  is native(gobject)
  is export
{ * }

sub g_flags_get_value_by_nick (GFlagsClass $flags_class, Str $nick)
  returns GFlagsValue
  is native(gobject)
  is export
{ * }

sub g_flags_register_static (Str $name, GFlagsValue $const_static_values)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_flags_to_string (GType $flags_type, guint $value)
  returns Str
  is native(gobject)
  is export
{ * }
