use v6.c;

use NativeCall;

use GLib::Raw::Types;

unit package GLib::Raw::KeyFile;

### /usr/src/glib2.0-2.68.4/glib/gkeyfile.h

sub g_key_file_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_key_file_free (GKeyFile $key_file)
  is native(glib)
  is export
{ * }

sub g_key_file_get_boolean (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_get_boolean_list (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[uint32]
  is native(glib)
  is export
{ * }

sub g_key_file_get_comment (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_get_double (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns gdouble
  is native(glib)
  is export
{ * }

sub g_key_file_get_double_list (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[gdouble]
  is native(glib)
  is export
{ * }

sub g_key_file_get_groups (GKeyFile $key_file, gsize $length)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_key_file_get_int64 (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns gint64
  is native(glib)
  is export
{ * }

sub g_key_file_get_integer (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns gint
  is native(glib)
  is export
{ * }

sub g_key_file_get_integer_list (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[gint]
  is native(glib)
  is export
{ * }

sub g_key_file_get_keys (
  GKeyFile                $key_file,
  Str                     $group_name,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_key_file_get_locale_for_key (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  Str      $locale
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_get_locale_string (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  Str                     $locale,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_get_locale_string_list (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  Str                     $locale,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_key_file_get_start_group (GKeyFile $key_file)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_get_string (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_get_string_list (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  gsize                   $length      is rw,
  CArray[Pointer[GError]] $error
)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_key_file_get_uint64 (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns guint64
  is native(glib)
  is export
{ * }

sub g_key_file_get_value (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_has_group (GKeyFile $key_file, Str $group_name)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_has_key (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_load_from_bytes (
  GKeyFile                $key_file,
  GBytes                  $bytes,
  uint32                  $flags,                # GKeyFileFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_load_from_data (
  GKeyFile                $key_file,
  Str                     $data,
  gsize                   $length,
  uint32                  $flags,                # GKeyFileFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_load_from_data_dirs (
  GKeyFile                $key_file,
  Str                     $file,
  Str                     $full_path,
  uint32                  $flags,                # GKeyFileFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_load_from_dirs (
  GKeyFile                $key_file,
  Str                     $file,
  Str                     $search_dirs,
  Str                     $full_path,
  uint32                  $flags,                # GKeyFileFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_load_from_file (
  GKeyFile                $key_file,
  Str                     $file,
  uint32                  $flags,                # GKeyFileFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_new ()
  returns GKeyFile
  is native(glib)
  is export
{ * }

sub g_key_file_ref (GKeyFile $key_file)
  returns GKeyFile
  is native(glib)
  is export
{ * }

sub g_key_file_remove_comment (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_remove_group (
  GKeyFile                $key_file,
  Str                     $group_name,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_remove_key (
  GKeyFile                $key_file,
  Str                     $group_name,
  Str                     $key,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_save_to_file (
  GKeyFile                $key_file,
  Str                     $filename,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_set_boolean (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  gboolean $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_comment (
  GKeyFile $key_file,
  Str $group_name,
  Str $key,
  Str $comment,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_key_file_set_double (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  gdouble  $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_int64 (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  gint64   $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_integer (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  gint     $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_list_separator (GKeyFile $key_file, Str $separator)
  is native(glib)
  is export
{ * }

sub g_key_file_set_locale_string (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  Str      $locale,
  Str      $string
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_string (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  Str      $string
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_uint64 (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  guint64  $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_value (
  GKeyFile $key_file,
  Str      $group_name,
  Str      $key,
  Str      $value
)
  is native(glib)
  is export
{ * }

sub g_key_file_to_data (
  GKeyFile                $key_file,
  gsize                   $length    is rw,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_key_file_unref (GKeyFile $key_file)
  is native(glib)
  is export
{ * }

sub g_key_file_set_string_list (
  GKeyFile         $key_file,
  Str              $group_name,
  Str              $key,
  CArray[Str]      $list,
  gsize            $length
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_locale_string_list (
  GKeyFile         $key_file,
  Str              $group_name,
  Str              $key,
  Str              $locale,
  CArray[Str]      $list,
  gsize            $length
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_boolean_list (
  GKeyFile         $key_file,
  Str              $group_name,
  Str              $key,
  CArray[gboolean] $list,
  gsize            $length
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_double_list (
  GKeyFile        $key_file,
  Str             $group_name,
  Str             $key,
  CArray[gdouble] $list,
  gsize           $length
)
  is native(glib)
  is export
{ * }

sub g_key_file_set_integer_list (
  GKeyFile     $key_file,
  Str          $group_name,
  Str          $key,
  CArray[gint] $list,
  gsize        $length
)
  is native(glib)
  is export
{ * }
