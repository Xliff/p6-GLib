use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Main;

class GLib::MainLoop {
  has GMainLoop $!ml is implementor;

  submethod BUILD (:$mainloop) {
    $!ml = $mainloop;
  }

  method GLib::Raw::Types::GMainLoop
    is also<
      GMainLoop
      MainLoop
    >
  { $!ml }

  multi method new (Int() $is_running) {
    samewith(GMainContext, $is_running);
  }
  multi method new (
    GMainContext() $context, Int() $is_running) {
    my gboolean $ir = $is_running;

    self.bless( mainloop => g_main_loop_new($context, $ir) );
  }
  multi method new {
    samewith(GMainContext, False);
  }

  method get_context is also<get-context> {
    g_main_loop_get_context($!ml);
  }

  method is_running is also<is-running> {
    g_main_loop_is_running($!ml);
  }

  method quit {
    g_main_loop_quit($!ml);
  }

  method ref {
    g_main_loop_ref($!ml);
  }

  method run {
    g_main_loop_run($!ml);
  }

  method unref {
    g_main_loop_unref($!ml);
  }

  method poll (gpointer $fds, Int() $nfds, Int() $timeout) {
    my guint $nf = $nfds;
    my gint $t = $timeout;

    g_poll($fds, $nf, $t);
  }

}
