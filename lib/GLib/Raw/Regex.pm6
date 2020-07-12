use v6.c

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GLib::Raw::Enums;

unit package GLib::Raw::Regex;

### /usr/include/glib-2.0/glib/gregex.h

sub g_regex_check_replacement (
  Str $replacement,
  gboolean $has_references,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_regex_escape_nul (Str $string, gint $length)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_escape_string (Str $string, gint $length)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_get_capture_count (GRegex $regex)
  returns gint
  is native(glib)
  is export
{ * }

sub g_regex_get_compile_flags (GRegex $regex)
  returns GRegexCompileFlags
  is native(glib)
  is export
{ * }

sub g_regex_get_has_cr_or_lf (GRegex $regex)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_get_match_flags (GRegex $regex)
  returns GRegexMatchFlags
  is native(glib)
  is export
{ * }

sub g_regex_get_max_backref (GRegex $regex)
  returns gint
  is native(glib)
  is export
{ * }

sub g_regex_get_max_lookbehind (GRegex $regex)
  returns gint
  is native(glib)
  is export
{ * }

sub g_regex_get_pattern (GRegex $regex)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_get_string_number (GRegex $regex, Str $name)
  returns gint
  is native(glib)
  is export
{ * }

sub g_regex_match (
  GRegex $regex,
  Str $string,
  GRegexMatchFlags $match_options,
  GMatchInfo $match_info
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_match_all (
  GRegex $regex,
  Str $string,
  GRegexMatchFlags $match_options,
  GMatchInfo $match_info
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_match_all_full (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  GRegexMatchFlags $match_options,
  GMatchInfo $match_info,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_match_full (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  GRegexMatchFlags $match_options,
  GMatchInfo $match_info,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_match_simple (
  Str $pattern,
  Str $string,
  GRegexCompileFlags $compile_options,
  GRegexMatchFlags $match_options
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_regex_new (
  Str $pattern,
  GRegexCompileFlags $compile_options,
  GRegexMatchFlags $match_options,
  CArray[Pointer[GError]] $error
)
  returns GRegex
  is native(glib)
  is export
{ * }

sub g_regex_ref (GRegex $regex)
  returns GRegex
  is native(glib)
  is export
{ * }

sub g_regex_replace (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  Str $replacement,
  GRegexMatchFlags $match_options,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_replace_eval (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  GRegexMatchFlags $match_options,
  &eval (GMatchInfo, GString, gpointer --> gboolean),
  gpointer $user_data,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_replace_literal (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  Str $replacement,
  GRegexMatchFlags $match_options,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_split (
  GRegex $regex,
  Str $string,
  GRegexMatchFlags $match_options
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_split_full (
  GRegex $regex,
  Str $string,
  gssize $string_len,
  gint $start_position,
  GRegexMatchFlags $match_options,
  gint $max_tokens,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_split_simple (
  Str $pattern,
  Str $string,
  GRegexCompileFlags $compile_options,
  GRegexMatchFlags $match_options
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_regex_unref (GRegex $regex)
  is native(glib)
  is export
{ * }

sub g_match_info_expand_references (
  GMatchInfo $match_info,
  Str $string_to_expand,
  CArray[Pointer[GError]] $error
)
  returns Str
  is native(glib)
  is export
{ * }

sub g_match_info_fetch (GMatchInfo $match_info, gint $match_num)
  returns Str
  is native(glib)
  is export
{ * }

sub g_match_info_fetch_all (GMatchInfo $match_info)
  returns Str
  is native(glib)
  is export
{ * }

sub g_match_info_fetch_named (GMatchInfo $match_info, Str $name)
  returns Str
  is native(glib)
  is export
{ * }

sub g_match_info_fetch_named_pos (
  GMatchInfo $match_info,
  Str $name,
  gint $start_pos is rw,
  gint $end_pos is rw
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_match_info_fetch_pos (
  GMatchInfo $match_info,
  gint $match_num,
  gint $start_pos is rw,
  gint $end_pos is rw
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_match_info_free (GMatchInfo $match_info)
  is native(glib)
  is export
{ * }

sub g_match_info_get_match_count (GMatchInfo $match_info)
  returns gint
  is native(glib)
  is export
{ * }

sub g_match_info_get_regex (GMatchInfo $match_info)
  returns GRegex
  is native(glib)
  is export
{ * }

sub g_match_info_get_string (GMatchInfo $match_info)
  returns Str
  is native(glib)
  is export
{ * }

sub g_match_info_is_partial_match (GMatchInfo $match_info)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_match_info_matches (GMatchInfo $match_info)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_match_info_next (
  GMatchInfo $match_info,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_match_info_ref (GMatchInfo $match_info)
  returns GMatchInfo
  is native(glib)
  is export
{ * }

sub g_match_info_unref (GMatchInfo $match_info)
  is native(glib)
  is export
{ * }
