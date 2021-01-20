use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Sequence;

class GLib::Sequence::Iter { ... }

class GLib::Sequence {
  has GSequence $!s is implementor handles<p>;

  submethod BUILD (:$sequence) {
    $!s = $sequence;
  }

  method GLib::Raw::Definitions::GSequence
    is also<GSequence>
  { $!s }

  multi method new (GSequence $sequence) {
    $sequence ?? self.bless( :$sequence ) !! Nil;
  }
  multi method new (GDestroyNotify $notify = gpointer) {
    my $sequence = g_sequence_new($notify);

    $sequence ?? self.bless( :$sequence ) !! Nil;
  }

  method append (gpointer $data, :$raw = False) {
    my $i = g_sequence_append($!s, $data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method foreach (&func, gpointer $user_data = gpointer) {
    g_sequence_foreach($!s, &func, $user_data);
  }

  method foreach_range (
    GLib::Sequence:U:
    GSequenceIter() $start,
    GSequenceIter() $end,
    &func,
    gpointer $user_data = gpointer
  )
    is also<foreach-range>
  {
    g_sequence_foreach_range($start, $end, &func, $user_data);
  }

  method free {
    g_sequence_free($!s);
  }

  method get_begin_iter (:$raw = False) is also<get-begin-iter> {
    my $i = g_sequence_get_begin_iter($!s);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method get_end_iter (:$raw = False) is also<get-end-iter> {
    my $i = g_sequence_get_end_iter($!s);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method get_iter_at_pos (Int() $pos, :$raw = False) is also<get-iter-at-pos> {
    my gint $p = $pos;
    my $i = g_sequence_get_iter_at_pos($!s, $p);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method get_length is also<get-length> {
    g_sequence_get_length($!s);
  }

  method insert_sorted (
    gpointer $data,
    &cmp_func,
    gpointer $cmp_data = gpointer,
    :$raw = False
  )
    is also<insert-sorted>
  {
    my $i = g_sequence_insert_sorted($!s, $data, &cmp_func, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method insert_sorted_iter (
    gpointer $data,
    &iter_cmp,
    gpointer $cmp_data = gpointer,
    :$raw = False
  )
    is also<insert-sorted-iter>
  {
    my $i = g_sequence_insert_sorted_iter($!s, $data, &iter_cmp, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method is_empty is also<is-empty> {
    so g_sequence_is_empty($!s);
  }

  method lookup (
    gpointer $data,
    &cmp_func,
    gpointer $cmp_data = gpointer,
    :$raw = False
  ) {
    my $i = g_sequence_lookup($!s, $data, &cmp_func, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method lookup_iter (
    gpointer $data,
    &iter_cmp,
    gpointer $cmp_data = gpointer,
    :$raw = False
  )
    is also<lookup-iter>
  {
    my $i = g_sequence_lookup_iter($!s, $data, &iter_cmp, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method prepend (gpointer $data, :$raw = False) {
    my $i = g_sequence_prepend($!s, $data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method range_get_midpoint (
    GLib::Sequence:U:
    GSequenceIter() $begin,
    GSequenceIter() $end,
    :$raw = False
  )
    is also<
      range-get-midpoint
      get_midpoint
      get-midpoint
    >
  {
    my $i = g_sequence_range_get_midpoint($begin, $end);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method remove_range (
    GLib::Sequence:U:
    GSequenceIter() $begin,
    GSequenceIter() $end
  )
    is also<remove-range>
  {
    g_sequence_remove_range($begin, $end);
  }

  method search (
    gpointer $data,
    &cmp_func,
    gpointer $cmp_data = gpointer,
    :$raw = False
  ) {
    my $i = g_sequence_search($!s, $data, &cmp_func, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method search_iter (
    gpointer $data,
    &iter_cmp,
    gpointer $cmp_data = gpointer,
    :$raw = False
  )
    is also<search-iter>
  {
    my $i = g_sequence_search_iter($!s, $data, &iter_cmp, $cmp_data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method sort (&cmp_func, gpointer $cmp_data = gpointer) {
    g_sequence_sort($!s, &cmp_func, $cmp_data);
  }

  method sort_changed (&cmp_func, gpointer $cmp_data = gpointer)
    is also<sort-changed>
  {
    g_sequence_sort_changed($!s, &cmp_func, $cmp_data);
  }

  method sort_changed_iter (&iter_cmp, gpointer $cmp_data = gpointer)
    is also<sort-changed-iter>
  {
    g_sequence_sort_changed_iter($!s, &iter_cmp, $cmp_data);
  }

  method sort_iter (&cmp_func, gpointer $cmp_data = gpointer)
    is also<sort-iter>
  {
    g_sequence_sort_iter($!s, &cmp_func, $cmp_data);
  }

  method swap (
    GLib::Sequence:U:
    GSequenceIter() $a,
    GSequenceIter() $b
  ) {
    g_sequence_swap($a, $b);
  }

}


class GLib::Sequence::Iter {
  has GSequenceIter $!si;

  submethod BUILD (:$iter) {
    $!si = $iter;
  }

  method GLib::Raw::Definitions::GSequenceIter
    is also<GSequenceIter>
  { $!si }

  method new (GSequenceIter $iter) {
    $iter ?? self.bless( :$iter ) !! Nil;
  }

  method compare (GSequenceIter $b) {
    so g_sequence_iter_compare($!si, $b);
  }

  method get {
    g_sequence_get($!si);
  }

  method get_position is also<get-position> {
    g_sequence_iter_get_position($!si);
  }

  method get_sequence (:$raw = False) is also<get-sequence> {
    my $s = g_sequence_iter_get_sequence($!si);

    $s ??
      ( $raw ?? $s !! GStreamer::Sequence.new($s) )
      !!
      Nil;
  }

  method insert_before (gpointer $data, :$raw = False) is also<insert-before> {
    my $i = g_sequence_insert_before($!si, $data);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method is_begin is also<is-begin> {
    so g_sequence_iter_is_begin($!si);
  }

  method is_end is also<is-end> {
    so g_sequence_iter_is_end($!si);
  }

  method move_delta (Int() $delta, :$raw = False) is also<move-delta> {
    my gint $d = $delta;
    my $i = g_sequence_iter_move($!si, $d);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method move (GSequenceIter() $dest) {
    g_sequence_move($!si, $dest);
  }

  method move_range (GSequenceIter() $begin, GSequenceIter() $end)
    is also<move-range>
  {
    g_sequence_move_range($!si, $begin, $end);
  }

  method next (:$raw = False) {
    my $i = g_sequence_iter_next($!si);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method prev (:$raw = False) {
    my $i = g_sequence_iter_prev($!si);

    $i ??
      ( $raw ?? $i !! GLib::Sequence::Iter.new($i) )
      !!
      Nil;
  }

  method remove {
    g_sequence_remove($!si);
  }

  method set (gpointer $data) {
    g_sequence_set($!si, $data);
  }

  method swap (GSequenceIter() $b) {
    g_sequence_swap($!si, $b);
  }

}
