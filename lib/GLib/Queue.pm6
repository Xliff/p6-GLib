use v6.c;

use GLib::Raw::Types;
use GLib::Raw::Queue;

use GLib::GList;

class GLib::Queue {
  has GQueue $!q;

  submethod BUILD (:$queue) {
    $!q = $queue if $queue
  }

  method GLib::Raw::Structs::GQueue
  { $!q }

  multi method new (GQueue $queue) {
    $queue ?? self.bless( :$queue ) !! Nil;
  }
  multi method new {
    my $queue = g_queue_new();

    $queue ?? self.bless( :$queue ) !! Nil;
  }

  method clear {
    g_queue_clear($!q);
  }

  method clear_full (&free_func) {
    g_queue_clear_full($!q, &free_func);
  }

  method copy (:$raw = False) {
    my $q = g_queue_copy($!q);

    $q ??
      ( $raw ?? $q !! GLib::Queue.new($q) )
      !!
      Nil
  }

  method delete_link (GList() $link) {
    g_queue_delete_link($!q, $link);
  }

  method find (
    gpointer $data,
             :$glist = False,
             :$raw   = True,
             :$typed = gpointer
  ) {
    returnGList(
      g_queue_find($!q, $data),
      $glist,
      $raw,
      $typed
    );
  }

  method find_custom (
    gpointer $data,
             &func,
             :$glist = False,
             :$raw   = True,
             :$typed = gpointer
  ) {
    returnGList(
      g_queue_find_custom($!q, $data, &func),
      $glist,
      $raw,
      $typed
    );
  }

  method foreach (&func, gpointer $user_data) {

    g_queue_foreach($!q, &func, $user_data);
  }

  method free {
    g_queue_free($!q);
  }

  method free_full (&free_func) {
    g_queue_free_full($!q, &free_func);
  }

  method get_length {
    g_queue_get_length($!q);
  }

  method index (gpointer $data) {
    g_queue_index($!q, $data);
  }

  method init {
    g_queue_init($!q);
  }

  method insert_after (GList() $sibling, gpointer $data = gpointer) {
    g_queue_insert_after($!q, $sibling, $data);
  }

  method insert_after_link (GList() $sibling, GList() $link) {
    g_queue_insert_after_link($!q, $sibling, $link);
  }

  method insert_before (GList() $sibling, gpointer $data) {
    g_queue_insert_before($!q, $sibling, $data);
  }

  method insert_before_link (GList() $sibling, GList() $link) {
    g_queue_insert_before_link($!q, $sibling, $link);
  }

  method insert_sorted (
    gpointer $data,
             &func,
    gpointer $user_data = gpointer
  ) {
    g_queue_insert_sorted($!q, $data, &func, $user_data);
  }

  method is_empty {
    so g_queue_is_empty($!q);
  }

  method link_index (GList() $link) {
    g_queue_link_index($!q, $link);
  }

  method peek_head {
    g_queue_peek_head($!q);
  }

  method peek_head_link (:$glist = False, :$raw = True) {
    g_queue_peek_head_link($!q);
  }

  method peek_nth (Int() $n) {
    my guint $nn = $n;

    g_queue_peek_nth($!q, $nn);
  }

  method peek_nth_link (
    Int() $n,
          :$glist = False,
          :$raw   = True,
          :$typed = gpointer
  ) {
    my guint $nn = $n;

    returnGList(
      g_queue_peek_nth_link($!q, $nn),
      $glist,
      $raw,
      $typed
    );
  }

  method peek_tail {
    g_queue_peek_tail($!q);
  }

  method peek_tail_link (:$glist = False, :$raw = True, :$typed = gpointer) {
    returnGList(
      g_queue_peek_tail_link($!q),
      $glist,
      $raw,
      $typed
    );
  }

  method pop_head {
    g_queue_pop_head($!q);
  }

  method pop_head_link (:$glist = False, :$raw = True, :$typed = gpointer) {
    returnGList(
      g_queue_pop_head_link($!q),
      $glist,
      $raw,
      $typed
    );
  }

  method pop_nth (Int() $n) {
    my guint $nn = $n;

    g_queue_pop_nth($!q, $nn);
  }

  method pop_nth_link (Int() $n,
                             :$glist = False,
                             :$raw   = True,
                             :$typed = gpointer
  ) {
    my guint $nn = $n;

    returnGList(
      g_queue_pop_nth_link($!q, $nn),
      $glist,
      $raw,
      $typed
    )
  }

  method pop_tail {
    g_queue_pop_tail($!q);
  }

  method pop_tail_link {
    g_queue_pop_tail_link($!q);
  }

  method push_head (gpointer $data) {
    g_queue_push_head($!q, $data);
  }

  method push_head_link (GList() $link) {
    g_queue_push_head_link($!q, $link);
  }

  method push_nth (gpointer $data, Int() $n) {
    my guint $nn = $n;

    g_queue_push_nth($!q, $data, $nn);
  }

  method push_nth_link (Int() $n, GList() $link) {
    my guint $nn = $n;

    g_queue_push_nth_link($!q, $nn, $link);
  }

  method push_tail (gpointer $data) {
    g_queue_push_tail($!q, $data);
  }

  method push_tail_link (GList() $link) {
    g_queue_push_tail_link($!q, $link);
  }

  method remove (gpointer $data) {
    so g_queue_remove($!q, $data);
  }

  method remove_all (gpointer $data) {
    g_queue_remove_all($!q, $data);
  }

  method reverse {
    g_queue_reverse($!q);
  }

  method sort (&compare_func, gpointer $user_data = gpointer) {
    g_queue_sort($!q, &compare_func, $user_data);
  }

  method unlink (GList() $link) {
    g_queue_unlink($!q, $link);
  }

}
