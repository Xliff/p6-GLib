use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Object::Raw::Class;

sub g_initially_unowned_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_object_class_install_property (
  GObjectClass $oclass,
  guint        $property_id,
  GParamSpec   $pspec
)
  is native(gobject)
  is export
{ * }

sub g_object_class_find_property (
  GObjectClass $oclass,
  Str          $property_name
)
  returns GParamSpec
  is native(gobject)
  is export
{ * }

sub g_object_class_list_properties (
  GObjectClass $oclass,
  guint        $n_properties
)
  returns CArray[Pointer[GParamSpec]]
  is native(gobject)
  is export
{ * }

sub g_object_class_override_property  (
  GObjectClass $oclass,
  guint        $property_id,
  Str          $name
)
  is native(gobject)
  is export
{ * }

sub g_object_class_install_properties (
  GObjectClass                $oclass,
  guint                       $n_pspecs,
  CArray[Pointer[GParamSpec]] $pspecs # GParamSpec**
)
  is native(gobject)
  is export
{ * }

sub g_object_interface_install_property (
  gpointer    $g_iface,
  GParamSpec  $pspec
)
  is native(gobject)
  is export
{ * }

sub g_object_interface_find_property (
  gpointer $g_iface,
  Str      $property_name
)
  returns GParamSpec
  is native(gobject)
  is export
{ * }

sub g_object_interface_list_properties (
  gpointer $g_iface,
  guint    $n_properties_p
)
  returns CArray[Pointer[GParamSpec]]
  is native(gobject)
  is export
{ * }
