use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Variant;

use GLib::Roles::Object;

class GLib::VariantDict {
  also does GLib::Roles::Object;

  has GVariantDict $!vd is implementor handles<p>;

  submethod BUILD (:$dict) {
    self!setObject($!vd = $dict);
  }

  method GLib::Raw::Definitions::GVariantDict
    is also<GVariantDict>
  { $!vd }

  method new (GVariant() $value) {
    my $d = g_variant_dict_new($value);

    $d ?? self.bless( dict => $d ) !! Nil
  }

  method clear {
    g_variant_dict_clear($!vd);
  }

  method contains (Str() $key) {
    so g_variant_dict_contains($!vd, $key);
  }

  method end (:$raw = False) {
    my $v = g_variant_dict_end($!vd);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method init (GVariant() $from_asv) {
    g_variant_dict_init($!vd, $from_asv);
  }

  method insert_value (Str() $key, GVariant() $value) is also<insert-value> {
    g_variant_dict_insert_value($!vd, $key, $value);
  }

  method lookup_value (
    Str() $key,
    GVariantType() $expected_type,
    :$raw = False
  )
    is also<lookup-value>
  {
    my $v = g_variant_dict_lookup_value($!vd, $key, $expected_type);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  # Method::Also is not properly handling overrides!
  #method ref is also<upref> {
  method ref {
    g_variant_dict_ref($!vd);
    self;
  }

  method remove (Str() $key) {
    g_variant_dict_remove($!vd, $key);
  }

  # Method::Also is not properly handling overrides!
  #method unref is also<downref> {
  method unref {
    g_variant_dict_unref($!vd);
  }

}
