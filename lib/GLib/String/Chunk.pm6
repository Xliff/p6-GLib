use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::String::Chunk;

use GLib::Roles::Implementor;

class GLib::String::Chunk {
  also does GLib::Roles::Implementor;

  has GStringChunk $!sc is implementor;

  submethod BUILD ( :glib-string-chunk(:$!sc) ) 
  { }

  method GLib::Raw::Structs::GStringChunk
    is also<GStringChunk>
  { $!sc }

  proto method new (|)
  { * }

  multi method new ( :glib_string_chunk(:$glib-string-chunk) ) {
    samewith($glib-string-chunk)
  }
  multi method new (GStringChunk $glib-string-chunk) {
    $glib-string-chunk ?? self.bless( :$glib-string-chunk ) !! Nil;
  }
  multi method new (Int() $len) {
    my gsize $l                 = $len;
    my       $glib-string-chunk = g_string_chunk_new($l);

    $glib-string-chunk ?? self.bless( :$glib-string-chunk ) !! Nil;
  }

  method clear {
    g_string_chunk_clear($!sc);
  }

  method free {
    g_string_chunk_free($!sc);
  }

  method insert (Str() $string) {
    g_string_chunk_insert($!sc, $string);
  }

  method insert_const (Str() $string) is also<insert-const> {
    g_string_chunk_insert_const($!sc, $string);
  }

  method insert_len (Str() $string, Int() $len) is also<insert-len> {
    my gsize $l = $len;

    g_string_chunk_insert_len($!sc, $string, $len);
  }

}
