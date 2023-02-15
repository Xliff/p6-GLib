use v6.c;

use Method::Also;

use NativeCall;
use NativeHelpers::Blob;

use GLib::Raw::Types;
use GLib::Raw::HashTable;

use GLib::GList;

use GLib::Roles::Implementor;

# cw: This is now semi working for most types. Only basically tested for strings
#     Please note that all variants of lookup_extended have NOT been
#     fully completed with respect to their return values. Please fix!!!

# --- START -- For Role Associative
role AssociativeLike does Associative {
  method ASSIGN-KEY (\k, \v) {
    self.contains(k) ?? self.replace(k, v) !! self.insert(k, v);
  }

  method AT-KEY (\k) is rw {
    Proxy.new:
      FETCH => -> $     { self.lookup(k) },
      STORE => -> $, \v { self.ASSIGN-KEY(k, v) }
  }

  method EXISTS-KEY (\k) {
    self.contains(k);
  }
}

class GLib::HashTable {
  also does AssociativeLike;
  also does GLib::Roles::Implementor;

  has GHashTable $!h is implementor handles<p>;

  has $!type;
  has &!hash_func;
  has %!dict;

  submethod BUILD (:$hash-table, :$!type) {
    $!h = $hash-table;
  }

  submethod DESTROY {
    self.downref
  }

  method GLib::Raw::Definitions::GHashTable
    is also<GHashTable>
  { $!h }

  multi method new (GHashTable $hash-table) {
    $hash-table ?? self.bless( :$hash-table ) !! Nil
  }
  multi method new (@key-pairs) {
    samewith( @key-pairs.rotor(2).map( |* ).Hash );
  }
  multi method new (Positional $keys, Positional $values) {
    samewith( ($keys Z $values).map( |* ).Hash )
  }

  # Really, the only thing that's needed.
  # Look into the diff between %table and *%table.
  # multi method new (
  #   %table,
  #   :$key-encoding = 'utf8',
  #   :$key-double   = True,
  #   :$key-signed   = False,
  #   :$val-encoding = 'utf8',
  #   :$val-double   = True,
  #   :$val-signed   = False,
  #   :$variant      = False
  # ) {
  #   my $o = GLib::HashTable::String.new(&g_str_hash, &g_str_equal);
  #   for %table.keys {
  #     my $v = %table{$_};
  #
  #     if $variant {
  #       $v = do given $v {
  #         when Int {
  #           $val-signed ?? ( $val-double ?? GLib::Variant.new-int64($_)
  #                                        !! GLib::Variant.new-int32($_) )
  #                       !! ( $val-double ?? GLib::Variant.new-uint64($_)
  #                                        !! GLib::Variant.new-uint32($_) )
  #         }
  #
  #         when Str  { GLib::Variant.new-string($_)  }
  #         when Num  { GLib::Variant.new-double($_)  }
  #         when Bool { GLib::Variant.new-boolean($_) }
  #
  #         default {
  #           die "Do not know how to handle { .^name } when adding {
  #                '' }values as Variants to a HashTable!";
  #         }
  #       }
  #     }
  #
  #     $o.insert(
  #       $_,
  #       $v,
  #       :$key-encoding,
  #       :$key-double,
  #       :$key-signed,
  #       :$val-encoding,
  #       :$val-double,
  #       :$val-signed,
  #     )
  #   }
  #   $o;
  # }

  multi method new (GHashTable $hash-table, :$ref = True) {
    my $o = self.bless( :$hash-table );
    $o.ref if $ref;
    $o;
  }

  # COPIED FROM THE DOC PAGES IN FULL, FOR PROPER REFERENCE.
  #
  # Creates a new GHashTable with a reference count of 1.
  #
  # Hash values returned by hash_func are used to determine where keys are stored
  # within the GHashTable data structure. The g_direct_hash(), g_int_hash(),
  # g_int64_hash(), g_double_hash() and g_str_hash() functions are provided for
  # some common types of keys. If hash_func is NULL, g_direct_hash() is used.
  #
  # key_equal_func is used when looking up keys in the GHashTable. The
  # g_direct_equal(), g_int_equal(), g_int64_equal(), g_double_equal() and
  # g_str_equal() functions are provided for the most common types of keys. If
  # key_equal_func is NULL, keys are compared directly in a similar fashion to
  # g_direct_equal(), but without the overhead of a function call.
  # key_equal_func is called with the key from the hash table as its first
  # parameter, and the user-provided key to check against as its second.
  multi method new (
    # These parameters WILL NOT WORK -- (2 years later): Huh? Why not?
    # (Serveral months later):
    # Because passing NC stubs will use the GIVEN BLOCK rather than create
    # a function pointer for the NativeCall definition!
    #
    # The workaround is to wrap the callables in an anonymous sub!
    &hash_func,
    &key_equal_func
  ) {
    my $hash-table = g_hash_table_new(
      sub ($a     --> guint)    { &hash_func($a)          },
      sub ($a, $b --> gboolean) { &key_equal_func($a, $b) }
    );

    $hash-table ?? self.bless( :$hash-table ) !! Nil;
  }

