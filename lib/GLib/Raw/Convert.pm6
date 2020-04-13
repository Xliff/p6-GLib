use v6.c;

use NativeCall;

use GLib::Raw::Types;

unit package GLib::Raw::Convert;

### /usr/include/glib-2.0/glib/gconvert.h

sub g_convert (
  Str $str,
  gssize $len,
  Str $to_codeset,
  Str $from_codeset,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_convert_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_convert_with_fallback (
  Str $str,
  gssize $len,
  Str $to_codeset,
  Str $from_codeset,
  Str $fallback,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_convert_with_iconv (
  Str $str,
  gssize $len,
  GIConv $converter,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_display_basename (Str $filename)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_display_name (Str $filename)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_from_uri (
  Str $uri,
  Str $hostname,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_from_utf8 (
  Str $utf8string,
  gssize $len,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_to_uri (
  Str $filename,
  Str $hostname,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_filename_to_utf8 (
  Str $opsysstring,
  gssize $len,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_get_filename_charsets (Str $filename_charsets)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_iconv (
  GIConv $converter,
  Str $inbuf,
  gsize $inbytes_left,
  Str $outbuf,
  gsize $outbytes_left
)
  returns gsize
  is native(glib)
  is export
{ * }

sub g_iconv_close (GIConv $converter)
  returns gint
  is native(glib)
  is export
{ * }

sub g_iconv_open (Str $to_codeset, Str $from_codeset)
  returns GIConv
  is native(glib)
  is export
{ * }

sub g_locale_from_utf8 (
  Str $utf8string,
  gssize $len,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_locale_to_utf8 (
  Str $opsysstring,
  gssize $len,
  gsize $bytes_read,
  gsize $bytes_written,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_uri_list_extract_uris (Str $uri_list)
  returns CArray[Str]
  is native(glib)
  is export
{ * }
