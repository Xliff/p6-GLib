use v6.c;

use GLib::Raw::Types;
use GLib::Raw::Node;

class GLib::Node {
  has GNode $!n is implementor handles<data next prev children parent>;

  submethod BUILD (:$node) {
    $!n = $node;
  }

  method GLib::Raw::Structs::GNode
  { $!n }

  multi method new (GNode $node) {
    $node ?? self.bless( :$node ) !! Nil;
  }
  multi method new (gpointer $data = gpointer) {
    my $node = g_node_new($data);

    $node ?? self.bless( :$node ) !! Nil;
  }

  method child_index (gpointer $data) {
    g_node_child_index($!n, $data);
  }

  method child_position (GNode $child) {
    g_node_child_position($!n, $child);
  }

  proto method children_foreach (|)
  { * }

  multi method children_foreach(
             &func,
    gpointer $data   = gpointer,
             :$flags = 0
  ) {
    samewith($flags, &func, $data);
  }
  multi method children_foreach (Int() $flags, &func, gpointer $data = gpointer) {
    my GTraverseFlags $f = $flags;

    g_node_children_foreach($!n, $f, &func, $data);
  }

  method copy ( :$raw = False ) {
    my $c = g_node_copy($!n);

    $c ??
      ( $raw ?? $c !! GLib::Node.new($c) )
      !!
      Nil;
  }

  method copy_deep (&copy_func, gpointer $data = gpointer, :$raw = False) {
    my $c = g_node_copy_deep($!n, &copy_func, $data);

    $c ??
      ( $raw ?? $c !! GLib::Node.new($c) )
      !!
      Nil;
  }

  method depth {
    g_node_depth($!n);
  }

  method destroy {
    g_node_destroy($!n);
  }

  # cw: $data does not take a default, here
  method find (
    Int()    $order,
    Int()    $flags,
    gpointer $data,
             :$raw = False
  ) {
    my GTraverseType  $o = $order;
    my GTraverseFlags $f = $flags;

    my $fn = g_node_find($!n, $order, $flags, $data);

    $fn ??
      ( $raw ?? $fn !! GLib::Node.new($fn) )
      !!
      Nil;
  }


  # cw: $data does not take a default, here
  method find_child (Int() $flags, gpointer $data, :$raw = False) {
    my GTraverseFlags $f  = $flags;
    my                $fn = g_node_find_child($!n, $f, $data);

    $fn ??
      ( $raw ?? $fn !! GLib::Node.new($fn) )
      !!
      Nil;
  }

  method first_sibling (:$raw = False) {
    my $n = g_node_first_sibling($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method get_root (:$raw = False) {
    my $n = g_node_get_root($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert (Int() $position, GNode() $node, :$raw = False) {
    my gint $p = $position;
    my      $n = g_node_insert($!n, $position, $node);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert_after (GNode() $sibling, GNode() $node, :$raw = False) {
    my $n = g_node_insert_after($!n, $sibling, $node);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert_before (GNode() $sibling, GNode() $node, :$raw = False) {
    my $n = g_node_insert_before($!n, $sibling, $node);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method is_ancestor (GNode() $descendant) {
    so g_node_is_ancestor($!n, $descendant);
  }

  method last_child (:$raw = False) {
    my $n = g_node_last_child($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method last_sibling (:$raw = False) {
    my $n = g_node_last_sibling($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method max_height {
    g_node_max_height($!n);
  }

  method n_children {
    g_node_n_children($!n);
  }

  method n_nodes (Int() $flags) {
    my GTraverseFlags $f = $flags;

    g_node_n_nodes($!n, $flags);
  }

  method nth_child (Int() $nth, :$raw = False) {
    my guint $nn = $nth;
    my       $n  = g_node_nth_child($!n, $nn);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method prepend (GNode() $node, :$raw = False) {
    my $n = g_node_prepend($!n, $node);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method reverse_children (:$raw = False) {
    my $n = g_node_reverse_children($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  multi method traverse (
             &func,
    gpointer $data       = gpointer,
    Int()    :$order,
    Int()    :$flags,
    Int()    :$max_depth
  ) {
    samewith($order, $flags, $max_depth, &func, $data);
  }
  multi method traverse (
    Int()    $order,
    Int()    $flags,
    Int()    $max_depth,
             &func,
    gpointer $data       = gpointer
  ) {
    my GTraverseType  $o  = $order;
    my GTraverseFlags $f  = $flags;
    my gint           $md = $max_depth;

    g_node_traverse($!n, $order, $flags, $max_depth, &func, $data);
  }

  method unlink {
    g_node_unlink($!n);
  }

  method append (GNode() $node, :$raw = False) {
    my $n = g_node_append($node);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert_data (Int() $pos, gpointer $data, :$raw = False) {
    my $n = g_node_insert_data($!n, $pos, $data);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert_data_after (GNode() $sibling, gpointer $data, :$raw = False) {
    my $n = g_node_insert_data_after($!n, $sibling, $data);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method insert_data_before (GNode() $sibling, gpointer $data, :$raw = False) {
    my $n = g_node_insert_data_before($!n, $sibling, $data);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method prepend_data (GNode() $parent, gpointer $data, :$raw = False) {
    my $n = g_node_prepend_data($!n, $parent, $data);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method append_data (GNode() $parent, gpointer $data, :$raw = False) {
    my $n = g_node_append_data($!n, $parent, $data);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method prev_sibling (:$raw = False) {
    my $n = g_node_prev_sibling($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method next_sibling (:$raw = False) {
    my $n = g_node_next_sibling($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

  method first_child (:$raw = False) {
    my $n = g_node_first_child($!n);

    $n ??
      ( $raw ?? $n !! GLib::Node.new($n) )
      !!
      Nil;
  }

}