  method new_full (
    &hash_func,
    &key_equal_func,
    &key_destroy_func   = Callable,
    &value_destroy_func = Callable
  )
    is also<new-full>
  {
    # cw: You CANNOT use a NativeCall defined sub as an argument. It must
    #     be wrapped in a Rakudo sub.
    g_hash_table_new_full(
      sub ($a     --> guint)    { &hash_func($a)          },
      sub ($a, $b --> gboolean) { &key_equal_func($a, $b) },
      &key_destroy_func,
      &value_destroy_func
    );
  }

  method add (
    gpointer $key       is copy,
    :$encoding =  'utf8',
    :$double   =  True,
    :$signed   =  False
  ) {
    g_hash_table_add($!h, $key);
  }

  method contains (gpointer $key) {
    so g_hash_table_contains($!h, $key);
  }

  method destroy {
    g_hash_table_destroy($!h);
  }

  method find (&predicate, gpointer $user_data = gpointer) {
    g_hash_table_find($!h, &predicate, $user_data);
  }

  method foreach (&func, gpointer $user_data = gpointer) {
    g_hash_table_foreach($!h, &func, $user_data);
  }

  method foreach_remove (&func, gpointer $user_data = gpointer)
    is also<foreach-remove>
  {
    g_hash_table_foreach_remove($!h, &func, $user_data);
  }

  method foreach_steal (&func, gpointer $user_data = gpointer)
    is also<foreach-steal>
  {
    g_hash_table_foreach_steal($!h, &func, $user_data);
  }

  # # STATIC METHODS -- start
  # method g_direct_equal (GLib::HashTable:U: $v1, $v2) {
  #   g_direct_equal($v1, $v2);
  # }
  #
  # method g_direct_hash (GLib::HashTable:U: Pointer $dh) {
  #   g_direct_hash($dh);
  # }
  #
  # method g_double_equal (GLib::HashTable:U: $v1, $v2) {
  #   g_double_equal($v1, $v2);
  # }
  #
  # method g_double_hash (GLib::HashTable:U: CArray[num64] $d) {
  #   g_double_hash($d);
  # }
  #
  # method g_int64_equal (GLib::HashTable:U: $v1, $v2) {
  #   g_int64_equal($v1, $v2);
  # }
  #
  # method g_int64_hash (GLib::HashTable:U: CArray[int64] $i) {
  #   g_int64_hash($i);
  # }
  #
  # method g_int_equal (GLib::HashTable:U: $i1, $i2) {
  #   g_int_equal($i1, $i2);
  # }
  #
  # method g_int_hash (GLib::HashTable:U: CArray[int32] $i) {
  #   g_int_hash($i);
  # }
  #
  # method g_str_equal (GLib::HashTable:U: Str $s1, Str $s2) {
  #   g_str_equal($s1, $s2);
  # }
  #
  # method g_str_hash (GLib::HashTable:U: Str $s) {
  #   g_str_hash($s);
  # }
  # # STATIC METHODS -- end

  # cw: Provided for role Associative. It is best not to alias get_keys()
  method keys {
    self.get_keys
  }

  method elems {
    self.keys.elems;
  }

  method get_keys (:$raw = False, :$glist = False, :$typed = Str, :$o)
    is also<get-keys>
  {
    my $kl = g_hash_table_get_keys($!h);

    returnGList($kl, $raw, $glist, $typed, $o)
  }

  # Keys can be of various types, so no easy way to do this. Will have to
  # consider the various options: Str, int32, int64, double, Pointer

  proto method get_keys_as_array (|)
      is also<get-keys-as-array>
  { * }

