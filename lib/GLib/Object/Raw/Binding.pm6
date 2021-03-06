use v6.c;

use NativeCall;

use GLib::Raw::Types;

unit package GLib::Object::Raw::Binding;

sub g_object_bind_property (
  GObject $source,
  Str     $source_property,
  GObject $target,
  Str     $target_property,
  uint32  $flags                           # GBindingFlags $flags
)
  returns GBinding
  is native(gobject)
  is export
  { * }

sub g_object_bind_property_full (
  GObject $source,
  Str     $source_property,
  GObject $target,
  Str     $target_property,
  uint32  $flags,                          # GBindingFlags $flags,
          &transform_to   (GBinding, GValue, GValue, gpointer --> gboolean),
          &transform_from (GBinding, GValue, GValue, gpointer --> gboolean),
  Pointer $user_data,
          &notify (gpointer)
)
  returns GBinding
  is native(gobject)
  is export
  { * }

sub g_object_bind_property_with_closures (
  GObject  $source,
  Str      $source_property,
  GObject  $target,
  Str      $target_property,
  uint32   $flags,                          # GBindingFlags $flags,
  GClosure $transform_to,
  GClosure $transform_from
)
  returns GBinding
  is native(gobject)
  is export
  { * }

sub g_binding_get_flags (GBinding $binding)
  returns uint32 # GBindingFlags
  is native(gobject)
  is export
  { * }

sub g_binding_get_source (GBinding $binding)
  returns GObject
  is native(gobject)
  is export
  { * }

sub g_binding_get_source_property (GBinding $binding)
  returns Str
  is native(gobject)
  is export
  { * }

sub g_binding_get_target (GBinding $binding)
  returns GObject
  is native(gobject)
  is export
  { * }

sub g_binding_get_target_property (GBinding $binding)
  returns Str
  is native(gobject)
  is export
  { * }

sub g_binding_get_type ()
  returns GType
  is native(gobject)
  is export
  { * }

sub g_binding_unbind (GBinding $binding)
  is native(gobject)
  is export
  { * }
