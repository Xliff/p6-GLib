use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

unit package GLib::Raw::Sequence;

### /usr/include/glib-2.0/glib/gsequence.h

sub g_sequence_append (GSequence $seq, gpointer $data)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_foreach (
  GSequence $seq,
  &func (Pointer, Pointer),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_foreach_range (
  GSequenceIter $begin,
  GSequenceIter $end,
  &func (Pointer, Pointer),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_free (GSequence $seq)
  is native(glib)
  is export
{ * }

sub g_sequence_get (GSequenceIter $iter)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_sequence_get_begin_iter (GSequence $seq)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_get_end_iter (GSequence $seq)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_get_iter_at_pos (GSequence $seq, gint $pos)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_get_length (GSequence $seq)
  returns gint
  is native(glib)
  is export
{ * }

sub g_sequence_insert_before (GSequenceIter $iter, gpointer $data)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_insert_sorted (
  GSequence $seq,
  gpointer $data,
  &func (Pointer, Pointer, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_insert_sorted_iter (
  GSequence $seq,
  gpointer $data,
  &cmp_func (GSequenceIter, GSequenceIter, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_is_empty (GSequence $seq)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_sequence_iter_compare (GSequenceIter $a, GSequenceIter $b)
  returns gint
  is native(glib)
  is export
{ * }

sub g_sequence_iter_get_position (GSequenceIter $iter)
  returns gint
  is native(glib)
  is export
{ * }

sub g_sequence_iter_get_sequence (GSequenceIter $iter)
  returns GSequence
  is native(glib)
  is export
{ * }

sub g_sequence_iter_is_begin (GSequenceIter $iter)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_sequence_iter_is_end (GSequenceIter $iter)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_sequence_iter_move (GSequenceIter $iter, gint $delta)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_iter_next (GSequenceIter $iter)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_iter_prev (GSequenceIter $iter)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_lookup (
  GSequence $seq,
  gpointer $data,
  &cmp_func (Pointer, Pointer, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_lookup_iter (
  GSequence $seq,
  gpointer $data,
  &cmp_func (GSequenceIter, GSequenceIter, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_move (GSequenceIter $src, GSequenceIter $dest)
  is native(glib)
  is export
{ * }

sub g_sequence_move_range (
  GSequenceIter $dest,
  GSequenceIter $begin,
  GSequenceIter $end
)
  is native(glib)
  is export
{ * }

sub g_sequence_new (GDestroyNotify $data_destroy)
  returns GSequence
  is native(glib)
  is export
{ * }

sub g_sequence_prepend (GSequence $seq, gpointer $data)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_range_get_midpoint (GSequenceIter $begin, GSequenceIter $end)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_remove (GSequenceIter $iter)
  is native(glib)
  is export
{ * }

sub g_sequence_remove_range (GSequenceIter $begin, GSequenceIter $end)
  is native(glib)
  is export
{ * }

sub g_sequence_search (
  GSequence $seq,
  gpointer $data,
  &cmp_func (Pointer, Pointer, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_search_iter (
  GSequence $seq,
  gpointer $data,
  &cmp_func (GSequenceIter, GSequenceIter, Pointer --> gint),
  gpointer $cmp_data
)
  returns GSequenceIter
  is native(glib)
  is export
{ * }

sub g_sequence_set (GSequenceIter $iter, gpointer $data)
  is native(glib)
  is export
{ * }

sub g_sequence_sort (
  GSequence $seq,
  &cmp_func (Pointer, Pointer, Pointer --> gint),
  gpointer $cmp_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_sort_changed (
  GSequenceIter $iter,
  &cmp_func (Pointer, Pointer, Pointer --> gint),
  gpointer $cmp_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_sort_changed_iter (
  GSequenceIter $iter,
  &cmp_func (GSequenceIter, GSequenceIter, Pointer --> gint),
  gpointer $cmp_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_sort_iter (
  GSequence $seq,
  &cmp_func (GSequenceIter, GSequenceIter, Pointer --> gint),
  gpointer $cmp_data
)
  is native(glib)
  is export
{ * }

sub g_sequence_swap (GSequenceIter $a, GSequenceIter $b)
  is native(glib)
  is export
{ * }