  multi method get_keys_as_array (:$type = Str, :$object) {
    samewith($, :$type, :$object);
  }
  multi method get_keys_as_array ($length is rw, :$type = Str, :$object) {
    my guint $l = $length;

    my $ar = g_hash_table_get_keys_as_array($!h, $l)
      but GLib::Roles::TypedBuffer[$type];
    $length = $l;
    $object === Nil ?? $ar.Array !! $ar.Array.map({ $object.new($_) });
  }

  # cw: Will return a list of CArray or Pointers -- Caller determines type!
  my enum ValueReturn <CARRAY POINTER>;

  my $default-value-return = CARRAY;

  method setValueReturn(:$array, :$pointer) {
    die 'Must use one of :$array or :$pointer in call to setValueReturn'
      unless $array || $pointer;

    die
      'Cannot use both :$array and :$pointer in the same call to setValueReturn'
    unless $array ^^ $pointer;

    $default-value-return = CARRAY  if $array;
    $default-value-return = POINTER if $pointer;
  }

  method get_values (:$raw = False, :$glist = False, :$typed = Pointer, :$o)
    is also<get-values>
  {
    my $vl = g_hash_table_get_values($!h);
    # GLib::GList.new( g_hash_table_get_values($!h) )
    #   but GLib::Roles::ListData[
    #     $default-value-return == CARRAY ?? CArray !! Pointer
    #   ];

    returnGList($vl, $raw, $glist, $typed, $o)
  }

  # cw: Shall use a hash of key => TYPE pairs. This matching is valid for the
  # last time key was stored, and will be used as a DEFAULT at lookup
  # time. When using the Associative interface, this object will always
  # do its best to return a typed value. If you want a RAW value returned,
  # use .lookup(:raw)
  #
  # Must provide a mechanism for setting this dictionary for when the
  # GHashTable is created by C.
  multi method insert (gpointer $key, gpointer $value) {
    so g_hash_table_insert($!h, $key, $value);
  }

  method lookup (gpointer $key) {
    g_hash_table_lookup($!h, $key);
  }

  method lookup_extended (gpointer $lookup_key) {
    my @return-pointers = CArray[Pointer].new;
    @return-pointers[0, 1] = Pointer.new(0) xx 2;

    my $rv = g_hash_table_lookup_extended(
      $!h,
      $lookup_key,
      @return-pointers[0],
      @return-pointers[1]
    );

    ($rv, |@return-pointers);
  }

  method ref {
    g_hash_table_ref($!h);
    self
  }

  method remove (gpointer $key) {
    g_hash_table_remove($!h, $key)
  }

  method remove_all is also<remove-all> {
    g_hash_table_remove_all($!h);
  }

  method replace (gpointer $key, gpointer $value) {
    g_hash_table_replace($!h, $key, $value);
  }

  method size {
    g_hash_table_size($!h);
  }

  method steal (gpointer $key) {
    g_hash_table_steal($!h, $key);
  }

  method steal_all is also<steal-all> {
    g_hash_table_steal_all($!h);
  }

  method steal_extended (gpointer $lookup_key, :$all = False) {
    my @return-pointers = CArray[Pointer].new;
    @return-pointers[0, 1] = Pointer.new(0) xx 2;

    my $rv = so g_hash_table_steal_extended(
      $!h,
      $lookup_key,
      |@return-pointers
    );

    ($rv, |@return-pointers);
  }

  method unref {
    g_hash_table_unref($!h);
  }


  method pairs (:$reversed = False) {
    my ($k, $v) = (self.get_keys, self.get_values);

    do for ^self.elems {
      $reversed.not ?? Pair.new( $k[$_], $v[$_] )
                    !! Pair.new( $v[$_], $k[$_] )
    }
  }

  method antipairs {
    self.pairs( :reversed );
  }
}

# Th String version, where "string" is not spelled S-t-r, but "CArray[uint8]"
class GLib::HashTable::String is GLib::HashTable {
  method new {
    nextwith(&g_str_hash, &g_str_equal);
  }

  method getTypePair {
    GHashTable, GLib::HashTable::String
  }

