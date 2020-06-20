use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;

use GLib::Roles::Pointers;
use GLib::Roles::TypeInstance;

unit package GLib::Raw::Object;

# Predeclarations
class GTypeClass            is repr<CStruct> does GLib::Roles::Pointers is export {
  has GType      $.g_type;
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
}

class GObject         is repr<CStruct> does GLib::Roles::Pointers is export {
  also does GLib::Roles::TypeInstance;

  HAS GTypeInstance  $.g_type_instance;
  has uint32         $.ref_count;
  has Pointer        $!qdata;
}

sub g_type_check_instance_is_a (
  GTypeInstance $instance,
  GType         $iface_type
)
  returns uint32
  is native(gobject)
  is export
{ * }
