use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Raw::Uri;

use GLib::Roles::Implementor;

class GLib::Uri {
  also does GLib::Roles::Implementor;

  has GUri $!u is implementor;

  submethod BUILD ( :$g-uri ) {
    $!u = $g-uri;
  }

  method GLib::Raw::Definitions::GUri
    is also<GUri>
  { $!u }

  proto method new (|)
  { * }

  multi method new (
    Int() $flags,
    Str() $scheme,
    Str() $userinfo,
    Str() $host,
    Int() $port,
    Str() $path,
    Str() $query,
    Str() $fragment
  ) {
    self.build(
      $flags,
      $scheme,
      $userinfo,
      $host,
      $port,
      $path,
      $query,
      $fragment
    );
  }
  method build (
    Int() $flags,
    Str() $scheme,
    Str() $userinfo,
    Str() $host,
    Int() $port,
    Str() $path,
    Str() $query,
    Str() $fragment
  ) {
    my GUriFlags $f = $flags;
    my gint      $p = $port,

    my $g-uri = g_uri_build(
      $f,
      $scheme,
      $userinfo,
      $host,
      $p,
      $path,
      $query,
      $fragment
    );

    $g-uri ?? self.bless( :$g-uri ) !! Nil;
  }

  multi method new (
    Str() $scheme,
    Str() $host,
    Str() $path,
    Str() $user,
    Str() $password,
    Str() :$auth_params  = '',
    Int() :$flags        = G_URI_FLAGS_NONE,
    Int() :$port,
    Str() :$query        = '',
    Str() :$fragment     = '',
  ) {
    self.build_with_user(
      $flags,
      $scheme,
      $user,
      $password,
      $auth_params,
      $host,
      $port,
      $path,
      $query,
      $fragment
    );
  }

  method build_with_user (
    Int() $flags,
    Str() $scheme,
    Str() $user,
    Str() $password,
    Str() $auth_params,
    Str() $host,
    Int() $port,
    Str() $path,
    Str() $query,
    Str() $fragment
  )
    is also<build-with-user>
  {
    my GUriFlags $f = $flags;
    my gint      $p = $port,

    my $g-uri = g_uri_build_with_user(
      $f,
      $scheme,
      $user,
      $password,
      $auth_params,
      $host,
      $port,
      $path,
      $query,
      $fragment
    );

    $g-uri ?? self.bless( :$g-uri ) !! Nil;
  }

  multi method new (
    Str() $uri_string,
    Int() $flags        = G_URI_FLAGS_NONE,
  ) {
    self.parse($uri_string, $flags);
  }
  method parse (
    Str()                   $uri_string,
    Int()                   $flags       = G_URI_FLAGS_NONE,
    CArray[Pointer[GError]] $error       = gerror
  )
    is static
  {
    my GUriFlags $f = $flags;

    clear_error;
    my $g-uri = g_uri_parse($uri_string, $f, $error);
    set_error($error);

    $g-uri ?? self.bless( :$g-uri ) !! Nil
  }

  method parse_relative (
    Str()                   $uri_ref,
    Int()                   $flags,
    CArray[Pointer[GError]] $error    = gerror
  )
    is also<parse-relative>
  {
    my GUriFlags $f = $flags;

    clear_error;
    my $g-uri = g_uri_parse_relative($!u, $uri_ref, $f, $error);
    set_error($error);

    $g-uri ?? self.bless( :$g-uri ) !! Nil
  }

  method error_quark
    is static
    is also<error-quark>
  {
    g_uri_error_quark();
  }

  method escape_bytes (
    Str() $unescaped,
    Int() $length,
    Str() $reserved_chars_allowed
  )
    is static
    is also<escape-bytes>
  {
    my gsize $l = $length;

    g_uri_escape_bytes($unescaped, $l, $reserved_chars_allowed);
  }

  method escape_string (
    Str() $unescaped,
    Str() $reserved_chars_allowed,
    Int() $allow_utf8
  )
    is static
    is also<escape-string>
  {
    my gboolean $a = $allow_utf8.so.Int;

    g_uri_escape_string($unescaped, $reserved_chars_allowed, $a);
  }

  method get_auth_params is also<get-auth-params> {
    g_uri_get_auth_params($!u);
  }

  method get_flags ( :$flags = True ) is also<get-flags> {
    my $f = g_uri_get_flags($!u);
    return $f unless $flags;
    getFlags(GUriFlagsEnum, $f);
  }

  method get_fragment is also<get-fragment> {
    g_uri_get_fragment($!u);
  }

  method get_host is also<get-host> {
    g_uri_get_host($!u);
  }

  method get_password is also<get-password> {
    g_uri_get_password($!u);
  }

  method get_path is also<get-path> {
    g_uri_get_path($!u);
  }

