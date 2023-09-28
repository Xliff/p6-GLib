use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;

unit package GLib::Raw::Type;

### /usr/include/glib-2.0/gobject/gtype.h

sub g_type_add_class_cache_func (
  gpointer $cache_data,
  &cache_func (Pointer, GTypeClass --> gboolean)
)
  is native(gobject)
  is export
{ * }

sub g_type_add_class_private (GType $class_type, gsize $private_size)
  is native(gobject)
  is export
{ * }

sub g_type_add_instance_private (GType $class_type, gsize $private_size)
  returns gint
  is native(gobject)
  is export
{ * }

sub g_type_add_interface_check (
  gpointer $check_data,
           &check_func (Pointer, Pointer)
)
  is native(gobject)
  is export
{ * }

sub g_type_add_interface_dynamic (
  GType       $instance_type,
  GType       $interface_type,
  GTypePlugin $plugin
)
  is native(gobject)
  is export
{ * }

sub g_type_add_interface_static (
  GType          $instance_type,
  GType          $interface_type,
  GInterfaceInfo $info
)
  is native(gobject)
  is export
{ * }

sub g_type_check_class_cast (GTypeClass $g_class, GType $is_a_type)
  returns GTypeClass
  is native(gobject)
  is export
{ * }

sub g_type_check_instance (GTypeInstance $instance)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_check_instance_cast (GTypeInstance $instance, GType $iface_type)
  returns GTypeInstance
  is native(gobject)
  is export
{ * }

sub g_type_instance_is_a (
  GTypeInstance $instance,
  GType $fundamental_type
)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_check_instance_is_fundamentally_a (
  GTypeInstance $instance,
  GType         $fundamental_type
)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_check_is_value_type (GType $type)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_check_value (GValue $value)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_check_value_holds (GValue $value, GType $type)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_children (GType $type, guint $n_children)
  returns CArray[GType]
  is native(gobject)
  is export
{ * }

sub g_type_class_add_private (gpointer $g_class, gsize $private_size)
  is native(gobject)
  is export
{ * }

sub g_type_class_adjust_private_offset (
  gpointer $g_class,
  gint     $private_size_or_offset
)
  is native(gobject)
  is export
{ * }

sub g_type_class_get_instance_private_offset (gpointer $g_class)
  returns gint
  is native(gobject)
  is export
{ * }

sub g_type_class_get_private (GTypeClass $klass, GType $private_type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_class_peek (GType $type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_class_peek_parent (gpointer $g_class)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_class_peek_static (GType $type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_class_ref (GType $type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_class_unref (gpointer $g_class)
  is native(gobject)
  is export
{ * }

sub g_type_class_unref_uncached (gpointer $g_class)
  is native(gobject)
  is export
{ * }

sub g_type_create_instance (GType $type)
  returns GTypeInstance
  is native(gobject)
  is export
{ * }

sub g_type_default_interface_peek (GType $g_type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_default_interface_ref (GType $g_type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_default_interface_unref (gpointer $g_iface)
  is native(gobject)
  is export
{ * }

sub g_type_depth (GType $type)
  returns guint
  is native(gobject)
  is export
{ * }

sub g_type_ensure (GType $type)
  is native(gobject)
  is export
{ * }

sub g_type_free_instance (GTypeInstance $instance)
  is native(gobject)
  is export
{ * }

sub g_type_from_name (Str $name)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_fundamental (GType $type_id)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_fundamental_next ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_get_instance_count (GType $type)
  returns gint
  is native(gobject)
  is export
{ * }

sub g_type_get_plugin (GType $type)
  returns GTypePlugin
  is native(gobject)
  is export
{ * }

sub g_type_get_qdata (GType $type, GQuark $quark)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_get_type_registration_serial ()
  returns guint
  is native(gobject)
  is export
{ * }

sub g_type_init ()
  is native(gobject)
  is export
{ * }

sub g_type_init_with_debug_flags (GTypeDebugFlags $debug_flags)
  is native(gobject)
  is export
{ * }

sub g_type_instance_get_private (GTypeInstance $instance, GType $private_type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_interface_add_prerequisite (
  GType $interface_type,
  GType $prerequisite_type
)
  is native(gobject)
  is export
{ * }

sub g_type_interface_get_plugin (GType $instance_type, GType $interface_type)
  returns GTypePlugin
  is native(gobject)
  is export
{ * }

sub g_type_interface_peek (GTypeClass $instance_class, GType $iface_type)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_interface_peek_parent (GTypeInstance $g_iface)
  returns Pointer
  is native(gobject)
  is export
{ * }

sub g_type_interface_prerequisites (
  GType $interface_type,
  guint $n_prerequisites
)
  returns CArray[GType]
  is native(gobject)
  is export
{ * }

sub g_type_interfaces (GType $type, guint $n_interfaces)
  returns CArray[GType]
  is native(gobject)
  is export
{ * }

sub g_type_is_a (GType $type, GType $is_a_type)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_name (GType $type)
  returns Str
  is native(gobject)
  is export
{ * }

sub g_type_name_from_class (GTypeClass $g_class)
  returns Str
  is native(gobject)
  is export
{ * }

sub g_type_name_from_instance (GTypeInstance $instance)
  returns Str
  is native(gobject)
  is export
{ * }

sub g_type_next_base (GType $leaf_type, GType $root_type)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_parent (GType $type)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_qname (GType $type)
  returns GQuark
  is native(gobject)
  is export
{ * }

sub g_type_query (GType $type, GTypeQuery $query)
  is native(gobject)
  is export
{ * }

sub g_type_register_dynamic (
  GType $parent_type,
  Str $type_name,
  GTypePlugin $plugin,
  GTypeFlags $flags
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_register_fundamental (
  GType $type_id,
  Str $type_name,
  GTypeInfo $info,
  GTypeFundamentalInfo $finfo,
  GTypeFlags $flags
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_register_static (
  GType $parent_type,
  Str $type_name,
  GTypeInfo $info,
  GTypeFlags $flags
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_register_static_simple (
  GType $parent_type,
  Str $type_name,
  guint $class_size,
  Pointer $class_init, # GClassInitFunc
  guint $instance_size,
  Pointer $instance_init, # GInstanceInitFunc
  GTypeFlags $flags
)
  returns GType
  is native(gobject)
  is export
{ * }

sub g_type_remove_class_cache_func (
  gpointer $cache_data,
  &cache_func (Pointer, GTypeClass --> gboolean)
)
  is native(gobject)
  is export
{ * }

sub g_type_remove_interface_check (
  Pointer $check_data,
  &check_func (Pointer, Pointer)
 )
  is native(gobject)
  is export
{ * }

sub g_type_set_qdata (GType $type, GQuark $quark, gpointer $data)
  is native(gobject)
  is export
{ * }

sub g_type_test_flags (GType $type, guint $flags)
  returns uint32
  is native(gobject)
  is export
{ * }

sub g_type_value_table_peek (GType $type)
  returns GTypeValueTable
  is native(gobject)
  is export
{ * }
