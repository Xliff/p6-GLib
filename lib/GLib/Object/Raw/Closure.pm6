use v6.c;

use GLib::Raw::Types;

unit package GLib::Object::Raw::Closure;

### /usr/include/glib-2.0/gobject/gclosure.h

sub g_closure_add_finalize_notifier (
  GClosure $closure,
  gpointer $notify_data,
  GClosureNotify $notify_func
)
  is native(glib)
  is export
{ * }

sub g_closure_add_invalidate_notifier (
  GClosure $closure,
  gpointer $notify_data,
  GClosureNotify $notify_func
)
  is native(glib)
  is export
{ * }

sub g_closure_add_marshal_guards (
  GClosure $closure,
  gpointer $pre_marshal_data,
  GClosureNotify $pre_marshal_notify,
  gpointer $post_marshal_data,
  GClosureNotify $post_marshal_notify
)
  is native(glib)
  is export
{ * }

sub g_cclosure_marshal_generic (
  GClosure $closure,
  GValue $return_gvalue,
  guint $n_param_values,
  GValue $param_values,
  gpointer $invocation_hint,
  gpointer $marshal_data
)
  is native(glib)
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
#   is native(glib)
#   is export
# { * }

sub g_cclosure_new (
  &callback_func (),
  gpointer $user_data,
  GClosureNotify $destroy_data
)
  returns GClosure
  is native(glib)
  is export
{ * }

sub g_cclosure_new_swap (
  &callback_func (),
  gpointer $user_data,
  GClosureNotify $destroy_data
)
  returns GClosure
  is native(glib)
  is export
{ * }

sub g_signal_type_cclosure_new (GType $itype, guint $struct_offset)
  returns GClosure
  is native(glib)
  is export
{ * }

sub g_closure_invalidate (GClosure $closure)
  is native(glib)
  is export
{ * }

sub g_closure_new_simple (guint $sizeof_closure, gpointer $data)
  returns GClosure
  is native(glib)
  is export
{ * }

sub g_closure_ref (GClosure $closure)
  returns GClosure
  is native(glib)
  is export
{ * }

sub g_closure_remove_finalize_notifier (
  GClosure $closure,
  gpointer $notify_data,
  GClosureNotify $notify_func
)
  is native(glib)
  is export
{ * }

sub g_closure_remove_invalidate_notifier (
  GClosure $closure,
  gpointer $notify_data,
  GClosureNotify $notify_func
)
  is native(glib)
  is export
{ * }

sub g_closure_set_marshal (GClosure $closure, GClosureMarshal $marshal)
  is native(glib)
  is export
{ * }

sub g_closure_set_meta_marshal (
  GClosure $closure,
  gpointer $marshal_data,
  GClosureMarshal $meta_marshal
)
  is native(glib)
  is export
{ * }

sub g_closure_sink (GClosure $closure)
  is native(glib)
  is export
{ * }

sub g_closure_unref (GClosure $closure)
  is native(glib)
  is export
{ * }
