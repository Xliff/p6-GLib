use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

unit package GLib::Raw::GString::Chunk;

### /usr/src/glib/glib/gstringchunk.h

sub g_string_chunk_clear (GStringChunk $chunk)
  is      native(glib)
  is      export
{ * }

sub g_string_chunk_free (GStringChunk $chunk)
  is      native(glib)
  is      export
{ * }

sub g_string_chunk_insert (
  GStringChunk $chunk,
  Str          $string
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_string_chunk_insert_const (
  GStringChunk $chunk,
  Str          $string
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_string_chunk_insert_len (
  GStringChunk $chunk,
  Str          $string,
  gssize       $len
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_string_chunk_new (gsize $size)
  returns GStringChunk
  is      native(glib)
  is      export
{ * }
