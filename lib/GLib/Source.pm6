use v6.c;

use Method::Also;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Raw::Main;

use GLib::MainContext;

use GLib::Roles::Implementor;

role GIdleId is export { ... }

class GLib::Source {
  has GSource $!gs is implementor handles<p>;

  submethod BUILD (GSource :$source, Int() :$attach = False) {
    self.setSource($source, :$attach) if $source;
  }

  submethod DESTROY {
    # What about removing it from attached Loops?
    self.unref;
  }

  method setSource(GSource $source, :$attach = False)
    is also<setGSource>
  {
    $!gs = $source;
  }

  method GLib::Raw::Definitions::GSource
    is also<GSource>
  { $!gs }

  multi method new (GSource $source, :$ref = True) {
    return Nil unless $source;

    my $o = self.bless(:$source);
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GSourceFuncs $source_funcs,
    Int()        $struct_size   = GSourceFuncs.size-of
  ) {
    my guint $ss = $struct_size;
    self.bless( source => g_source_new($source_funcs, $ss) );
  }

  method add_child_source (GSource() $child_source)
    is also<add-child-source>
  {
    g_source_add_child_source($!gs, $child_source);
  }

  method add_poll (GPollFD $fd) is also<add-poll> {
    g_source_add_poll($!gs, $fd);
  }

  method add_unix_fd (Int() $fd, Int() $events) is also<add-unix-fd> {
    my gint $f = $fd;
    my guint $e = $events;

    g_source_add_unix_fd($!gs, $fd, $e);
  }

  method attach (GMainContext() $context = GMainContext) {
    g_source_attach($!gs, $context);
  }

  method destroy {
    g_source_destroy($!gs);
  }

  method get_context is also<get-context> {
    GLib::MainContext.new( g_source_get_context($!gs) );
  }

  method get_id is also<get-id> {
    g_source_get_id($!gs);
  }

  method get_time is also<get-time> {
    g_source_get_time($!gs);
  }

  method is_destroyed is also<is-destroyed> {
    g_source_is_destroyed($!gs);
  }

  method modify_unix_fd (gpointer $tag, Int() $new_events)
    is also<modify-unix-fd>
  {
    my guint $ne = $new_events;
    g_source_modify_unix_fd($!gs, $tag, $ne);
  }

  method query_unix_fd (gpointer $tag) is also<query-unix-fd> {
    GIOConditionEnum( g_source_query_unix_fd($!gs, $tag) );
  }

  method ref {
    g_source_ref($!gs);
  }

  method remove_child_source (&child_source) is also<remove-child-source> {
    g_source_remove_child_source($!gs, &child_source);
  }

  method remove_poll (GPollFD() $fd) is also<remove-poll> {
    g_source_remove_poll($!gs, $fd);
  }

  method remove_unix_fd (gpointer $tag) is also<remove-unix-fd> {
    g_source_remove_unix_fd($!gs, $tag);
  }

  method set_callback (
    &func,
    gpointer       $data   = gpointer,
    GDestroyNotify $notify = gpointer
  )
    is also<set-callback>
  {
    g_source_set_callback($!gs, &func, $data, $notify);
  }

  method set_callback_indirect (
    gpointer             $callback_data,
    GSourceCallbackFuncs $callback_funcs
  )
    is also<set-callback-indirect>
  {
    g_source_set_callback_indirect($!gs, $callback_data, $callback_funcs);
  }

  method set_can_recurse (Int() $can_recurse) is also<set-can-recurse> {
    my gboolean $c = $can_recurse;

    g_source_set_can_recurse($!gs, $c);
  }

  method set_dispose_function (&dispose)
    is also<set-dispose-function>
  {
    g_source_set_dispose_function($!gs, &dispose);
  }

  method set_funcs (GSourceFuncs $funcs) is also<set-funcs> {
    g_source_set_funcs($!gs, $funcs);
  }

  method set_name (Str() $name) is also<set-name> {
    g_source_set_name($!gs, $name);
  }

  method set_name_by_id (
    Int() $source-id,
    Str() $name
  )
    is static
    is also<set-name-by-id>
  {
    my guint $s = $source-id;

    g_source_set_name_by_id($s, $name);
  }

  method set_priority (Int() $priority) {
    my gint $p = $priority;

    g_source_set_priority($!gs, $p);
  }

  method set_ready_time (Int() $ready_time) {
    my gint64 $r = $ready_time;

    g_source_set_ready_time($!gs, $ready_time);
  }

  method unref {
    g_source_unref($!gs);
  }

  method remove (Int() $tag) is static {
    my guint $t = $tag;

    g_source_remove($t);
  }

  method remove_by_funcs_user_data (
    GSourceFuncs    $funcs,
    gpointer        $user_data
  )
    is static
    is also<remove-by-funcs-user-data>
  {
    g_source_remove_by_funcs_user_data($funcs, $user_data);
  }

  method remove_by_user_data (
    gpointer        $user_data
  )
    is static
    is also<remove-by-user-data>
  {
    g_source_remove_by_user_data($user_data);
  }

  method idle_add (
                     &function,
    gpointer         $data      = gpointer,
    Str()           :$name      = Str
  )
    is static
    is also<idle-add>
  {
    my $id = g_idle_add(&function, $data);
    ::?CLASS.set_name_by_id($id, $name) if $name;
    $id but GIdleId;
  }

  multi method idle_add_full (
              &function,
    gpointer  $data      = gpointer,
              &notify    = %DEFAULT-CALLBACKS<GDestroyNotify>,
    Int()    :$priority  = G_PRIORITY_DEFAULT,
    Str()    :$name      = Str
  ) {
    samewith($priority, &function, $data, &notify, :$name);

  }
  multi method idle_add_full (
    Int()     $priority,
              &function,
    gpointer  $data      = gpointer,
              &notify    = %DEFAULT-CALLBACKS<GDestroyNotify>,
     Str()   :$name
  )
    is static
    is also<idle-add-full>
  {
    my $id = g_idle_add_full($priority, &function, $data, &notify);
    ::?CLASS.set_name_by_id($id, $name) if $name;
    $id but GIdleId;
  }

  method idle_remove_by_data (gpointer $data)
    is static
    is also<idle-remove-by-data>
  {
    g_idle_remove_by_data($data);
  }

}


class GLib::Source::Idle is GLib::Source {

  method new {
    my $source = g_idle_source_new();

    $source ?? self.bless( :$source ) !! Nil;
  }

}

role GIdleId {

  method cancel ( :$clear = False ) {
    GLib::Source.remove(self);
    self = 0 if $clear;
  }

}
