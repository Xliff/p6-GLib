use v6.c;

use NativeCall;
use NativeHelpers::Blob;

use GLib::Raw::Types;
use GLib::Raw::HashTable;

use GLib::GList;

INIT {
  say qq:to/S/ unless %*ENV<P6_BUILDING_GTK>.so;
»»»»»»
» Please note that the objects in { $?FILE } are classed as use-at-your-own-risk!
» Accessing an object created from C should be usable, but creating objects of
» this type, via Raku, may behave erratically.
»»»»»»
S

}

# Oy-ya-mama! The issues with this class. Let me start on the fact that it's
# all POINTER BASED. This is easy for C, but not so easy for Perl6 given
# the differences in typing system.. So let's try and determine scope.
#  - This object will handle keys of native types (Int, Str, Num, CStruct, CPointer)
#    - These will be handled via a nativecast to Pointer
#  - This object is to handle values of all primative types. (Str, Num, Int)
#    - Int and Num types will be converted to the native equivalent and passed
#      via CArray[::T][0]
#    - By extension, this means that this object will also handle all GObject derivatives
#       - These will be handled via a nativecast to Pointer

class GLib::HashTable::String { ... }

class GLib::HashTable does Associative {
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
  { $!h }

  # Really, the only thing that's needed.
  # Look into the diff between %tabe and *%table.
  multi method new (
    %table,
    :$key-encoding = 'utf8',
    :$key-double   = True,
    :$key-signed   = False,
    :$val-encoding = 'utf8',
    :$val-double   = True,
    :$val-signed   = False
  ) {
    my $o = GLib::HashTable::String.new(&g_str_hash, &g_str_equal);
    for %table.keys {
      $o.insert(
        $_,
        %table{$_},
        :$key-encoding,
        :$key-double,
        :$key-signed,
        :$val-encoding,
        :$val-double,
        :$val-signed,
      )
    }
    $o;
  }

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
    &hash_func,
    &key_equal_func
  ) {
    my $hash-table = g_hash_table_new(&hash_func, &key_equal_func);

    $hash-table ?? self.bless( :$hash-table ) !! Nil;
  }

  method new_full (
    # THESE PARAMETERS WILL NOT WORK. See above.
    # (2 years later): Again... why not?
    &hash_func,
    &key_equal_func,
    GDestroyNotify $key_destroy_func   = Pointer,
    GDestroyNotify $value_destroy_func = Pointer
  ) {
    g_hash_table_new_full(
      &hash_func,
      &key_equal_func,
      $key_destroy_func,
      $value_destroy_func
    );
  }

  method add (
    $key       is copy,
    :$encoding =  'utf8',
    :$double   =  True,
    :$signed   =  False
  ) {
    g_hash_table_add(
      $!h,
      toPointer($key, :$encoding, :$double, :$signed)
    );
  }

  method contains (
    $key       is copy,
    :$encoding =  'utf8',
    :$double   =  True,
    :$signed   =  False,
    :$typed    =  Str
  ) {
    say "H: { $!h }";
    say ".contains K: { $key }";

    # cw: Broken, again. We need to grab the key type at object creation
    #     time as the key routines DEPEND on it, and up til now, we've
    #     been depending on Str semantics, rather than generic-value
    #     semantics.

    #$key = toPointer($key, :$encoding, :$double, :$signed, :$typed);
    #say "after cast (Str): { $key }";

    so g_hash_table_contains($!h, $key);
  }

  method destroy {
    g_hash_table_destroy($!h);
  }

  method find (&predicate, gpointer $user_data) {
    g_hash_table_find($!h, &predicate, $user_data);
  }

  method foreach (&func, gpointer $user_data) {
    g_hash_table_foreach($!h, &func, $user_data);
  }

  method foreach_remove (&func, gpointer $user_data) {
    g_hash_table_foreach_remove($!h, &func, $user_data);
  }

  method foreach_steal (&func, gpointer $user_data) {
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

  method get_keys (:$raw = False, :$glist = False, :$type = Str, :$o) {
    my $kl = g_hash_table_get_keys($!h);

    returnGList($kl, :$raw, :$glist, :$type, :$o)
  }

  # Keys can be of various types, so no easy way to do this. Will have to
  # consider the various options: Str, int32, int64, double, Pointer

  proto method get_keys_as_array (|)
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

  # cw: Will return a lsit of CArray or Pointers -- Caller determines type!
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

  method get_values (:$return = $default-value-return) {
    GLib::GList.new( g_hash_table_get_values($!h) )
      but GLib::Roles::ListData[
        $default-value-return == CARRAY ?? CArray !! Pointer
      ];
  }

  # cw: Shall use a hash of key => TYPE pairs. This matching is valid for the
  # last time key was stored, and will be used as a DEFAULT at lookup
  # time. When using the Associative interface, this object will always
  # do its best to return a typed value. If you want a RAW value returned,
  # use .lookup(:raw)
  #
  # Must provide a mechanism for setting this dictionary for when the
  # GHashTable is created by C.
  multi method insert (
    $key,
    $value,
    :$val-typed,
    :$key-typed    = Str,
    :$key-encoding = 'utf8',
    :$key-double   = True,
    :$key-signed   = False,
    :$val-encoding = 'utf8',
    :$val-double   = True,
    :$val-signed   = False,
  ) {
    so g_hash_table_insert(
      $!h,
      toPointer(
        $key,
        encoding => $key-encoding,
        double   => $key-double,
        signed   => $key-signed,
        typed    => $key-typed
      ),
      toPointer(
        $value,
        encoding => $val-encoding,
        double   => $val-double,
        signed   => $val-signed,
        typed    => $val-typed // $value.WHAT
      )
    );
  }

  multi method setDictionary (*%dict) {
    samewith(%dict)
  }
  multi method setDictionary (%dict) {
    %!dict = %dict;
  }

  # --- START -- For Role Associative
  method ASSIGN-KEY (\k, \v) {
    %!dict{k} = v.WHAT;
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
  # --- END -- For Role Associative

  method lookup (
    $key,
    :$typed    = %!dict{$key},
    :$encoding = 'utf8',
    :$double   = True,
    :$signed   = False,
  ) {
    my $v = g_hash_table_lookup(
      $!h,
      toPointer($key)
    );

    # cw: Return a typed value if :$typed
    if $typed !=== Nil {
      $v = do given $typed {
        when Int {
          my \t = $double ?? ( $signed ?? int64 !! uint64 )
                          !! ( $signed ?? int32 !! uint32 );

          cast(CArray[t], $v)[0];
        }

        when Num {
          cast(CArray[$double ?? num64 !! num32], $v)[0]
        }

        when Str {
          cast(Str, $v)
        }

        when .REPR eq <CStruct CPointer>.any {
          cast($_, $v);
        }
      }
    }
    $v;
  }

  proto method lookup_extended (|)
  { * }

  multi method lookup_extended (
    $lookup_key,
    :$encoding = 'utf8',
    :$double   = True,
    :$signed   = False,
  ) {
    samewith($lookup_key, $, $, :all, :$encoding, :$double, :$signed);
  }
  multi method lookup_extended (
    $lookup_key,
    $orig_key    is               rw,
    $value       is               rw,
                 :$all          = False,
                 :$key-encoding = 'utf8',
                 :$key-double   = True,
                 :$key-signed   = False,
                 :$val-type

  ) {
    my @return-pointers = CArray[Pointer].new;
    @return-pointers[0, 1] = Pointer.new(0) xx 0;

    my $rv = g_hash_table_lookup_extended(
      $!h,
      toPointer($lookup_key),
      @return-pointers[0],
      @return-pointers[1]
    );

    if $val-type {
      @return-pointers[1] = do given $val-type {
        when int32 | int64 | num32 | num64 {
          cast(Pointer[$_], @return-pointers[1]).deref
        }

        when Str {
          cast(Str, @return-pointers[1])
        }

        when .REPR eq <CPointer CStruct> {
          cast($_, @return-pointers[1]);
        }

        default {
          die "Don't know how to handle $val-type of { $val-type.^name }"
        }
      }
    }

    $all ?? $rv !! ($rv, |@return-pointers);
  }

  method ref {
    g_hash_table_ref($!h);
  }

  method remove (
    $key,
    :$encoding = 'utf8',
    :$double   = True,
    :$signed   = False,
  ) {
    g_hash_table_remove(
      $!h,
      toPointer($key, :$encoding, :$double, :$signed)
    );
  }

  method remove_all {
    g_hash_table_remove_all($!h);
  }

  method replace (
    $key,
    $value,
    :$key-encoding   = 'utf8',
    :$key-signed     = False,
    :$key-double     = False,
    :$value-encoding = 'utf8',
    :$value-signed   = False,
    :$value-double   = False
  ) {
    g_hash_table_replace(
      $!h,
      toPointer(
        $key,
        encoding => $key-encoding,
        signed   => $key-signed,
        double   => $key-double
      ),
      toPointer(
        $value,
        encoding => $value-encoding,
        signed   => $value-signed,
        double   => $value-double
      ),
    );
  }

  method size {
    g_hash_table_size($!h);
  }

  method steal (
    $key,
    :$encoding = 'utf8',
    :$double   = True,
    :$signed   = False,
  ) {
    g_hash_table_steal(
      $!h,
      toPointer($key, :$encoding, :$double, :$signed)
    );
  }

  method steal_all {
    g_hash_table_steal_all($!h);
  }

  proto method steal_extended (|)
  { * }

  multi method steal_extended (
    $lookup_key,
    :$encoding    =  'utf8',
    :$double      =  True,
    :$signed      =  False
  ) {
    my $rv = samewith($lookup_key, $, $, :all, :$encoding, :$double, :$signed);

    $rv ?? $rv.skip(1) !! Nil;
  }
  multi method steal_extended (
    $lookup_key,
    $stolen_key   is rw,
    $stolen_value is rw,
    :$all         =  False,
    :$encoding    =  'utf8',
    :$double      =  True,
    :$signed      =  False
  ) {
    my @return-pointers = CArray[Pointer].new;
    @return-pointers[0, 1] = Pointer.new(0) xx 2;

    my $rv = g_hash_table_steal_extended(
      $!h,
      toPointer($lookup_key, :$encoding, :$double, :$signed),
      |@return-pointers
    );
    ($stolen_key, $stolen_value) = @return-pointers;

    $all.not ?? $rv !! ($rv, |@return-pointers);
  }

  method unref {
    g_hash_table_unref($!h);

  }

}

class GLib::HashTable::String is GLib::HashTable {
  method new {
    nextwith(&g_str_hash, &g_str_equal);
  }
}

class GLib::HashTable::Int is GLib::HashTable {
  method new {
    nextwith( &g_int_hash, &g_int_equal, type => int32 );
  }
}

class GLib::HashTable::Int64 is GLib::HashTable {
  method new {
    nextwith( &g_int64_hash, &g_int64_equal, type => int64);
  }
}

class GLib::HashTable::Double is GLib::HashTable {
  method new {
    self.new( &g_double_hash, &g_double_equal, type => num64);
  }
}

# OPAQUE STRUCT

class GLib::HashTableIter {
  has GHashTableIter $!hi;

  method GLib::Raw::Definitions::GHashTableIter
  { $!hi }

  method get_hash_table {
    GLib::HashTable.new(
      g_hash_table_iter_get_hash_table($!hi)
    );
  }

  method init (GHashTable() $hash_table) {
    my $i = GHashTableIter;
    self.bless( iter => g_hash_table_iter_init($i, $hash_table) );
  }

  method next (Pointer $key, Pointer $value) {
    so g_hash_table_iter_next($!hi, $key, $value);
  }

  method remove {
    g_hash_table_iter_remove($!hi);
  }

  method replace (Pointer $value) {
    g_hash_table_iter_replace($!hi, $value);
  }

  method steal {
    g_hash_table_iter_steal($!hi);
  }

}
