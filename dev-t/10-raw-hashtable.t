use v6;

use NativeCall;

constant gpointer = Pointer;

constant glib     = 'glib-2.0',v0;
constant guint    = uint32;
constant gboolean = uint32;

class GHashTable  is repr<CPointer> { }

sub getStrLen (CArray[uint8] $s) {
  my $l = 0;
  $l++ while $s[$l];
  $l
}

sub newCArray (\T, $fv?, :$encoding = 'utf8') is export {
  if (T, $fv).all ~~ Str {
    return CArray[uint8].new( $fv.encode($encoding) );
  }

  my $s = T.REPR eq 'CStruct';
  (my $p = ( $s ?? CArray[T] !! CArray[ Pointer[T] ] ).new)[0] =
    $fv ?? $fv
        !! ($s ?? T !! Pointer[T]);

  $p;
}

my $h = g_hash_table_new(
  sub (CArray[uint8] $a --> gboolean) { g_str_hash($a) },
  sub (CArray[uint8] $a, CArray[uint8] $b --> gboolean) {
    CATCH { default { .message.say; .backtrace.concise.say } }
    my $a-sub = $a[0 ..^ getStrLen($a)];
    my $b-sub = $b[0 ..^ getStrLen($b)];

    $a-sub.map( *.chr ).gist.say;
    $b-sub.map( *.chr ).gist.say;

    #my $a-str = Buf.new($a-sub).decode;
    #my $b-str = Buf.new($b-sub).decode;

    g_str_equal($a, $b)
  }
);

my $j = newCArray(Str, 'Jazzy');

say "J: $j ({ $j.^name })";

my $r = g_hash_table_insert( $h, $j, newCArray(Str, 'Cheese') );
say $r.so;
say g_hash_table_contains($h, $j);
say g_hash_table_lookup($h, $j);

sub g_hash_table_insert (
  GHashTable $hash_table,
  CArray[uint8]        $key,
  CArray[uint8]        $value
)
  returns uint32
  is native(glib)
  is export
  { * }

sub g_hash_table_new (
  &hash_func  (CArray[uint8] --> guint),
  &equal_func (CArray[uint8] $a, CArray[uint8] $b --> gboolean)
)
  returns GHashTable
  is native(glib)
  is export
  { * }

sub g_str_equal (CArray[uint8] $v1, CArray[uint8] $v2)
  returns uint32
  is native(glib)
  is export
  { * }

sub g_str_hash (CArray[uint8] $v)
  returns guint
  is native(glib)
  is export
  { * }

sub g_hash_table_contains (GHashTable $hash_table, CArray[uint8] $key)
  returns uint32
  is native(glib)
  is export
  { * }

sub g_hash_table_lookup (GHashTable $hash_table, CArray[uint8] $key)
  returns Str
  is native(glib)
  is export
{ * }

sub malloc (uint64)
  returns Pointer
  is native
  { * }

class HashContains {
  has $!hash is built;

  method contains (Str() $key) {
    sub g_hash_table_contains_str (GHashTable $hash_table, CArray[uint8] $key)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    say "H: { $!hash }";

    g_hash_table_contains_str( $!hash, newCArray(Str, $key) )
  }

}

my $hc = HashContains.new(hash => $h);
say $hc.contains('Jazzy');
#say $hc.contains('Cheese');
