use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;


use GLib::Roles::TypeInstance;

unit package GLib::Raw::Object;

# Predeclarations
class GTypeClass            is repr<CStruct> does GLib::Roles::Pointers is export {
  has GType $.g_type;

  # Lifted from ::Raw::Type, but that compunit cannot be loaded here due to circularity.
  sub g_type_name (GType $type)
    returns Str
    is native(gobject)
  { * }

  method getTypeName { g_type_name($!g_type) }

  method raku {
    ::?CLASS.^name ~ ".new(g_type => { $!g_type } #`[{ self.getTypeName }] )";
  }
  method gist {
    ::?CLASS.^name ~ ".new(g_type => { $!g_type } #`[{ self.getTypeName }] )";
  }
  method Str {
    ::?CLASS.^name ~ ".new(g_type => { $!g_type } #`[{ self.getTypeName }] )";
  }
}

class GTypeInstance         is repr<CStruct> does GLib::Roles::Pointers is export {
  has GTypeClass $.g_class;

  method checkType($compare_type) {
    my GType $ct = $compare_type;

    self.g_class.defined ??
       $ct == self.g_class.g_type            !!
       g_type_check_instance_is_a(self, $ct);
  }

  method getType {
    self.g_class.g_type;
  }

  method getTypeName {
    self.g_class.getTypeName;
  }

}

class GObject         is repr<CStruct> does GLib::Roles::Pointers is export {
  also does GLib::Roles::TypeInstance;

  HAS GTypeInstance  $.g_type_instance;
  has uint32         $.ref_count;
  has Pointer        $!qdata;

  method getTypeName {
    self.g_type_instance.getTypeName;
  }

  method getType {
    self.g_type_instance.getType
  }
}

sub g_type_check_instance_is_a (
  GTypeInstance $instance,
  GType         $iface_type
)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_object_new_with_properties (
  GType       $object_type,
  guint       $n_properties,
  CArray[Str] $names,
  Pointer     $values
)
  returns GObject
  is native(gobject)
  is export
 { * }
