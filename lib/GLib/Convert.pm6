use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Convert;

use GLib::Roles::StaticClass;

class GLib::Convert {
  also does GLib::Roles::StaticClass;

  multi method convert (
    Str() $str,
    Int() $len,
    Str() $to_codeset,
    Str() $from_codeset
  ) {
    samewith($str, $len, $to_codeset, $from_codeset, $, $, :all);
  }
  multi method convert (
    Str() $str,
    Int() $len,
    Str() $to_codeset,
    Str() $from_codeset,
    $bytes_read is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_convert($str, $l, $to_codeset, $from_codeset, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written)
  }

  method convert_error_quark is also<convert-error-quark> {
    g_convert_error_quark();
  }

  proto method convert_with_fallback (|)
      is also<convert-with-fallback>
  { * }

  multi method convert_with_fallback (
    Str() $str,
    Int() $len,
    Str() $to_codeset,
    Str() $from_codeset,
    Str() $fallback
  ) {
    samewith($str, $len, $to_codeset, $from_codeset, $fallback, $, $, :all);
  }
  multi method convert_with_fallback (
    Str() $str,
    Int() $len,
    Str() $to_codeset,
    Str() $from_codeset,
    Str() $fallback,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_convert_with_fallback(
      $str,
      $l,
      $to_codeset,
      $from_codeset,
      $fallback,
      $br,
      $bw,
      $error
    );
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written);
  }

  proto method convert_with_iconv (|)
      is also<convert-with-iconv>
  { * }

  multi method convert_with_iconv (
    Str() $str,
    Int() $len,
    GIConv() $converter
  ) {
    samewith($str, $len, $converter, $, $, :all)
  }
  multi method convert_with_iconv (
    Str() $str,
    Int() $len,
    GIConv() $converter,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_convert_with_iconv($str, $l, $converter, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written);
  }

  method filename_display_basename (Str() $filename)
    is also<filename-display-basename>
  {
    g_filename_display_basename($filename);
  }

  method filename_display_name (Str() $filename)
    is also<filename-display-name>
  {
    g_filename_display_name($filename);
  }

  proto method filename_from_uri (|)
      is also<filename-from-uri>
  { * }

  multi method filename_from_uri (Str() $uri) {
    samewith($uri, $, :all);
  }
  multi method filename_from_uri (
    Str() $uri,
    $hostname is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my $h = CArray[Str].new;
    $h[0] = Str;

    clear_error;
    my $rv = g_filename_from_uri($uri, $h, $error);
    set_error($error);

    $hostname = $h[0] ?? $h[0] !! Nil;
    $all.not ?? $rv !! ($rv, $hostname);
  }

  proto method filename_from_utf8 (|)
      is also<filename-from-utf8>
  { * }

  multi method filename_from_utf8 (
    Str() $utf8string,
    Int() $len
  ) {
    samewith($utf8string, $len, $, $, :all);
  }
  multi method filename_from_utf8 (
    Str() $utf8string,
    Int() $len,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_filename_from_utf8($utf8string, $l, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $br, $bw);
  }

  method filename_to_uri (
    Str() $filename,
    Str() $hostname,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<filename-to-uri>
  {
    clear_error;
    my $rv = g_filename_to_uri($filename, $hostname, $error);
    set_error($error);
    $rv;
  }

  proto method filename_to_utf8 (|)
      is also<filename-to-utf8>
  { * }

  multi method filename_to_utf8 (
    Str() $opsysstring,
    Int() $len
  ) {
    samewith($opsysstring, $len, $, $, :all);
  }
  multi method filename_to_utf8 (
    Str() $opsysstring,
    Int() $len,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False;
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_filename_to_utf8($opsysstring, $l, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $br, $bw);
  }

  proto method get_filename_charsets (|)
    is also<get-filename-charsets>
  { * }

  multi method get_filename_charsets  {
    samewith($, :all);
  }
  multi method get_filename_charsets (
    $filename_charsets is rw,
    :$all = False
  ) {
    my $fc = CArray[CArray[Str]].new;
    $fc[0] = CArray[Str];

    my $rv = so g_get_filename_charsets($fc);
    $filename_charsets = $fc[0] ?? CStringArrayToArray($fc[0]) !! Nil;
    $all.not ?? $rv !! ($rv, $filename_charsets);
  }

  # Need to add a more raku-ish multi when I understand this, better.
  multi method iconf (
    GIConv() $converter,
    CArray[Str] $inbuf,
    CArray[Str] $outbuf,
  ) {
    samewith($converter, $inbuf, $, $outbuf, $, :all);
  }
  multi method iconv (
    GIConv() $converter,
    CArray[Str] $inbuf,
    $inbytes_left is rw,
    CArray[Str] $outbuf,
    $outbytes_left is rw,
    :$all = False
  ) {
    my gsize ($ib, $ob) = ($inbytes_left, $outbytes_left);
    my $rv = g_iconv($converter, $inbuf, $ib, $outbuf, $ob);

    ($inbytes_left, $outbytes_left) = ($ib, $ob);
    $all.not ?? $rv !! ($rv, $inbytes_left, $outbytes_left);
  }

  method iconv_close (GIConv() $converter) is also<iconv-close> {
    g_iconv_close($converter);
  }

  method iconv_open (Str() $to_codeset, Str() $from_codeset, :$raw = False)
    is also<iconv-open>
  {
    my $i = g_iconv_open($to_codeset, $from_codeset);

    $i ??
      ( $raw ?? $i !! GLib::IConv.new($i) )
      !!
      Nil;
  }

  proto method locale_from_utf8 (|)
      is also<locale-from-utf8>
  { * }

  multi method locale_from_utf8 (
    Str() $utf8string,
    Int() $len
  ) {
    samewith($utf8string, $len, $, $, :all);
  }
  multi method locale_from_utf8 (
    Str() $utf8string,
    Int() $len,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_locale_from_utf8($utf8string, $l, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written);
  }

  proto method locale_to_utf8 (|)
      is also<locale-to-utf8>
  { * }

  multi method locale_to_utf8 (
    Str() $opsysstring,
    Int() $len
  ) {
    samewith($opsysstring, $len, $, $, :all);
  }
  multi method locale_to_utf8 (
    Str() $opsysstring,
    Int() $len,
    $bytes_read    is rw,
    $bytes_written is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gssize $l = $len;
    my gsize ($br, $bw) = 0 xx 2;

    clear_error;
    my $rv = g_locale_to_utf8($opsysstring, $l, $br, $bw, $error);
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);
    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written);
  }

  # Move to GLib::URI?
  method uri_list_extract_uris (Str() $uri_list)
    is also<uri-list-extract-uris>
  {
    CStringArrayToArray( g_uri_list_extract_uris($uri_list) )
  }

}
