use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;

unit package GLib::Raw::Uri;

our constant G_URI_RESERVED_CHARS_GENERIC_DELIMETERS      is export = ':/?#[]@';

our constant G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS is export = q«!$&'()*+,;=»;

our constant G_URI_RESERVED_CHARS_ALLOWED_IN_PATH_ELEMENT is export =
  G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS ~ ':@';

our constant G_URI_RESERVED_CHARS_ALLOWED_IN_PATH         is export =
  G_URI_RESERVED_CHARS_ALLOWED_IN_PATH_ELEMENT ~ '/';

our constant G_URI_RESERVED_CHARS_ALLOWED_IN_USERINFO     is export =
  G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS ~ ':';


### /usr/src/glib2.0-2.68.4/glib/guri.h

sub g_uri_build (
  GUriFlags $flags,
  Str       $scheme,
  Str       $userinfo,
  Str       $host,
  gint      $port,
  Str       $path,
  Str       $query,
  Str       $fragment
)
  returns GUri
  is      native(glib)
  is      export
{ * }

sub g_uri_build_with_user (
  GUriFlags $flags,
  Str       $scheme,
  Str       $user,
  Str       $password,
  Str       $auth_params,
  Str       $host,
  gint      $port,
  Str       $path,
  Str       $query,
  Str       $fragment
)
  returns GUri
  is      native(glib)
  is      export
{ * }

sub g_uri_error_quark
  returns GQuark
  is      native(glib)
  is      export
{ * }

sub g_uri_escape_bytes (
  guint8 $unescaped is rw,
  gsize  $length,
  Str    $reserved_chars_allowed
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_escape_string (
  Str      $unescaped,
  Str      $reserved_chars_allowed,
  gboolean $allow_utf8
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_auth_params (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_flags (GUri $uri)
  returns GUriFlags
  is      native(glib)
  is      export
{ * }

sub g_uri_get_fragment (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_host (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_password (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_path (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_port (GUri $uri)
  returns gint
  is      native(glib)
  is      export
{ * }

sub g_uri_get_query (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_scheme (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_user (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_get_userinfo (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_is_valid (
  Str                     $uri_string,
  GUriFlags               $flags,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_uri_join (
  GUriFlags $flags,
  Str       $scheme,
  Str       $userinfo,
  Str       $host,
  gint      $port,
  Str       $path,
  Str       $query,
  Str       $fragment
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_join_with_user (
  GUriFlags $flags,
  Str       $scheme,
  Str       $user,
  Str       $password,
  Str       $auth_params,
  Str       $host,
  gint      $port,
  Str       $path,
  Str       $query,
  Str       $fragment
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_params_iter_init (
  GUriParamsIter  $iter,
  Str             $params,
  gssize          $length,
  Str             $separators,
  GUriParamsFlags $flags
)
  is      native(glib)
  is      export
{ * }

sub g_uri_params_iter_next (
  GUriParamsIter          $iter,
  CArray[Str]             $attribute,
  CArray[Str]             $value,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_uri_parse (
  Str                     $uri_string,
  GUriFlags               $flags,
  CArray[Pointer[GError]] $error
)
  returns GUri
  is      native(glib)
  is      export
{ * }

sub g_uri_parse_params (
  Str                     $params,
  gssize                  $length,
  Str                     $separators,
  GUriParamsFlags         $flags,
  CArray[Pointer[GError]] $error
)
  returns GHashTable
  is      native(glib)
  is      export
{ * }

sub g_uri_parse_relative (
  GUri                    $base_uri,
  Str                     $uri_ref,
  GUriFlags               $flags,
  CArray[Pointer[GError]] $error
)
  returns GUri
  is      native(glib)
  is      export
{ * }

sub g_uri_parse_scheme (Str $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_peek_scheme (Str $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_ref (GUri $uri)
  returns GUri
  is      native(glib)
  is      export
{ * }

sub g_uri_resolve_relative (
  Str                     $base_uri_string,
  Str                     $uri_ref,
  GUriFlags               $flags,
  CArray[Pointer[GError]] $error
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_split (
  Str                     $uri_ref,
  GUriFlags               $flags,
  CArray[Str]             $scheme,
  CArray[Str]             $userinfo,
  CArray[Str]             $host,
  gint                    $port is rw,
  CArray[Str]             $path,
  CArray[Str]             $query,
  CArray[Str]             $fragment,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_uri_split_network (
  Str                     $uri_string,
  GUriFlags               $flags,
  CArray[Str]             $scheme,
  CArray[Str]             $host,
  gint                    $port is rw,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_uri_split_with_user (
  Str                     $uri_ref,
  GUriFlags               $flags,
  CArray[Str]             $scheme,
  CArray[Str]             $user,
  CArray[Str]             $password,
  CArray[Str]             $auth_params,
  CArray[Str]             $host,
  gint                    $port is rw,
  CArray[Str]             $path,
  CArray[Str]             $query,
  CArray[Str]             $fragment,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(glib)
  is      export
{ * }

sub g_uri_to_string (GUri $uri)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_to_string_partial (
  GUri          $uri,
  GUriHideFlags $flags
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_unescape_bytes (
  Str                     $escaped_string,
  gssize                  $length,
  Str                     $illegal_characters,
  CArray[Pointer[GError]] $error
)
  returns GBytes
  is      native(glib)
  is      export
{ * }

sub g_uri_unescape_segment (
  Str $escaped_string,
  Str $escaped_string_end,
  Str $illegal_characters
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_unescape_string (
  Str $escaped_string,
  Str $illegal_characters
)
  returns Str
  is      native(glib)
  is      export
{ * }

sub g_uri_unref (GUri $uri)
  is      native(glib)
  is      export
{ * }
