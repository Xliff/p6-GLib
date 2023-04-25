use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;
use GLib::Class::Structs;

unit package GLib::Object::Raw::TypeModule;

### /usr/include/glib-2.0/gobject/gtypemodule.h

sub g_type_module_add_interface (
  GTypeModule    $module,
  GType          $instance_type,
  GType          $interface_type,
  GInterfaceInfo $interface_info
)
  is native(gobject)
  is export
{ * }

sub g_type_module_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_module_register_enum (
  GTypeModule $module,
  Str         $name,
  GEnumValue  $const_static_values
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_module_register_flags (
  GTypeModule $module,
  Str         $name,
  GFlagsValue $const_static_values
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_module_register_type (
  GTypeModule $module,
  GType       $parent_type,
  Str         $type_name,
  GTypeInfo   $type_info,
  GTypeFlags  $flags
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_module_set_name (GTypeModule $module, Str $name)
  is native(gobject)
  is export
{ * }

sub g_type_module_unuse (GTypeModule $module)
  is native(gobject)
  is export
{ * }

sub g_type_module_use (GTypeModule $module)
  returns uint32
  is native(gobject)
  is export
{ * }

sub  g_type_register_static_simple (
  GType      $parent_type,
  Str        $type_name,
  guint      $class_size,
             &class_init (gpointer, gpointer),
  guint      $instance_size,
             &instance_init (gpointer, gpointer),
  GTypeFlags $flags
)
  returns GType
  is      native(gobject)
  is      export
{ * }
