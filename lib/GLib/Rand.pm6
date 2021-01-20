use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Rand;

class GLib::Rand {
  has GRand $!r is implementor handles<p>;

  submethod BUILD (:$rand) {
    $!r = $rand;
  }

  method GLib::Raw::Definitions::GRand
    is also<GRand>
  { $!r }

  multi method new (GRand $rand) {
    $rand ?? self.bless( :$rand ) !! Nil;
  }
  multi method new {
    my $rand = g_rand_new();

    $rand ?? self.bless( :$rand ) !! Nil;
  }

  method new_with_seed (Int() $seed = 0) is also<new-with-seed> {
    my guint $s    = $seed;
    my       $rand = g_rand_new_with_seed($seed);

    $rand ?? self.bless( :$rand ) !! Nil;
  }

  proto method new_with_seed_array (|)
      is also<new-with-seed-array>
  { * }

  multi method new_with_seed_array (@seeds) {
    samewith( ArrayToCArray(guint, @seeds), @seeds.elems );
  }
  multi method new_with_seed_array (
    CArray[guint] $seed_array,
    Int() $seed_length
  ) {
    my guint $sl   = $seed_length;
    my       $rand = g_rand_new_with_seed_array($seed_array, $sl);

    $rand ?? self.bless( :$rand ) !! Nil;
  }

  # Class methods,.
  multi method double (
    GLib::Rand:U:
  ) {
    g_random_double();
  }

  proto method double_range (|)
    is also<double-range>
  { * }

  multi method double_range (
    GLib::Rand:U:
    Num()         $begin,
    Num()         $end
  ) {
    my gdouble ($b, $e) = ($begin, $end);

    g_random_double_range($b, $e);
  }

  multi method int (GLib::Rand:U:) {
    g_random_int();
  }

  proto method int_range (|)
    is also<int-range>
  { * }

  multi method int_range (
    GLib::Rand:U:
    Int()         $begin,
    Int()         $end
  ) {
    my gint ($b, $e) = ($begin, $end);

    g_random_int_range($b, $e);
  }

  proto method set_seed (|)
    is also<set-seed>
  { * }

  multi method set_seed (
    GLib::Rand:U:
    Int()         $seed
  ) {
    my guint $s = $seed;

    g_random_set_seed($s);
  }

  # Methods
  method copy (GLib::Rand:D: ) {
    GLib::Rand.new( g_rand_copy($!r) );
  }

  multi method double ( GLib::Rand:D: ) {
    g_rand_double($!r);
  }

  multi method double_range (GLib::Rand:D: Num() $begin, Num() $end) {
    my gdouble ($b, $e) = ($begin, $end);

    g_rand_double_range($!r, $b, $e);
  }

  method free {
    g_rand_free($!r);
  }

  multi method int (GLib::Rand:D: ) {
    g_rand_int($!r);
  }

  multi method int_range (GLib::Rand:D: Int() $begin, Int() $end) {
    my gint ($b, $e) = ($begin, $end);

    g_rand_int_range($!r, $b, $e);
  }

  multi method set_seed (GLib::Rand:D: Int() $seed) {
    my guint $s = $seed;

    g_rand_set_seed($!r, $seed);
  }

  proto method set_seed_array (|)
      is also<set-seed-array>
  { * }

  multi method set_seed_array (GLib::Rand:D: @seeds) {
    samewith( ArrayToCArray(guint, @seeds), @seeds.elems );
  }
  multi method set_seed_array (
    GLib::Rand:D:
    CArray[guint] $seed_array,
    Int()         $seed_length
  ) {
    my guint $sl = $seed_length;

    g_rand_set_seed_array($!r, $seed_array, $seed_length);
  }

}
