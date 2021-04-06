use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Raw::Node;

### /usr/include/glib-2.0/glib/gnode.h

sub g_node_child_index (GNode $node, gpointer $data)
  returns gint
  is native(glib)
  is export
{ * }

sub g_node_child_position (GNode $node, GNode $child)
  returns gint
  is native(glib)
  is export
{ * }

sub g_node_children_foreach (
  GNode          $node,
  GTraverseFlags $flags,
                 &func (GNode, gpointer),
  gpointer       $data
)
  is native(glib)
  is export
{ * }

sub g_node_copy (GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_copy_deep (GNode $node, GCopyFunc $copy_func, gpointer $data)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_depth (GNode $node)
  returns guint
  is native(glib)
  is export
{ * }

sub g_node_destroy (GNode $root)
  is native(glib)
  is export
{ * }

sub g_node_find (
  GNode          $root,
  GTraverseType  $order,
  GTraverseFlags $flags,
  gpointer       $data
)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_find_child (GNode $node, GTraverseFlags $flags, gpointer $data)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_first_sibling (GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_get_root (GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_insert (GNode $parent, gint $position, GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_insert_after (GNode $parent, GNode $sibling, GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_insert_before (GNode $parent, GNode $sibling, GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_is_ancestor (GNode $node, GNode $descendant)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_node_last_child (GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_last_sibling (GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_max_height (GNode $root)
  returns guint
  is native(glib)
  is export
{ * }

sub g_node_n_children (GNode $node)
  returns guint
  is native(glib)
  is export
{ * }

sub g_node_n_nodes (GNode $root, GTraverseFlags $flags)
  returns guint
  is native(glib)
  is export
{ * }

sub g_node_new (gpointer $data)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_nth_child (GNode $node, guint $n)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_prepend (GNode $parent, GNode $node)
  returns GNode
  is native(glib)
  is export
{ * }

sub g_node_reverse_children (GNode $node)
  is native(glib)
  is export
{ * }

sub g_node_traverse (
  GNode          $root,
  GTraverseType  $order,
  GTraverseFlags $flags,
  gint           $max_depth,
                 &func (GNode, gpointer --> gboolean),
  gpointer       $data
)
  is native(glib)
  is export
{ * }

sub g_node_unlink (GNode $node)
  is native(glib)
  is export
{ * }

sub g_node_append (GNode $parent, GNode $node) is export {
  g_node_insert_before($parent, GNode, $node);
}

sub g_node_insert_data (GNode $parent, Int() $pos, gpointer $data) is export {
  my gint $p = $pos;

  g_node_insert( $parent, $p, g_node_new($data) )
}

sub g_node_insert_data_after (GNode $parent, GNode $sibling, gpointer $data)
  is export
{
  g_node_insert_after( $parent, $sibling, g_node_new($data) );
}

sub g_node_insert_data_before (GNode $parent, GNode $sibling, gpointer $data)
  is export
{
  g_node_insert_before( $parent, $sibling, g_node_new($data) );
}

sub g_node_prepend_data (GNode $parent, gpointer $data) {
  g_node_prepend( $parent, GNode, g_node_new($data) )
}

sub g_node_append_data (GNode $parent, gpointer $data) {
  g_node_insert_before( $parent, GNode, g_node_new($data) );
}

sub g_node_prev_sibling (GNode $node) is export
  { $node ? $node.prev !! Nil }

sub g_node_next_sibling (GNode $node) is export
  { $node ? $node.next !! Nil }

sub g_node_first_child  (GNode $node) is export
  { $node ? $node.children !! Nil }
