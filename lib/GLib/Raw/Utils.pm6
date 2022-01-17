use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Subs;

unit package GLib::Raw::Utils;

### /usr/include/glib-2.0/glib/gutils.h

sub g_abort ()
  is native(glib)
  is export
{ * }

# sub g_atexit (GVoidFunc $func)
#   is native(glib)
#   is export
# { * }

sub g_strerror (gint32 $errno)
  returns Str
  is native(glib)
  is export
{ * }

sub g_find_program_in_path (Str $program)
  returns Str
  is native(glib)
  is export
{ * }

sub g_format_size (guint64 $size)
  returns Str
  is native(glib)
  is export
{ * }

sub g_format_size_full (guint64 $size, GFormatSizeFlags $flags)
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_application_name ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_home_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_host_name ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_prgname ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_real_name ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_tmp_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_cache_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_config_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_data_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_name ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_runtime_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_user_special_dir (GUserDirectory $directory)
  returns Str
  is native(glib)
  is export
{ * }

sub g_nullify_pointer (gpointer $nullify_location)
  is native(glib)
  is export
{ * }

sub g_parse_debug_string (Str $string, Pointer $keys, guint $nkeys)
  returns guint
  is native(glib)
  is export
{ * }

sub g_reload_user_special_dirs_cache ()
  is native(glib)
  is export
{ * }

sub g_set_application_name (Str $application_name)
  is native(glib)
  is export
{ * }

sub g_set_prgname (Str $prgname)
  is native(glib)
  is export
{ * }
