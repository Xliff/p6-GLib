use v6.c;

use Method::Also;

use GLib::Raw::Types;

use GLib::Raw::String;
use GLib::Raw::Bytes;

class GLib::String {
  has GString $!s is implementor handles<p str>;

  submethod BUILD (:$string) {
    $!s = $string;
  }

  method GLib::Raw::Structs::GString
    is also<GString>
  { $!s }

  method Str { self.str }

  multi method new (GString $string, :$ref) {
    $string ?? self.bless( :$string ) !! Nil;
  }
  multi method new (Str() $init = Str) {
    my $string = g_string_new($init);

    $string ?? self.bless( :$string ) !! Nil;
  }

  method new_len (Str() $init = '', Int() $len = $init.chars + 1)
    is also<new-len>
  {
    my gssize $l      = $len;
    my        $string = g_string_new_len($init, $len);

    $string ?? self.bless( :$string ) !! Nil;
  }

  method new_sized (Int() $dfl_size) is also<new-sized> {
    my gsize $d      = $dfl_size;
    my       $string = g_string_sized_new($d);

    $string ?? self.bless( :$string ) !! Nil;
  }

  method append (Str() $val) {
    g_string_append($!s, $val);
  }

  method append_c (Str() $c) is also<append-c> {
    g_string_append_c($!s, $c);
  }

  method append_len (Str() $val, Int() $len = $val.chars + 1)
    is also<append-len>
  {
    my gssize $l = $len;

    g_string_append_len($!s, $val, $len);
  }

  method append_unichar ($unichar) is also<append-unichar> {
    my guint32 $u = do given $unichar {
      when Int { $_ }
      when Str { .substr(0, 1).ord }
      default  { die 'Unexpected value given!'; }
    };

    g_string_append_unichar($!s, $u);
  }

  method append_uri_escaped (
    Str() $unescaped,
    Str() $reserved_chars_allowed,
    Int() $allow_utf8
  )
    is also<append-uri-escaped>
  {
    my gboolean $a = $allow_utf8;

    g_string_append_uri_escaped($!s, $unescaped, $reserved_chars_allowed, $a);
  }

  method ascii_down is also<ascii-down> {
    g_string_ascii_down($!s);
  }

  method ascii_up is also<ascii-up> {
    g_string_ascii_up($!s);
  }

  method assign (Str() $rval) {
    g_string_assign($!s, $rval);
  }

  method down {
    g_string_down($!s);
  }

  method equal (GString() $v2) {
    g_string_equal($!s, $v2);
  }

  method erase (Int() $pos, Int() $len) {
    my gssize ($p, $l) = ($pos, $len);

    g_string_erase($!s, $p, $l);
  }

  method free (Int() $free_segment = False) {
    my gboolean $f = $free_segment.so.Int;

    g_string_free($!s, $f);
  }

  method free_to_bytes (:$raw = False) is also<free-to-bytes> {
    my $b = g_string_free_to_bytes($!s);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b) )
      !!
      Nil;
  }

  method hash {
    g_string_hash($!s);
  }

  method insert (Int() $pos, Str() $val) {
    my gsize $p = $pos;

    g_string_insert($!s, $pos, $val);
  }

  method insert_c (Int() $pos, Str() $c) is also<insert-c> {
    my gssize $p = $pos;

    g_string_insert_c($!s, $p, $c);
  }

  method insert_len (Int() $pos, Str() $val, Int() $len) is also<insert-len> {
    my gssize ($p, $l) = ($pos, $len);

    g_string_insert_len($!s, $p, $val, $l);
  }

  method insert_unichar (Int() $pos, Int $wc) is also<insert-unichar> {
    my gsize $p  = $pos;
    my guint $uc = do given $wc {
      when Int { $_ }
      when Str { .substr(0, 1).ord }
      default  { die 'Unexpected value given!'; }
    };

    g_string_insert_unichar($!s, $pos, $wc);
  }

  method overwrite (Int() $pos, Str() $val) {
    my gsize $p = $pos;

    g_string_overwrite($!s, $pos, $val);
  }

  method overwrite_len (Int() $pos, Str() $val, Int() $len)
    is also<overwrite-len>
  {
    my gsize  $p = $pos;
    my gssize $l = $len;

    g_string_overwrite_len($!s, $pos, $val, $len);
  }

  method prepend (Str() $val) {
    g_string_prepend($!s, $val);
  }

  method prepend_c (Str() $c) is also<prepend-c> {
    g_string_prepend_c($!s, $c);
  }

  method prepend_len (Str() $val, Int() $len) is also<prepend-len> {
    my gssize $l = $len;

    g_string_prepend_len($!s, $val, $l);
  }

  multi method prepend_unichar ($wc) is also<prepend-unichar> {
    my guint $uc = do given $wc {
      when Int { $_ }
      when Str { .substr(0, 1).ord }
      default  { die 'Unexpected value given!'; }
    };

    g_string_prepend_unichar($!s, $uc);
  }

  method set_size (Int() $len) is also<set-size> {
    my gsize $l = $len;

    g_string_set_size($!s, $l);
  }

  method truncate (Int() $len) {
    my gsize $l = $len;

    g_string_truncate($!s, $l);
  }

  method up {
    g_string_up($!s);
  }

}
