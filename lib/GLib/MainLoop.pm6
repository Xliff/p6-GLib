use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Main;

class GLib::MainLoop {
  has GMainLoop $!ml is implementor handles<p>;

  submethod BUILD (:$mainloop) {
    $!ml = $mainloop;
  }

  method GLib::Raw::Definitions::GMainLoop
    is also<
      GMainLoop
      MainLoop
    >
  { $!ml }

  multi method new (GMainLoop $mainloop) {
    $mainloop ?? self.bless( :$mainloop ) !! Nil;
  }
  multi method new (Int() $is_running = False) {
    samewith(GMainContext, $is_running);
  }
  multi method new (
    GMainContext() $context,
    Int()          $is_running
  ) {
    my gboolean $ir       = $is_running;
    my          $mainloop = g_main_loop_new($context, $ir);

    $mainloop ?? self.bless( :$mainloop ) !! Nil;
  }

  method get_context
    is also<
      get-context
      context
    >
  {
    g_main_loop_get_context($!ml);
  }

  method is_running is also<is-running> {
    so g_main_loop_is_running($!ml);
  }

  method quit {
    g_main_loop_quit($!ml);
  }

  method ref {
    g_main_loop_ref($!ml);
    self;
  }

  method run {
    g_main_loop_run($!ml);
  }

  method unref {
    g_main_loop_unref($!ml);
  }

  multi method poll (@fds, Int() $timeout) {
    samewith(
      GLib::Roles::TypedBuffer[GPollFD].new(@fds).p,
      @fds.elems,
      $timeout
    );
  }
  multi method poll (gpointer $fds, Int() $nfds, Int() $timeout) {
    my guint $nf = $nfds;
    my gint $t = $timeout;

    g_poll($fds, $nf, $t);
  }

  method child_watch_add (
    GPid $pid,
    &func,
    gpointer $data = gpointer
  )
    is also<child-watch-add>
  {
    my GPid $p = $pid;

    g_child_watch_add ($pid, &func, $data);
  }

  method child_watch_add_full (
    Int() $priority,
    Int() $pid,
    &func,
    gpointer       $data   = gpointer,
    GDestroyNotify $notify = gpointer
  )
    is also<child-watch-add-full>
  {
    my gint $p = $priority;
    my GPid $pp = $pid;

    g_child_watch_add_full ($p, $pp, &func, $data, $notify);
  }

}

### /usr/include/glib-2.0/glib/gpoll.h

sub g_poll (gpointer $fds, guint $nfds, gint $timeout)
  returns gint
  is native(glib)
  is export
{ * }
