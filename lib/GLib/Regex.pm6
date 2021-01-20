use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Regex;

use GLib::MatchInfo;

class GLib::Regex {
  has GRegex $!r is implementor handles<p>;

  submethod BUILD (:$regex) {
    $!r = $regex;
  }

  method GLib::Raw::Definitions::GRegex
    is also<GRegex>
  { $!r }

  method new (
    Str() $pattern,
    Int() $compile_options         = 0,
    Int() $match_options           = 0,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GRegexCompileFlags $c = $compile_options;
    my GRegexMatchFlags   $m = $match_options;

    clear_error;
    my $regex = g_regex_new($pattern, $c, $m, $error);
    set_error($error);

    $regex ?? self.bless( :$regex ) !! Nil;
  }

  method check_replacement (
    Str() $replacement,
    Int() $has_references,
    CArray[Pointer[GError]] $error
  )
    is also<check-replacement>
  {
    my gboolean $h = $has_references.so.Int;

    clear_error;
    my $rv = so g_regex_check_replacement($replacement, $h, $error);
    set_error($error);
    $rv;
  }

  method error_quark (GLib::Regex:U: ) is also<error-quark> {
    g_regex_error_quark();
  }

  method escape_nul (Str() $string, Int() $length) is also<escape-nul> {
    my gint $l = $length;

    g_regex_escape_nul($string, $l);
  }

  method escape_string (Str() $string, Int() $length) is also<escape-string> {
    my gint $l = $length;

    g_regex_escape_string($string, $length);
  }

  method get_capture_count
    is also<
      get-capture-count
      capture_count
      capture-count
      elems
    >
  {
    g_regex_get_capture_count($!r);
  }

  method get_compile_flags
    is also<
      get-compile-flags
      compile_flags
      compile-flags
    >
  {
    g_regex_get_compile_flags($!r);
  }

  method get_has_cr_or_lf
    is also<
      get-has-cr-or-lf
      has_cr_or_lf
      has-cr-or-lf
      cr_or_lf
      cr-or-lf
    >
  {
    so g_regex_get_has_cr_or_lf($!r);
  }

  method get_match_flags
    is also<
      get-match-flags
      match_flags
      match-flags
    >
  {
    g_regex_get_match_flags($!r);
  }

  method get_max_backref
    is also<
      get-max-backref
      max_backref
      max-backref
    >
  {
    g_regex_get_max_backref($!r);
  }

  method get_max_lookbehind
    is also<
      get-max-lookbehind
      max_lookbehind
      max-lookbehind
    >
  {
    g_regex_get_max_lookbehind($!r);
  }

  method get_pattern
    is also<
      get-pattern
      pattern
    >
  {
    g_regex_get_pattern($!r);
  }

  method get_string_number (Str() $name) is also<get-string-number> {
    g_regex_get_string_number($!r, $name);
  }

  multi method match (
    Str() $string,
    Int() $match_options = 0,
    :$raw                = False,
    :$all                = True
  ) {
    my $mi = CArray[GMatchInfo].new;
    $mi[0] = GMatchInfo;

    my $matched = samewith($string, $match_options, $mi);
    my $m       = ppr($mi);

    $m = GLib::MatchInfo.new($m) unless $m.not || $raw;
    $all.not ?? ($matched ?? $m !! Nil)
             !! ($matched, $m);
  }
  multi method match (
    Str() $string,
    Int() $match_options,
    CArray[GMatchInfo] $match_info
  ) {
    my GRegexMatchFlags $m = $match_options;

    g_regex_match($!r, $string, $m, $match_info);
  }

  proto method match_all (|)
      is also<match-all>
  { * }

  multi method match_all (Int() $match_options, :$all = False, :$raw = False) {
    my $mi = CArray[GMatchInfo].new;
    $mi[0] = GMatchInfo;

    my $matched = samewith($match_options, $mi);
    my $m       = ppr($mi);

    $m = GLib::MatchInfo.new($m) unless $m.not || $raw;
    $all.not ?? ($matched ?? $m !! Nil)
             !! ($matched, $m);
  }
  multi method match_all (
    Str() $string,
    Int() $match_options,
    CArray[GMatchInfo] $match_info
  ) {
    my GRegexMatchFlags $m = $match_options;

    so g_regex_match_all($!r, $string, $match_options, $match_info);
  }

  proto method match_all_full (|)
      is also<match-all-full>
  { * }

  multi method match_all_full (
    Str() $string,
    Int() $match_options           = 0,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    samewith($string, $string.chars, 0, $match_options, $error, :$raw);
  }
  multi method match_all_full (
    Str() $string,
    Int() $start_position,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    samewith(
      $string,
      $string.chars,
      $start_position,
      $match_options,
      $error,
      :$raw
    );
  }
  multi method match_all_full (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my $mi = CArray[GMatchInfo].new;
    $mi[0] = GMatchInfo;

    my $matched = samewith(
      $string,
      $string_len,
      $start_position,
      $match_options,
      $mi,
      $error,
    );
    my $m = ppr($mi);

    $m = GLib::MatchInfo.new($m) unless $m.not || $raw;
    ($matched, $m);
  }
  multi method match_all_full (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    CArray[GMatchInfo] $match_info,
    CArray[Pointer[GError]] $error = gerror,
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize $sl = $string_len;
    my gint $sp = $start_position;

    clear_error;
    my $matched = g_regex_match_all_full(
      $!r,
      $string,
      $sl,
      $sp,
      $m,
      $match_info,
      $error
    );
    set_error($error);
    $matched;
  }

  proto method match_full (|)
      is also<match-full>
  { * }