  method add (Str() $key) {
    sub g_hash_table_add_str(GHashTable, CArray[uint8] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_add')
      { * }

    so g_hash_table_add_str(
      self.GHashtTable,
      newCArray(Str, $key);
    );
  }

  method contains (Str() $key) {
    sub g_hash_table_contains_str (GHashTable, CArray[uint8] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    my $newKey = newCArray(Str, $key);
    say "$key / { $newKey.^name }";

    so g_hash_table_contains_str(self.GHashTable, $newKey);
  }

  method get_values (:$raw = False, :$glist = False, :$typed = Str, :$o)
    is also<get-values>
  {
    my $vl = g_hash_table_get_values(self.GHashTable);

    # GLib::GList.new( g_hash_table_get_values($!h) )
    #   but GLib::Roles::ListData[
    #     $default-value-return == CARRAY ?? CArray !! Pointer
    #   ];

    returnGList($vl, $raw, $glist, $typed, $o)
  }

  multi method insert (Str() $key, Str() $value) {
    sub g_hash_table_insert_str(GHashTable, CArray[uint8] $k, CArray[uint8] $v)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_insert')
      { * }

    so g_hash_table_insert_str(self.GHashTable,
      newCArray(Str, $key),
      newCArray(Str, $value)
    );
  }

  method lookup (Str() $key, :$encoding = 'utf8') {
    sub g_hash_table_lookup_str(GHashTable, CArray[uint8] $k)
      returns CArray[uint8]
      is native(glib)
      is symbol('g_hash_table_lookup')
      { * }

    Buf.new(
      nullTerminatedBuffer(
        g_hash_table_lookup_str( self.GHashTable, newCArray(Str, $key) )
      )
    ).decode($encoding);
  }

  proto method lookup_extended (|)
    is also<lookup-extended>
  { * }

  multi method lookup_extended (Str() $lookup_key, :$all = False) {
    my @return-pointers;
    @return-pointers[0, 1] = newCArray(uint8) xx 2;

    sub g_hash_table_lookup_extended_str (
      GHashTable    $hash_table,
      CArray[uint8] $lookup_key,
      CArray[uint8] $orig_key,
      CArray[uint8] $value
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup_extended')
      { * }


    my $rv = g_hash_table_lookup_extended_str(
      self.GHashTable,
      newCArray(Str, $lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method remove (Str() $key) {
    sub g_hash_table_remove_str (GHashTable, CArray[uint8] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_remove')
      { * }

    so g_hash_table_remove_str( self.GHashTable, newCArray(Str, $key) );
  }

  method replace (Str() $key, Str() $value) {
    sub g_hash_table_replace_str(
      GHashTable,
      CArray[uint8] $k,
      CArray[uint8] $v
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_replace')
      { * }

    so g_hash_table_replace_str(
      self.GHashTable,
      newCArray(Str, $key),
      newCArray(Str, $value)
    );
  }

  method steal (Str() $key) {
    sub g_hash_table_steal_str(GHashTable, CArray[uint8] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_steal')
      { * }

    g_hash_table_steal_str( self.GHashTable, newCArray(Str, $key) );
  }

}

class GLib::HashTable::Integer is GLib::HashTable {
  method new {
    nextwith(&g_int_hash, &g_int_equal);
  }

  method getTypePair {
    GHashTable, GLib::HashTable::Integer
  }

  method add (Int() $key) {
    sub g_hash_table_add_int(GHashTable, CArray[gint] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_add')
      { * }

    so g_hash_table_add_int(
      self.GHashtTable,
      $key
    );
  }

  method contains (Int() $key) {
    sub g_hash_table_contains_int (GHashTable, CArray[gint] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    so g_hash_table_contains_int( self.GHashTable, $key);
  }

  multi method insert (Int() $key, Int() $value) {
    sub g_hash_table_insert_int(GHashTable, CArray[gint] $k, CArray[gint] $v)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_insert')
      { * }

    so g_hash_table_insert_int(
      self.GHashTable,
      newCArray(gint, $key),
      newCArray(gint, $value)
    );
  }

  method lookup (Int() $key) {
    sub g_hash_table_lookup_int(GHashTable, CArray[gint] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup')
      { * }

    my $l = g_hash_table_lookup_int(self.GHashTable, $key);
    $l ?? $l[0] !! Nil;
  }

  proto method lookup_extended (|)
    is also<lookup-extended>
  { * }

  multi method lookup_extended (Int() $lookup_key, :$all = False) {
    my @return-pointers;
    @return-pointers[0, 1] = newCArray(CArray[gint]) xx 2;

    sub g_hash_table_lookup_extended_int (
      GHashTable    $hash_table,
      CArray[gint] $lookup_key,
      CArray[gint] $orig_key,
      CArray[gint] $value
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup_extended')
      { * }


    my $rv = g_hash_table_lookup_extended_int(
      self.GHashTable,
      newCArray(CArray[gint], $lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method remove (Int() $key) {
    sub g_hash_table_remove_int(GHashTable, CArray[gint] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_remove')
      { * }

    so g_hash_table_remove_int(
      self.GHashTable,
      newCArray(CArray[gint], $key )
    );
  }

  method replace (Int() $key, Int() $value) {
    sub g_hash_table_replace_int(
      GHashTable,
      CArray[gint] $k,
      CArray[gint] $v
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_replace')
      { * }

    so g_hash_table_replace_int(
      self.GHashTable,
      newCArray(CArray[gint], $key),
      newCArray(CArray[gint], $value)
    );
  }

  method steal (Int() $key) {
    sub g_hash_table_steal_int(GHashTable, CArray[gint] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_steal')
      { * }

    g_hash_table_steal_int(self.GHashTable, $key);
  }

}

class GLib::HashTable::Int64 is GLib::HashTable {
  method new {
    nextwith(&g_int_hash, &g_int_equal);
  }

  method getTypePair {
    GHashTable, GLib::HashTable::Int64
  }

  method add (Int() $key) {
    sub g_hash_table_add_int64(GHashTable, CArray[gint64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_add')
      { * }

    so g_hash_table_add_int64(
      self.GHashtTable,
      $key
    );
  }

  method contains (Int() $key) {
    sub g_hash_table_contains_int64 (GHashTable, CArray[gint64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    so g_hash_table_contains_int64( self.GHashTable, $key);
  }

  multi method insert (Int() $key, Int() $value) {
    sub g_hash_table_insert_int64(GHashTable, CArray[gint64] $k, CArray[gint64] $v)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_insert')
      { * }

    so g_hash_table_insert_int64(
      self.GHashTable,
      newCArray(int64, $key),
      newCArray(int64, $value)
    );
  }

  method lookup (Int() $key) {
    sub g_hash_table_lookup_int64(GHashTable, CArray[gint64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup')
      { * }

    my $l = g_hash_table_lookup_int64(self.GHashTable, $key);
    $l ?? $l[0] !! Nil;
  }

  proto method lookup_extended (|)
    is also<lookup-extended>
  { * }

  multi method lookup_extended (Int() $lookup_key, :$all = False) {
    my @return-pointers;
    @return-pointers[0, 1] = newCArray(CArray[gint64]) xx 2;

    sub g_hash_table_lookup_extended_int64 (
      GHashTable    $hash_table,
      CArray[gint64] $lookup_key,
      CArray[gint64] $orig_key,
      CArray[gint64] $value
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup_extended')
      { * }


    my $rv = g_hash_table_lookup_extended_int64(
      self.GHashTable,
      newCArray(CArray[gint64], $lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method remove (Int() $key) {
    sub g_hash_table_remove_int64(GHashTable, CArray[gint64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_remove')
      { * }

    so g_hash_table_remove_int64(
      self.GHashTable,
      newCArray(CArray[gint64], $key )
    );
  }

  method replace (Int() $key, Int() $value) {
    sub g_hash_table_replace_int64(
      GHashTable,
      CArray[gint64] $k,
      CArray[gint64] $v
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_replace')
      { * }

    so g_hash_table_replace_int64(
      self.GHashTable,
      newCArray(CArray[gint64], $key),
      newCArray(CArray[gint64], $value)
    );
  }

  method steal (Int() $key) {
    sub g_hash_table_steal_int64(GHashTable, CArray[gint64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_steal')
      { * }

    g_hash_table_steal_int64(self.GHashTable, $key);
  }

}

class GLib::HashTable::Float is GLib::HashTable {
  method new {
    nextwith(&g_double_hash, &g_double_equal);
  }

  method getTypePair {
    GHashTable, GLib::HashTable::Float
  }

  method add (Num() $key) {
    sub g_hash_table_add_float(GHashTable, CArray[num32] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_add')
      { * }

    so g_hash_table_add_float(
      self.GHashtTable,
      $key
    );
  }

  method contains (Num() $key) {
    sub g_hash_table_contains_float (GHashTable, CArray[num32] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    so g_hash_table_contains_float( self.GHashTable, $key);
  }

  multi method insert (Num() $key, Num() $value) {
    sub g_hash_table_insert_float(GHashTable, CArray[num32] $k, CArray[num32] $v)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_insert')
      { * }

    so g_hash_table_insert_float(
      self.GHashTable,
      newCArray(num32, $key),
      newCArray(num32, $value)
    );
  }

  method lookup (Num() $key) {
    sub g_hash_table_lookup_float(GHashTable, CArray[num32] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup')
      { * }

    my $l = g_hash_table_lookup_float(self.GHashTable, $key);
    $l ?? $l[0] !! Nil;
  }

  proto method lookup_extended (|)
    is also<lookup-extended>
  { * }

  multi method lookup_extended (Num() $lookup_key, :$all = False) {
    my @return-pointers;
    @return-pointers[0, 1] = newCArray(CArray[num32]) xx 2;

    sub g_hash_table_lookup_extended_float (
      GHashTable    $hash_table,
      CArray[num32] $lookup_key,
      CArray[num32] $orig_key,
      CArray[num32] $value
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup_extended')
      { * }


    my $rv = g_hash_table_lookup_extended_float(
      self.GHashTable,
      newCArray(CArray[num32], $lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method remove (Num() $key) {
    sub g_hash_table_remove_float(GHashTable, CArray[num32] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_remove')
      { * }

    so g_hash_table_remove_float(
      self.GHashTable,
      newCArray(CArray[num32], $key )
    );
  }

  method replace (Num() $key, Num() $value) {
    sub g_hash_table_replace_float(
      GHashTable,
      CArray[num32] $k,
      CArray[num32] $v
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_replace')
      { * }

    so g_hash_table_replace_float(
      self.GHashTable,
      newCArray(CArray[num32], $key),
      newCArray(CArray[num32], $value)
    );
  }

  method steal (Num() $key) {
    sub g_hash_table_steal_float(GHashTable, CArray[num32] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_steal')
      { * }

    g_hash_table_steal_float(self.GHashTable, $key);
  }

}

class GLib::HashTable::Double is GLib::HashTable {
  method new {
    nextwith(&g_double_hash, &g_double_equal);
  }

  method getTypePair {
    GHashTable, GLib::HashTable::Double
  }

  method add (Num() $key) {
    sub g_hash_table_add_double(GHashTable, CArray[num64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_add')
      { * }

    so g_hash_table_add_double(
      self.GHashtTable,
      $key
    );
  }

  method contains (Num() $key) {
    sub g_hash_table_contains_double (GHashTable, CArray[num64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_contains')
      { * }

    so g_hash_table_contains_double( self.GHashTable, $key);
  }

  multi method insert (Num() $key, Num() $value) {
    sub g_hash_table_insert_double(GHashTable, CArray[num64] $k, CArray[num64] $v)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_insert')
      { * }

    so g_hash_table_insert_double(
      self.GHashTable,
      newCArray(num64, $key),
      newCArray(num64, $value)
    );
  }

  method lookup (Num() $key) {
    sub g_hash_table_lookup_double(GHashTable, CArray[num64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup')
      { * }

    my $l = g_hash_table_lookup_double(self.GHashTable, $key);
    $l ?? $l[0] !! Nil;
  }

  proto method lookup_extended (|)
    is also<lookup-extended>
  { * }

  multi method lookup_extended (Num() $lookup_key, :$all = False) {
    my @return-pointers;
    @return-pointers[0, 1] = newCArray(CArray[num64]) xx 2;

    sub g_hash_table_lookup_extended_double (
      GHashTable    $hash_table,
      CArray[num64] $lookup_key,
      CArray[num64] $orig_key,
      CArray[num64] $value
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_lookup_extended')
      { * }


    my $rv = g_hash_table_lookup_extended_double(
      self.GHashTable,
      newCArray(CArray[num64], $lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method remove (Num() $key) {
    sub g_hash_table_remove_double(GHashTable, CArray[num64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_remove')
      { * }

    so g_hash_table_remove_double(
      self.GHashTable,
      newCArray(CArray[num64], $key )
    );
  }

  method replace (Num() $key, Num() $value) {
    sub g_hash_table_replace_double(
      GHashTable,
      CArray[num64] $k,
      CArray[num64] $v
    )
      returns uint32
      is native(glib)
      is symbol('g_hash_table_replace')
      { * }

    so g_hash_table_replace_double(
      self.GHashTable,
      newCArray(CArray[num64], $key),
      newCArray(CArray[num64], $value)
    );
  }

  method steal (Num() $key) {
    sub g_hash_table_steal_double(GHashTable, CArray[num64] $k)
      returns uint32
      is native(glib)
      is symbol('g_hash_table_steal')
      { * }

    g_hash_table_steal_double(self.GHashTable, $key);
  }

}
