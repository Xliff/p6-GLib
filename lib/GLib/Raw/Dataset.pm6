use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

unit package GLib::Raw::Dataset;

### /usr/src/glib2.0-2.68.4/glib/gdataset.h

sub g_dataset_destroy (gpointer $dataset_location)
  is      native(glib)
  is      export
{ * }

sub g_dataset_foreach (
  gpointer         $dataset_location,
                   &func (GQuark, gpointer, gpointer),
  gpointer         $user_data
)
  is      native(glib)
  is      export
{ * }

sub g_datalist_clear (CArray[GData] $datalist)
  is      native(glib)
  is      export
{ * }

sub g_datalist_foreach (
  CArray[GData]    $datalist,
                   &func (GQuark, gpointer, gpointer),
  gpointer         $user_data
)
  is      native(glib)
  is      export
{ * }

sub g_datalist_get_data (
  CArray[GData] $datalist,
  Str           $key
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_datalist_get_flags (CArray[GData] $datalist)
  returns guint
  is      native(glib)
  is      export
{ * }

sub g_datalist_id_dup_data (
  CArray[GData]  $datalist,
  GQuark         $key_id,
                 &dup_func (gpointer, gpointer --> gpointer),
  gpointer       $user_data
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_datalist_id_get_data (
  CArray[GData] $datalist,
  GQuark        $key_id
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_datalist_id_remove_no_notify (
  CArray[GData] $datalist,
  GQuark        $key_id
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_datalist_id_replace_data (
  CArray[GData]  $datalist,
  GQuark         $key_id,
  gpointer       $oldval,
  gpointer       $newval,
  GDestroyNotify $destroy,
  GDestroyNotify $old_destroy
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_datalist_id_set_data_full (
  CArray[GData]  $datalist,
  GQuark         $key_id,
  gpointer       $data,
  GDestroyNotify $destroy_func
)
  is      native(glib)
  is      export
{ * }

sub g_datalist_init (CArray[GData] $datalist)
  is      native(glib)
  is      export
{ * }

sub g_datalist_set_flags (
  CArray[GData] $datalist,
  guint         $flags
)
  is      native(glib)
  is      export
{ * }

sub g_datalist_unset_flags (
  CArray[GData] $datalist,
  guint         $flags
)
  is      native(glib)
  is      export
{ * }

sub g_dataset_id_get_data (
  gpointer      $dataset_location,
  GQuark        $key_id
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_dataset_id_remove_no_notify (
  gpointer      $dataset_location,
  GQuark        $key_id
)
  returns Pointer
  is      native(glib)
  is      export
{ * }

sub g_dataset_id_set_data_full (
  gpointer       $dataset_location,
  GQuark         $key_id,
  gpointer       $data,
  GDestroyNotify $destroy_func
)
  is      native(glib)
  is      export
{ * }
