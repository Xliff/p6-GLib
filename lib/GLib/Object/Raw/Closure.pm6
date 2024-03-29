use v6.c;

use GLib::Raw::Types;

unit package gobject::Object::Raw::Closure;

### /usr/include/gobject-2.0/gobject/gclosure.h

sub g_closure_add_finalize_notifier (
  GClosure $closure,
  gpointer $notify_data,
           &notify_func (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_closure_add_invalidate_notifier (
  GClosure $closure,
  gpointer $notify_data,
           &notify_func (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_closure_add_marshal_guards (
  GClosure $closure,
  gpointer $pre_marshal_data,
           &pre_marshal_notify (gpointer),
  gpointer $post_marshal_data,
           &post_marshal_notify (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_cclosure_marshal_generic (
  GClosure $closure,
  GValue   $return_gvalue,
  guint    $n_param_values,
  GValue   $param_values,
  gpointer $invocation_hint,
  gpointer $marshal_data
)
  is native(gobject)
  is export
{ * }

# sub g_cclosure_marshal_generic_va (
#   GClosure $closure,
#   GValue $return_value,
#   gpointer $instance,
#   va_list $args_list,
#   gpointer $marshal_data,
#   gint $n_params,
#   GType $param_types
# )
#   is native(gobject)
#   is export
# { * }

sub g_cclosure_new (
                 &callback_func (),
  gpointer       $user_data,
                 &destroy_data (gpointer)
)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_cclosure_new_swap (
           &callback_func (),
  gpointer $user_data,
           &destroy_data (gpointer)
)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_cclosure_new_object (
          &callback_func (),
  GObject $object
)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_signal_type_cclosure_new (GType $itype, guint $struct_offset)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_closure_invalidate (GClosure $closure)
  is native(gobject)
  is export
{ * }

sub g_closure_new_simple (guint $sizeof_closure, gpointer $data)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_closure_ref (GClosure $closure)
  returns GClosure
  is native(gobject)
  is export
{ * }

sub g_closure_remove_finalize_notifier (
  GClosure $closure,
  gpointer $notify_data,
           &notify_func (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_closure_remove_invalidate_notifier (
  GClosure $closure,
  gpointer $notify_data,
           &notify_func (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_closure_set_marshal (GClosure $closure, GClosureMarshal $marshal)
  is native(gobject)
  is export
{ * }

sub g_closure_set_meta_marshal (
  GClosure $closure,
  gpointer $marshal_data,
           &meta_marshal (gpointer)
)
  is native(gobject)
  is export
{ * }

sub g_closure_sink (GClosure $closure)
  is native(gobject)
  is export
{ * }

sub g_closure_unref (GClosure $closure)
  is native(gobject)
  is export
{ * }
