use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Object::Raw::Closure;

use GLib::Roles::Object;

our subset GClosureAncestry is export of Mu
  where GClosure | GObject;

class GLib::Object::Closure {
  also does GLib::Roles::Object;

  has GClosure $!c is implementor;

  method BUILD (:$closure) {
    self.setGClosure($closure) if $closure;
  }

  method setGClosure (GClosureAncestry $_) {
    my $to-parent;

    $!c = do {
      when GClosure {
        $to-parent = cast(GObject, $_);
        $_
      }

      default {
        $to-parent = $_;
        cast(GClosure, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GLib::Raw::Structs::GClosure
    is also<GClosure>
  { $!c }

  method new (GClosureAncestry $closure, :$ref = True) {
    $closure ?? self.bless(:$closure) !! Nil;

    my $o = self.bless( :$closure );
    $o.ref if $ref;
    $o;
  }

  method new_simple (Int() $size, gpointer $data = gpointer)
    is also<new-simple>
  {
    my guint $s = $size;
    my $closure = g_closure_new_simple($s, $data);

    $closure ?? self.bless(:$closure) !! Nil;
  }

  method add_finalize_notifier (
    gpointer $notify_data,
             &notify_func  = %DEFAULT-CALLBACKS<GDestroyNotify>
  )
    is also<add-finalize-notifier>
  {
    g_closure_add_finalize_notifier($!c, $notify_data, &notify_func);
  }

  method add_invalidate_notifier (
    gpointer $notify_data,
             &notify_func  = %DEFAULT-CALLBACKS<GDestroyNotify>
  )
    is also<add-invalidate-notifier>
  {
    g_closure_add_invalidate_notifier($!c, $notify_data, &notify_func);
  }

  method add_marshal_guards (
    gpointer $pre_marshal_data,
             &pre_marshal_notify  = %DEFAULT-CALLBACKS<GDestroyNotify>,
    gpointer $post_marshal_data   = gpointer,
             &post_marshal_notify = %DEFAULT-CALLBACKS<GDestroyNotify>
  )
    is also<add-marshal-guards>
  {
    g_closure_add_marshal_guards(
      $!c,
      $pre_marshal_data,
      &pre_marshal_notify,
      $post_marshal_data,
      &post_marshal_notify
    );
  }

  method invalidate {
    g_closure_invalidate($!c);
  }

  method ref {
    g_closure_ref($!c);
  }

  method remove_finalize_notifier (
    gpointer $notify_data,
             &notify_func  = %DEFAULT-CALLBACKS<GDestroyNotify>
  )
    is also<remove-finalize-notifier>
  {
    g_closure_remove_finalize_notifier($!c, $notify_data, &notify_func);
  }

  method remove_invalidate_notifier (
    gpointer $notify_data,
             &notify_func  = %DEFAULT-CALLBACKS<GDestroyNotify>
  )
    is also<remove-invalidate-notifier>
  {
    g_closure_remove_invalidate_notifier($!c, $notify_data, &notify_func);
  }

  method set_marshal (GClosureMarshal $marshal) is also<set-marshal> {
    g_closure_set_marshal($!c, $marshal);
  }

  method set_meta_marshal (
    gpointer        $marshal_data,
    GClosureMarshal $meta_marshal
  )
    is also<set-meta-marshal>
  {
    g_closure_set_meta_marshal($!c, $marshal_data, $meta_marshal);
  }

  method sink {
    g_closure_sink($!c);
  }

  method unref {
    g_closure_unref($!c);
  }

}

class GLib::Object::Closure::C is GLib::Object::Closure {

  # XXX - Define $callback!
  # For now.... it's a void function with no parameters!!
  method new (
             &callback,
    gpointer $user_data    = gpointer,
             $destroy_data = gpointer
  ) {
    my $closure = g_cclosure_new(&callback, $user_data, $destroy_data);

    $closure ?? self.bless(:$closure) !! Nil;
  }

  # XXX - Define $callback!
  # For now.... it's a void function with no parameters!!
  method new_swap (
                   &callback,
    gpointer       $user_data    = gpointer,
    GClosureNotify $destroy_data = GClosureNotify
  )
    is also<new-swap>
  {
    my $closure = g_cclosure_new_swap(&callback, $user_data, $destroy_data);

    $closure ?? self.bless( :$closure ) !! Nil;
  }

  method new_object (
    GObject() $object,
              &callback
  )
    is also<new-object>
  {
    my $closure = g_cclosure_new_object(&callback, $object);

    $closure ?? self.bless( :$closure ) !! Nil;
  }

  method new_signal_type (Int() $type, Int() $struct_offset)
    is also<new-signal-type>
  {
    my GType $t = $type;
    my guint $s = $struct_offset;

    my $closure = g_signal_type_cclosure_new($t, $s);

    $closure ?? self.bless(:$closure) !! Nil;
  }

  method marshal_generic (
    GValue() $return_gvalue,
    Int()    $n_param_values,
    GValue() $param_values,
    gpointer $invocation_hint,
    gpointer $marshal_data
  )
    is also<marshal-generic>
  {
    my guint $n = $n_param_values,
    g_cclosure_marshal_generic(
      self.GClosure,
      $return_gvalue,
      $n,
      $param_values,
      $invocation_hint,
      $marshal_data
    );
  }

}
