use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Raw::Queue;

### /usr/include/glib-2.0/glib/gqueue.h

sub g_queue_clear (GQueue $queue)
  is native(glib)
  is export
{ * }

sub g_queue_clear_full (
  GQueue $queue,
         &free_func (Pointer)
)
  is native(glib)
  is export
{ * }

sub g_queue_copy (GQueue $queue)
  returns GQueue
  is native(glib)
  is export
{ * }

sub g_queue_delete_link (GQueue $queue, GList $link_)
  is native(glib)
  is export
{ * }

sub g_queue_find (GQueue $queue, Pointer $data)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_find_custom (
  GQueue  $queue,
  Pointer $data,
          &compare_func (Pointer, Pointer --> gboolean)
)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_foreach (
  GQueue   $queue,
  Pointer, # GFunc $func,
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_queue_free (GQueue $queue)
  is native(glib)
  is export
{ * }

sub g_queue_free_full (
  GQueue $queue,
         &free_func (Pointer)
)
  is native(glib)
  is export
{ * }

sub g_queue_get_length (GQueue $queue)
  returns guint
  is native(glib)
  is export
{ * }

sub g_queue_index (GQueue $queue, Pointer $data)
  returns gint
  is native(glib)
  is export
{ * }

sub g_queue_init (GQueue $queue)
  is native(glib)
  is export
{ * }

sub g_queue_insert_after (GQueue $queue, GList $sibling, gpointer $data)
  is native(glib)
  is export
{ * }

sub g_queue_insert_after_link (GQueue $queue, GList $sibling, GList $link)
  is native(glib)
  is export
{ * }

sub g_queue_insert_before (GQueue $queue, GList $sibling, gpointer $data)
  is native(glib)
  is export
{ * }

sub g_queue_insert_before_link (GQueue $queue, GList $sibling, GList $link)
  is native(glib)
  is export
{ * }

sub g_queue_insert_sorted (
  GQueue   $queue,
  gpointer $data,
           &compare_func (Pointer, Pointer, Pointer --> gboolean),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_queue_is_empty (GQueue $queue)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_queue_link_index (GQueue $queue, GList $link_)
  returns gint
  is native(glib)
  is export
{ * }

sub g_queue_new ()
  returns GQueue
  is native(glib)
  is export
{ * }

sub g_queue_peek_head (GQueue $queue)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_peek_head_link (GQueue $queue)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_peek_nth (GQueue $queue, guint $n)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_peek_nth_link (GQueue $queue, guint $n)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_peek_tail (GQueue $queue)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_peek_tail_link (GQueue $queue)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_pop_head (GQueue $queue)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_pop_head_link (GQueue $queue)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_pop_nth (GQueue $queue, guint $n)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_pop_nth_link (GQueue $queue, guint $n)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_pop_tail (GQueue $queue)
  returns Pointer
  is native(glib)
  is export
{ * }

sub g_queue_pop_tail_link (GQueue $queue)
  returns GList
  is native(glib)
  is export
{ * }

sub g_queue_push_head (GQueue $queue, gpointer $data)
  is native(glib)
  is export
{ * }

sub g_queue_push_head_link (GQueue $queue, GList $link_)
  is native(glib)
  is export
{ * }

sub g_queue_push_nth (GQueue $queue, gpointer $data, gint $n)
  is native(glib)
  is export
{ * }

sub g_queue_push_nth_link (GQueue $queue, gint $n, GList $link)
  is native(glib)
  is export
{ * }

sub g_queue_push_tail (GQueue $queue, gpointer $data)
  is native(glib)
  is export
{ * }

sub g_queue_push_tail_link (GQueue $queue, GList $link)
  is native(glib)
  is export
{ * }

sub g_queue_remove (GQueue $queue, Pointer $data)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_queue_remove_all (GQueue $queue, Pointer $data)
  returns guint
  is native(glib)
  is export
{ * }

sub g_queue_reverse (GQueue $queue)
  is native(glib)
  is export
{ * }

sub g_queue_sort (
  GQueue   $queue,
           &compare_func (Pointer, Pointer, Pointer --> gboolean),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_queue_unlink (GQueue $queue, GList $link_)
  is native(glib)
  is export
{ * }
