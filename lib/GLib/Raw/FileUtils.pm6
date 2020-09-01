use v6.c;

use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;

unit package GLib::Raw::FileUtils;

### /usr/include/glib-2.0/glib/gfileutils.h

sub g_basename (Str $file_name)
  returns Str
  is native(glib)
  is export
{ * }

# sub g_build_filename (Str $first_element, ...)
#   returns Str
#   is native(glib)
#   is export
# { * }
#
# sub g_build_filename_valist (Str $first_element, va_list $args)
#   returns Str
#   is native(glib)
#   is export
# { * }

sub g_build_filenamev (CArray[Str] $args)
  returns Str
  is native(glib)
  is export
{ * }

# sub g_build_path (Str $separator, Str $first_element, ...)
#   returns Str
#   is native(glib)
#   is export
# { * }

sub g_build_pathv (Str $separator, CArray[Str] $args)
  returns Str
  is native(glib)
  is export
{ * }

sub g_canonicalize_filename (Str $filename, Str $relative_to)
  returns Str
  is native(glib)
  is export
{ * }

sub g_dir_make_tmp (Str $tmpl, CArray[Pointer[GError]] $error)
  returns Str
  is native(glib)
  is export
{ * }

sub g_file_error_from_errno (gint $err_no)
  returns GFileError
  is native(glib)
  is export
{ * }

sub g_file_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_file_get_contents (
  Str $filename,
  Str $contents,
  gsize $length,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_file_open_tmp (Str $tmpl, Str $name_used, CArray[Pointer[GError]] $error)
  returns gint
  is native(glib)
  is export
{ * }

sub g_file_read_link (Str $filename, CArray[Pointer[GError]] $error)
  returns Str
  is native(glib)
  is export
{ * }

sub g_file_set_contents (
  Str $filename,
  Str $contents,
  gssize $length,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_file_test (Str $filename, GFileTest $test)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_get_current_dir ()
  returns Str
  is native(glib)
  is export
{ * }

sub g_mkdir_with_parents (Str $pathname, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_mkdtemp (Str $tmpl)
  returns Str
  is native(glib)
  is export
{ * }

sub g_mkdtemp_full (Str $tmpl, gint $mode)
  returns Str
  is native(glib)
  is export
{ * }

sub g_mkstemp (Str $tmpl)
  returns gint
  is native(glib)
  is export
{ * }

sub g_mkstemp_full (Str $tmpl, gint $flags, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_path_get_basename (Str $file_name)
  returns Str
  is native(glib)
  is export
{ * }

sub g_path_get_dirname (Str $file_name)
  returns Str
  is native(glib)
  is export
{ * }

sub g_path_is_absolute (Str $file_name)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_path_skip_root (Str $file_name)
  returns Str
  is native(glib)
  is export
{ * }



### /usr/include/glib-2.0/glib/gstdio.h

sub g_access (Str $filename, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_chdir (Str $path)
  returns gint
  is native(glib)
  is export
{ * }

sub g_chmod (Str $filename, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_close (gint $fd, CArray[Pointer[GError]] $error)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_creat (Str $filename, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_fopen (Str $filename, Str $mode)
  returns FILE
  is native(glib)
  is export
{ * }

sub g_freopen (Str $filename, Str $mode, FILE $stream)
  returns FILE
  is native(glib)
  is export
{ * }

sub g_fsync (gint $fd)
  returns gint
  is native(glib)
  is export
{ * }

#sub g_lstat (Str $filename, GStatBuf $buf)
sub g_lstat (Str $filename, GStatBuf $buf)
  returns gint
  is native(glib)
  is export
{ * }

sub g_mkdir (Str $filename, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_open (Str $filename, gint $flags, gint $mode)
  returns gint
  is native(glib)
  is export
{ * }

sub g_remove (Str $filename)
  returns gint
  is native(glib)
  is export
{ * }

sub g_rename (Str $oldfilename, Str $newfilename)
  returns gint
  is native(glib)
  is export
{ * }

sub g_rmdir (Str $filename)
  returns gint
  is native(glib)
  is export
{ * }

# sub g_stat (Str $filename, GStatBuf $buf)
sub g_stat (Str $filename, Pointer $buf)
  returns gint
  is native(glib)
  is export
{ * }

sub g_unlink (Str $filename)
  returns gint
  is native(glib)
  is export
{ * }