  method get_port is also<get-port> {
    g_uri_get_port($!u);
  }

  method get_query is also<get-query> {
    g_uri_get_query($!u);
  }

  method get_scheme is also<get-scheme> {
    g_uri_get_scheme($!u);
  }

  method get_user is also<get-user> {
    g_uri_get_user($!u);
  }

  method get_userinfo is also<get-userinfo> {
    g_uri_get_userinfo($!u);
  }

  method is_valid (
    Str()                   $uri_string,
    Int()                   $flags,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<is-valid>
  {
    my GUriFlags $f = $flags;

    clear_error;
    g_uri_is_valid($uri_string, $f, $error);
    set_error($error);
  }

  method join (
    Int() $flags,
    Str() $scheme,
    Str() $userinfo,
    Str() $host,
    Int() $port,
    Str() $path,
    Str() $query,
    Str() $fragment
  )
    is static
  {
    my GUriFlags $f = $flags;
    my gint      $p = $port;

    g_uri_join(
      $f,
      $scheme,
      $userinfo,
      $host,
      $port,
      $path,
      $query,
      $fragment
    );
  }

  method join_with_user (
    Int() $flags,
    Str() $scheme,
    Str() $user,
    Str() $password,
    Str() $auth_params,
    Str() $host,
    Int() $port,
    Str() $path,
    Str() $query,
    Str() $fragment
  )
    is static

    is also<join-with-user>
  {
    my GUriFlags $f = $flags;
    my gint      $p = $port;

    g_uri_join_with_user(
      $f,
      $scheme,
      $user,
      $password,
      $auth_params,
      $host,
      $p,
      $path,
      $query,
      $fragment
    );
  }

  method parse_params (
    Str()                    $params,
    Int()                    $length     = -1,
    Str()                    $separators = '&',
    Int()                    $flags      = G_URI_PARAMS_NONE,
    CArray[Pointer[GError]]  $error      = gerror,
                            :$raw        = False
  )
    is static

    is also<parse-params>
  {
    my gssize          $l = $length;
    my GUriParamsFlags $f = $flags;

    clear_error;
    my $h = g_uri_parse_params($!u, $l, $separators, $f, $error);
    set_error($error);

    propReturnObject( $h,  :$raw, |GLib::HashTable.getTypePair );
  }

  method parse_scheme (Str() $uri) is static is also<parse-scheme> {
    g_uri_parse_scheme($uri);
  }

  method peek_scheme (Str() $url)
    is static
    is also<peek-scheme>
  {
    g_uri_peek_scheme($url);
  }

  method ref {
    g_uri_ref($!u);
  }

  method resolve_relative (
    Str()                   $base_uri_string,
    Str()                   $uri_ref,
    Int()                   $flags,
    CArray[Pointer[GError]] $error            = gerror
  )
    is also<resolve-relative>
  {
    my GUriFlags $f = $flags;

    g_uri_resolve_relative($!u, $uri_ref, $f, $error);
  }

  multi method split (Str() $uri_ref, Int() $flags = G_URI_FLAGS_NONE) {
    samewith(
      $uri_ref,
      $flags,
      |newCArray(Str) xx 3,
      $,
      |newCArray(Str) xx 3,
      :all
    );
  }
  multi method split (
    Str()                    $uri_ref,
    Int()                    $flags,
    CArray[Str]              $scheme,
    CArray[Str]              $userinfo,
    CArray[Str]              $host,
                             $port is rw,
    CArray[Str]              $path,
    CArray[Str]              $query,
    CArray[Str]              $fragment,
    CArray[Pointer[GError]]  $error       = gerror,
                            :$all         = False
  )
    is static
  {
    my GUriFlags $f = $flags;
    my gint      $p = 0;

    clear_error;
    my $rv = so g_uri_split(
      $uri_ref,
      $f,
      $scheme,
      $userinfo,
      $host,
      $p,
      $path,
      $query,
      $fragment,
      $error
    );
    set_error($error);
    $port = $p;
    $all.not ?? $rv
             !! (
                  |ppr($scheme, $userinfo, $host),
                  $port,
                  |ppr($path, $query, $fragment)
                );
  }

  proto method split_network (|)
    is also<split-network>
  { * }

  multi method split_network (
    Str()                   $uri_string,
    Int()                   $flags       = G_URI_FLAGS_NONE
  ) {
    samewith(
      $uri_string,
      $flags,
      |newCArray(Str) xx 2;
      $,
      :all
    );
  }
  multi method split_network (
    Str()                    $uri_string,
    Int()                    $flags,
    CArray[Str]              $scheme,
    CArray[Str]              $host,
                             $port        is rw,
    CArray[Pointer[GError]]  $error              = gerror,
                            :$all                = False
  )

  {
    my GUriFlags $f = $flags;
    my gint      $p = 0;

    clear_error;
    my $rv = so g_uri_split_network(
      $uri_string,
      $f,
      $scheme,
      $host,
      $p,
      $error
    );
    set_error($error);
    $port = $p;

    $all.not ?? $rv
             !! ( |ppr($scheme, $host), $port );
  }

  proto method split_with_user (|)
    is also<split-with-user>
  { * }

  multi method split_with_user (
    Str() $uri_ref,
    Int() $flags    = G_URI_FLAGS_NONE
  ) {
    samewith(
      $uri_ref,
      $flags,
      |newCArray(Str) xx 5,
      $,
      |newCArray(Str) xx 3
    );
  }
  multi method split_with_user (
    Str()                    $uri_ref,
    Int()                    $flags,
    CArray[Str]              $scheme,
    CArray[Str]              $user,
    CArray[Str]              $password,
    CArray[Str]              $auth_params,
    CArray[Str]              $host,
                             $port         is rw,
    CArray[Str]              $path,
    CArray[Str]              $query,
    CArray[Str]              $fragment,
    CArray[Pointer[GError]]  $error                = gerror,
                            :$all                  = False
  ) {
    my GUriFlags $f = $flags;
    my gint      $p = 0;

    clear_error;
    my $rv = so g_uri_split_with_user(
      $uri_ref,
      $f,
      $scheme,
      $user,
      $password,
      $auth_params,
      $host,
      $p,
      $path,
      $query,
      $fragment,
      $error
    );
    set_error($error);
    $port = $p;
    $all.not ?? $rv
             !! (
               |ppr($scheme, $user, $password, $auth_params, $host),
               $p,
               |ppr($path, $query, $fragment)
             );
  }

  method to_string is also<to-string> {
    g_uri_to_string($!u);
  }

  method to_string_partial (Int() $flags) is also<to-string-partial> {
    my GUriHideFlags $f = $flags;

    g_uri_to_string_partial($!u, $f);
  }

  proto method unescape_bytes (|)
    is also<unescape-bytes>
  { * }

  multi method unescape_bytes (
    Str                      $escaped_string,
    CArray[Pointer[GError]]  $error                                  = gerror,
    Int()                   :$length                                 = -1,
    Str                     :illegal-characters(:$illegal_characters) = Str,
                            :$raw = False
  ) {
    samewith($escaped_string, $length, $illegal_characters, $error, :$raw);
  }
  multi method unescape_bytes (
    Str()                    $escaped_string,
    Int()                    $length,
    Str()                    $illegal_characters,
    CArray[Pointer[GError]]  $error              = gerror,
                            :$raw = False
  )
    is static
  {
    my gsize $l = $length;

    clear_error;
    my $b = g_uri_unescape_bytes(
      $escaped_string,
      $l,
      $illegal_characters,
      $error
    );
    set_error($error);

    propReturnObject($b, $raw, |GLib::Bytes.getTypePair);
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
    Str() $escaped_string,
    Str() $illegal_characters
  )
    is also<unescape-string>
  {
    g_uri_unescape_string($escaped_string, $illegal_characters);
  }

  method unref {
    g_uri_unref($!u);
  }
}

class GLib::Uri::Params::Iter {
  has GUriParamsIter $!ui is implementor;

