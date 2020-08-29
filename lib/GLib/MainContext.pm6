use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Main;

use GLib::Roles::TypedBuffer;

class GLib::MainContext {
  has GMainContext $!mc;

  submethod BUILD (:$maincontext) {
    $!mc = $maincontext;
  }

  method GLib::Raw::Definitions::GMainContext
    is also<
      GMainContext
      MainContext
    >
  { $!mc }

  multi method new (GMainContext $maincontext) {
    $maincontext ?? self.bless( :$maincontext ) !! Nil;
  }
  multi method new {
    my $maincontext = g_main_context_new();

    $maincontext ?? self.bless( :$maincontext ) !! Nil;
  }

  method acquire {
    g_main_context_acquire($!mc);
  }

  method add_poll (GPollFD $fd, Int() $priority) is also<add-poll> {
    my gint $p = $priority;

    g_main_context_add_poll($!mc, $fd, $p);
  }

  multi method check (
    Int() $max_priority,
    @fds,
  ) {
    my $f = GLib::Roles::TypedBuffer[GPollFD].new(@fds);

    samewith($max_priority, $f.p, @fds.elems);
  }
  multi method check (
   Int() $max_priority,
   gpointer $fds,           # Block of GPollFD
   Int() $n_fds
 ) {
    my gint ($mp, $nf) = ($max_priority, $n_fds);

    g_main_context_check($!mc, $mp, $fds, $nf);
    my $fdb = GLib::Roles::TypedBuffer[GPollFD].new-typedbuffer-obj($fds);
    $fdb.Array;
  }

  method default {
    g_main_context_default();
  }

  method dispatch {
    g_main_context_dispatch($!mc);
  }

  method find_source_by_funcs_user_data (
    GSourceFuncs $funcs,
    gpointer $user_data = gpointer
  )
    is also<find-source-by-funcs-user-data>
  {
    g_main_context_find_source_by_funcs_user_data($!mc, $funcs, $user_data);
  }

   method find_source_by_id (Int() $source_id) is also<find-source-by-id> {
     my guint $sid = $source_id;

     g_main_context_find_source_by_id($!mc, $sid);
   }

   method find_source_by_user_data (gpointer $user_data = gpointer)
     is also<find-source-by-user-data>
   {
     g_main_context_find_source_by_user_data($!mc, $user_data);
   }

   method get_thread_default is also<get-thread-default> {
    g_main_context_get_thread_default();
  }

  method invoke (&function, gpointer $data = gpointer) {
    g_main_context_invoke($!mc, &function, $data);
  }

  method invoke_full (
    Int() $priority,
    &function,
    gpointer $data         = gpointer,
    GDestroyNotify $notify = gpointer
  )
    is also<invoke-full>
  {
    my gint $p = $priority;

    g_main_context_invoke_full($!mc, $p, &function, $data, $notify);
  }

  method is_owner is also<is-owner> {
    g_main_context_is_owner($!mc);
  }

  multi method iteration (
    GLib::MainContext:U:
  ) {
    GLib::MainContext.iteration(GMainContext);
  }
  multi method iteration (Int() $may_block = True) {
    GLib::MainContext.iteration($!mc, $may_block);
  }
  multi method iteration (
    GLib::MainContext:U:
    GMainContext $context = GMainContext,
    Int() $may_block = True
  ) {
    my gboolean $mb = $may_block.so.Int;

    g_main_context_iteration($context, $mb);
  }

  method pending {
    so g_main_context_pending($!mc);
  }

  method pop_thread_default is also<pop-thread-default> {
    g_main_context_pop_thread_default($!mc);
  }

  method prepare (Int() $priority) {
    my gint $p = $priority;

    g_main_context_prepare($!mc, $priority);
  }

  method push_thread_default is also<push-thread-default> {
    g_main_context_push_thread_default($!mc);
  }

  multi method query (
    Int() $max_priority,
    Int() $n_fds
  ) {
    my gpointer $fds = calloc(nativesizeof(GPollFD), $n_fds);

    samewith($max_priority, $, $, $n_fds);
  }
  multi method query (
    Int() $max_priority,
    $timeout is rw,
    $fds is rw,           # Block of GPollFD
    Int() $n_fds
  ) {
    my gint ($mp, $to, $nf) = ($max_priority, 0, $n_fds);
    my gpointer $f = GLib::Roles::TypedBuffer[GPollFD].new( size => $nf );
    my $rv = g_main_context_query($!mc, $mp, $to, $f.p, $nf);

    ($rv, $to, $f.Array);
  }

  method ref is also<upref> {
    g_main_context_ref($!mc);
    self;
  }

  method ref_thread_default is also<ref-thread-default> {
    g_main_context_ref_thread_default();
  }

  method release {
    g_main_context_release($!mc);
  }

  method remove_poll (GPollFD $fd) is also<remove-poll> {
    g_main_context_remove_poll($!mc, $fd);
  }

  method unref is also<downref> {
    g_main_context_unref($!mc);
  }

  method wakeup {
    g_main_context_wakeup($!mc);
  }

}