  multi method match_full (
    Str() $string,
    Int() $match_options           = 0,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    samewith($string, $string.chars, 0, $match_options, $error, :$raw);
  }
  multi method match_full (
    Str() $string,
    Int() $start_position,
    Int() $match_options,
    CArray[Pointer[GError]] $error,
    :$raw = False
  ) {
    samewith($string, $string.chars, $match_options, $error, :$raw);
  }
  multi method match_full (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    CArray[Pointer[GError]] $error,
    :$raw = False
  ) {
    my $mi = CArray[GMatchInfo].new;
    $mi[0] = GMatchInfo;

    my $matched = samewith(
      $string,
      $string_len,
      $start_position,
      $match_options,
      $mi,
      $error
    );
    my $m = ppr($mi);

    $m = GLib::MatchInfo.new($m) unless $m.not || $raw;
    ($matched, $m);
  }
  multi method match_full (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    CArray[GMatchInfo] $match_info,
    CArray[Pointer[GError]] $error
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize $sl = $string_len;
    my gint $sp = $start_position;

    clear_error;
    my $rv = so g_regex_match_full(
      $!r,
      $string,
      $sl,
      $sp,
      $m,
      $match_info,
      $error
    );
    set_error($error);
    $rv;
  }

  method match_simple (
    GLib::Regex:U:
    Str() $pattern,
    Str() $string,
    Int() $compile_options = 0,
    Int() $match_options   = 0
  )
    is also<match-simple>
  {
    my GRegexCompileFlags $c = $compile_options;
    my GRegexMatchFlags   $m = $match_options;

    so g_regex_match_simple($pattern, $string, $c, $m);
  }

  method ref {
    g_regex_ref($!r);
    self;
  }

  multi method replace (
    Str() $string,
    Str() $replacement,
    Int() $match_options           = 0,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith($string, $string.chars, 0, $match_options, $error);
  }
  multi method replace (
    Str() $string,
    Int() $start_position,
    Str() $replacement,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith($string, $string.chars, $start_position, $match_options, $error);
  }
  multi method replace (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Str() $replacement,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize $sl = $string_len;
    my gint $sp = $start_position;

    clear_error;
    my $replaced = g_regex_replace(
      $!r,
      $string,
      $sl,
      $sp,
      $replacement,
      $m,
      $error
    );
    set_error($error);
    $replaced;
  }

  proto method replace_eval (|)
      is also<replace-eval>
  { * }

  multi method replace_eval (
    Str() $string,
    Int() $match_options,
    &eval,
    gpointer $user_data            = gpointer,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      0,
      $match_options,
      &eval,
      $user_data,
      $error
    );
  }
  multi method replace_eval (
    Str() $string,
    Int() $start_position,
    Int() $match_options,
    &eval,
    gpointer $user_data            = gpointer,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      $match_options,
      &eval,
      $user_data,
      $error
    );
  }
  multi method replace_eval (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    &eval,
    gpointer $user_data            = gpointer,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize $sl          = $string_len;
    my gint $sp            = $start_position;

    clear_error;
    my $replaced = g_regex_replace_eval(
      $!r,
      $string,
      $sl,
      $sp,
      $m,
      &eval,
      $user_data,
      $error
    );
    set_error($error);
    $replaced;
  }

  proto method replace_literal (|)
      is also<replace-literal>
  { * }

  multi method replace_literal (
    Str() $string,
    Str() $replacement,
    Int() $match_options           = 0,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      0,
      $replacement,
      $match_options,
      $error
    );
  }
  multi method replace_literal (
    Str() $string,
    Int() $start_position,
    Str() $replacement,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      $start_position,
      $replacement,
      $match_options,
      $error
    );
  }
  multi method replace_literal (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Str() $replacement,
    Int() $match_options,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize          $sl = $string_len;
    my gint            $sp = $start_position;

    g_regex_replace_literal($!r, $string, $sl, $sp, $replacement, $m, $error);
  }

  method split (Str() $string, Int() $match_options = 0) {
    my GRegexMatchFlags $m = $match_options;

    CStringArrayToArray( g_regex_split($!r, $string, $m) );
  }

  proto method split_full (|)
      is also<split-full>
  { * }

  multi method split_full (
    Str() $string,
    Int() $match_options,
    Int() $max_tokens,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      0,
      $match_options,
      $max_tokens,
      $error
    );
  }
  multi method split_full (
    Str() $string,
    Int() $start_position,
    Int() $match_options,
    Int() $max_tokens,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $string,
      $string.chars,
      $start_position,
      $match_options,
      $max_tokens,
      $error
    );
  }
  multi method split_full (
    Str() $string,
    Int() $string_len,
    Int() $start_position,
    Int() $match_options,
    Int() $max_tokens,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GRegexMatchFlags $m = $match_options;
    my gssize          $sl = $string_len;
    my gint     ($sp, $mt) = ($start_position, $max_tokens);

    clear_error;
    my $l = CStringArrayToArray(
      g_regex_split_full($!r, $string, $sl, $sp, $m, $mt, $error);
    );
    set_error($error);
    $l
  }

  method split_simple (
    GLib::Regex:U:
    Str() $pattern,
    Str() $string,
    GRegexCompileFlags $compile_options = 0,
    GRegexMatchFlags $match_options     = 0
  )
    is also<split-simple>
  {
    my GRegexCompileFlags $c = $compile_options;
    my GRegexMatchFlags   $m = $match_options;

    CStringArrayToArray( g_regex_split_simple($pattern, $string, $c, $m) );
  }

  method unref {
    g_regex_unref($!r);
  }

}
