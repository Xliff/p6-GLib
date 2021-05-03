use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Raw::TypedPlugin;

### /usr/include/glib-2.0/gobject/gtypeplugin.h

sub g_type_plugin_complete_interface_info (
  GTypePlugin    $plugin,
  GType          $instance_type,
  GType          $interface_type,
  GInterfaceInfo $info
)
  is native(gobject)
  is export
{ * }

sub g_type_plugin_complete_type_info (
  GTypePlugin     $plugin,
  GType           $g_type,
  GTypeInfo       $info,
  GTypeValueTable $value_table
)
  is native(gobject)
  is export
{ * }

sub g_type_plugin_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_plugin_unuse (GTypePlugin $plugin)
  is native(gobject)
  is export
{ * }

sub g_type_plugin_use (GTypePlugin $plugin)
  is native(gobject)
  is export
{ * }
