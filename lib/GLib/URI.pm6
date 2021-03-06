use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;

use GLib::Convert;

use GLib::Roles::StaticClass;

class GLib::URI {
  also does GLib::Roles::StaticClass;

  method escape_string (
    Str() $unescaped,
    Str() $reserved_chars_allowed,
    Int() $allow_utf8
  )
    is also<escape-string>
  {
    my gboolean $a = $allow_utf8;

    g_uri_escape_string($unescaped, $reserved_chars_allowed, $a);
  }

  method parse_scheme (Str() $uri) is also<parse-scheme> {
    g_uri_parse_scheme($uri);
  }

  method unescape_segment (
    Str() $escaped_string,
    Str() $escaped_string_end,
    Str() $illegal_characters
  )
    is also<unescape-segment>
  {
    g_uri_unescape_segment(
      $escaped_string,
      $escaped_string_end,
      $illegal_characters
    );
  }

  method unescape_string (
    Str $escaped_string,
    Str $illegal_characters
  )
    is also<unescape-string>
  {
    g_uri_unescape_string($escaped_string, $illegal_characters);
  }

  method to_filename (Str() $u) is also<to-filename> {
    GLib::Convert.filename_from_uri($u);
  }

  method from-filename (Str() $f, Str() $h) is also<from_filename> {
    GLib::Convert.filename_to_uri($f, $h);
  }

}

sub g_uri_escape_string (
  Str      $unescaped,
  Str      $reserved_chars_allowed,
  gboolean $allow_utf8
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_uri_parse_scheme (Str $uri)
  returns Str
  is native(glib)
  is export
{ * }

sub g_uri_unescape_segment (
  Str $escaped_string,
  Str $escaped_string_end,
  Str $illegal_characters
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_uri_unescape_string (Str $escaped_string, Str $illegal_characters)
  returns Str
  is native(glib)
  is export
{ * }