  submethod BUILD ( :$g-params-iter ) {
    $!ui = $g-params-iter;
  }

  method GLib::Raw::Structs::GParamsIter
    is also<GParamsIter>
  { $!ui }

  proto method init (|)
    is also<new>
  { * }

  multi method init (
    Str()            $params,
    Int()            $length     = -1,
    Str()            $separators = '&',
    Int()            $flags      = G_URI_PARAMS_NONE
  ) {
    samewith(
      GUriParamsIter.new,
      $params,
      $length,
      $separators,
      $flags
    );
  }
  multi method init (
    GUriParamsIter() $iter,
    Str()            $params,
    Int()            $length,
    Str()            $separators,
    Int()            $flags
  ) {
    my gssize          $l = $length;
    my GUriParamsFlags $f = $flags;

    my $g-params-iter = g_uri_params_iter_init(
      $iter,
      $params,
      $l,
      $separators,
      $f
    );

    $g-params-iter ?? self.bless( :$g-params-iter ) !! Nil;
  }

  multi method next {
    samewith( |newCArray(Str) xx 2 );
  }
  multi method next (
    CArray[Str]             $attribute,
    CArray[Str]             $value,
    CArray[Pointer[GError]] $error      = gerror
  ) {
    clear_error;
    g_uri_params_iter_next($!ui, $attribute, $value, $error);
    set_error($error);
    ppr($attribute, $value);
  }

}
