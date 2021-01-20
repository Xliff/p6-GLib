use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Regex;

class GLib::MatchInfo {
  has GMatchInfo $!m is implementor handles<p>;

  submethod BUILD (:$match) {
    $!m = $match;
  }

  method new (GMatchInfo $match) {
    $match ?? self.bless( :$match ) !! NativeCall
  }

  method GLib::Raw::Definitions::MatchInfo
    is also<MatchInfo>
  { $!m }

  method expand_references (
    Str() $string_to_expand,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<expand-references>
  {
    clear_error;
    my $rv = g_match_info_expand_references($!m, $string_to_expand, $error);
    set_error($error);
    $rv;
  }

  method fetch (Int() $match_num) {
    my gint $m = $match_num;

    g_match_info_fetch($!m, $m);
  }

  method fetch_all is also<fetch-all> {
    CStringArrayToArray( g_match_info_fetch_all($!m) );
  }

  method fetch_named (Str() $name) is also<fetch-named> {
    g_match_info_fetch_named($!m, $name);
  }

  proto method fetch_named_pos (|)
    is also<fetch-named-pos>
  { * }

  multi method fetch_named_pos (Str() $name) {
    my $rv = samewith($name, $, $, :all);

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method fetch_named_pos (
    Str() $name,
    $start_pos is rw,
    $end_pos is rw,
    :$all = False
  ) {
    my gint ($s, $e) = 0 xx 2;

    my $rv = g_match_info_fetch_named_pos($!m, $name, $s, $e);
    ($start_pos, $end_pos) = ($s, $e);
    $all.not ?? $rv !! ($rv, $start_pos, $end_pos);
  }

  proto method fetch_pos (|)
      is also<fetch-pos>
  { * }

  multi method fetch_pos (Int() $match_num) {
    my $rv = samewith($match_num, $, $, :all);

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method fetch_pos (
    Int() $match_num,
    $start_pos is rw,
    $end_pos is rw,
    :$all = False
  ) {
    my gint $m = $match_num;
    my gint ($s, $e) = 0 xx 2;

    my $rv = g_match_info_fetch_pos($!m, $match_num, $s, $e);
    ($start_pos, $end_pos) = ($s, $e);
    $all.not ?? $rv !! ($rv, $start_pos, $end_pos);
  }

  method free {
    g_match_info_free($!m);
  }

  method get_match_count
    is also<
      get-match-count
      match_count
      match-count
      elems
    >
  {
    g_match_info_get_match_count($!m);
  }

  method get_regex (:$raw = False)
    is also<
      get-regex
      regex
    >
  {
    my $r = g_match_info_get_regex($!m);

    $r ??
      ( $raw ?? $r !! ::('GLib::Regex').new($r) )
      !!
      Nil;
  }

  method get_string
    is also<
      get-string
      string
    >
  {
    g_match_info_get_string($!m);
  }

  method is_partial_match is also<is-partial-match> {
    so g_match_info_is_partial_match($!m);
  }

  method matches {
    so g_match_info_matches($!m);
  }

  method next (CArray[Pointer[GError]] $error) {
    clear_error;
    my $rv = so g_match_info_next($!m, $error);
    set_error($error);
    $rv;
  }

  method ref {
    g_match_info_ref($!m);
    self;
  }

  method unref {
    g_match_info_unref($!m);
  }

}
