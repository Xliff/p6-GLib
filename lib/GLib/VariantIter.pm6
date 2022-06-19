use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Variant;

use GLib::Variant;

class GLib::VariantIter {
  has GVariantIter $!vi is implementor handles<p>;

  submethod BUILD (:$iter) {
    $!vi = $iter;
  }

  method GLib::Raw::Definitions::GVariantIter
    is also<VariantIter>
  { $!vi }

  multi method new (GVariant() $value) {
    my $iter = g_variant_iter_new($value);

    $iter ?? self.bless( :$iter ) !! Nil;
  }

  multi method new (GVariant() $value, :$iter is required) {
    self.init($value);
  }
  method init (GVariant() $value) {
    my $iter = GVariantIter.new;

    g_variant_iter_init($iter, $value);

    $iter ?? self.bless( :$iter ) !! Nil;
  }

  method copy {
    g_variant_iter_copy($!vi);
  }

  method free {
    g_variant_iter_free($!vi);
  }

  method n_children
    is also<
      n-children
      elems
    >
  {
    g_variant_iter_n_children($!vi);
  }

  method next_value
    is also<
      next-value
      next
    >
  {
    my $nv = g_variant_iter_next_value($!vi);

    #say "NV: { $nv.^name } ({ +$nv.p })";
    $nv;
  }

  method next_key_value ( :$raw = False )
    is also<
      next-key-value
    >
  {
    my $k = newCArray(Str);
    my $v = newCArray(GVariant);

    #say "K: { $k.^name }";

    return Nil unless g_variant_iter_next_key_value($!vi, '{sv}', $k, $v);

    $v = GLib::Variant.new( ppr($v) ) unless $raw;
    #say "VKV:  { $v.print(:annotate) }";
    my @r = ( ppr($k), $v );
    #say "R: { @r.gist }";
    @r;
  }

}
