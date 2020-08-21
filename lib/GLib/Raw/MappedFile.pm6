use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Raw::MappedFile;

### /usr/include/glib-2.0/glib/gmappedfile.h

sub g_mapped_file_free (GMappedFile $file)
  is native(glib)
  is export
{ * }

sub g_mapped_file_get_bytes (GMappedFile $file)
  returns GBytes
  is native(glib)
  is export
{ * }

sub g_mapped_file_get_contents (GMappedFile $file)
  returns Str
  is native(glib)
  is export
{ * }

sub g_mapped_file_get_length (GMappedFile $file)
  returns gsize
  is native(glib)
  is export
{ * }

sub g_mapped_file_new (
  Str $filename,
  gboolean $writable,
  CArray[Pointer[GError]] $error
)
  returns GMappedFile
  is native(glib)
  is export
{ * }

sub g_mapped_file_new_from_fd (
  gint $fd,
  gboolean $writable,
  CArray[Pointer[GError]] $error
)
  returns GMappedFile
  is native(glib)
  is export
{ * }

sub g_mapped_file_ref (GMappedFile $file)
  returns GMappedFile
  is native(glib)
  is export
{ * }

sub g_mapped_file_unref (GMappedFile $file)
  is native(glib)
  is export
{ * }
