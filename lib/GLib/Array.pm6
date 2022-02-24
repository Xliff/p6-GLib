use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Array;

use GLib::Roles::TypedBuffer;
use GLib::Roles::Implementor;

class GLib::Array {
  also does Positional;
  also does GLib::Roles::Implementor;

  has GArray $!a is implementor handles<p>;
  has        $!ca;

  submethod BUILD (:$array, :$typed) {
    $!a  = $array;
    self.setType($typed) unless $typed === Any
  }

  submethod DESTROY {
    self.downref;
  }

  # The "garray" alias is legacy and can be removed if not in use.
  method GLib::Raw::Definitions::GArray
    is also<
      GArray
      garray
    >
  { $!a }

  method Array {
    my @array;
    @array.push( $!ca[$_] ) for ^self.elems;
    @array;
  }

  proto method new (|)
  { * }

  # $ref is false due to warning when wrapping GPtrArrays
  multi method new (GArray $array, :$typed, :$ref = False) {
    return Nil unless $array;

    my $o = self.bless( :$array, :$typed );
    $o.upref if $ref;
    $o;
  }
  multi method new (
    @values,
    :$typed is required,
    :$signed,
    :$double,
    :$direct
  ) {
    my $o = samewith(
      False,
      True,
      nativeSized($typed, :$double),
      :$typed,
    );

    #say "V: { @values.gist }";

    #state $c = 0;
    my $num-values = @values.elems;
    for @values.kv -> $k, $v {
      #say "Attempting to append #{ $k + 1 } / { $num-values }: { $v }";
      $o.append_vals($v, 1, :$typed, :$signed, :$double, :$direct);
      #exit if $c++ > 20;
    }
    $o;
  }
  multi method new (
    Int() $zero_terminated,
    Int() $clear,
    Int() $element_size,
          :$typed
  ) {
    my guint ($zt, $c, $es) = ($zero_terminated, $clear, $element_size);
    my       $a             = g_array_new($zt, $c, $es);

    $a ?? self.bless( array => $a, :$typed ) !! Nil;
  }

  multi method new (
    Int() $zero_terminated,
    Int() $clear,
    Int() $element_size,
    Int() $reserved_size,
    :$sized is required,
    :$typed
  ) {
    self.sized_new(
      $zero_terminated,
      $clear,
      $element_size,
      $reserved_size,
      :$typed
    );
  }
  method sized_new (
    Int() $zero_terminated,
    Int() $clear,
    Int() $element_size,
    Int() $reserved_size,
    :$typed
  )
    is also<
      sized-new
      new_sized
      new-sized
    >
  {
    my guint ($zt, $c, $es, $rs) =
      ($zero_terminated, $clear, $element_size, $reserved_size);
    my $a =  g_array_sized_new($zt, $c, $es, $rs);

    $a ?? self.bless( array => $a, :$typed ) !! Nil;
  }

  method setType (\t = Mu) {
    use NativeCall;

    die 'Cannot use Mu as a type!' unless t !=:= Mu;

    $!ca = cast(CArray[Pointer[t]], $!a.data);
  }

  method AT-POS (\k) {
    unless $!ca {
      warn 'Cannot use as Positional until .setType is called!';
      return Nil;
    }

    die X::OutOfRange.new( payload => "Index { k } does not exist!" )
      unless k < self.elems;

    $!ca[k];
  }

  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ PROPERTIES ↓↓↓↓
  # ↑↑↑↑ PROPERTIES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  proto method append_vals (|)
    is also<append-vals>
  { * }

  multi method append_vals (
          $data where * !~~ gpointer,
    Int() $len,
          :$typed,
          :$double,
          :$signed,
          :$direct
  ) {
    # cw: There is no collective for NativeCallTypeObjects so we have to do things
    #     the hard way
    samewith(gpointer, 1) if $data === int8           ||
                             $data === int16          ||
                             $data === int32          ||
                             $data === int64          ||
                             $data === uint8          ||
                             $data === uint16         ||
                             $data === uint32         ||
                             $data === uint64         ||
                             $data === num32          ||
                             $data === num64          ||
                             $data === gpointer       ||
                             $data === Str            ||
                             $data === str            ||
                             $data.defined.not && (
                               $data.REPR eq 'CArray'   ||
                               $data.REPR eq 'CPointer' ||
                               $data.REPR eq 'CStruct'  ||
                               $data.REPR eq 'CUnion'
                             );

    samewith(
      toPointer($data, :$typed, :$signed, :$double, :$direct),
      $len
    );
  }
  multi method append_vals (gpointer $data, Int() $len) {
    my guint $l = $len;

    g_array_append_vals($!a, $data, $l);
    self;
  }

  method elems {
    $!a.len;
  }

  method free (Int() $free_segment) {
    my gboolean $fs = $free_segment;

    g_array_free($!a, $fs);
  }

  method get_element_size
    is also<
      get-element-size
      element_size
      element-size
    >
  {
    g_array_get_element_size($!a);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_array_get_type, $n, $t );
  }

  method insert_vals (Int() $index, gpointer $data, Int() $len)
    is also<insert-vals>
  {
    my guint ($i, $l) = ($index, $len);

    g_array_insert_vals($!a, $i, $data, $l);
    self;
  }

  method prepend_vals (gpointer $data, Int() $len) is also<prepend-vals> {
    my guint $l = $len;

    g_array_prepend_vals($!a, $data, $l);
    self;
  }

  method ref is also<upref> {
    g_array_ref($!a);
    self;
  }

  method remove_index (Int() $index) is also<remove-index> {
    my guint $i = $index;

    g_array_remove_index($!a, $index);
    self;
  }

  method remove_index_fast (Int() $index) is also<remove-index-fast> {
    my guint $i = $index;

    g_array_remove_index_fast($!a, $i);
    self;
  }

  method remove_range (Int() $index, Int() $length) is also<remove-range> {
    my guint ($i, $l) = ($index, $length);

    g_array_remove_range($!a, $i, $l);
    self;
  }

  method set_clear_func (GDestroyNotify $clear_func) is also<set-clear-func> {
    g_array_set_clear_func($!a, $clear_func);
  }

  method sort (GCompareFunc $compare_func) {
    g_array_sort($!a, $compare_func);
  }

  method sort_with_data (
    GCompareDataFunc $compare_func,
    gpointer $user_data = gpointer
  )
    is also<sort-with-data>
  {
    g_array_sort_with_data($!a, $compare_func, $user_data);
  }

  method unref is also<downref> {
    g_array_unref($!a);
  }

  # ↑↑↑↑ METHODS ↑↑↑↑

}

sub value_array_get_type is export {
  state ($n, $t);

  unstable_get_type( 'ValueArray', &g_value_array_get_type, $n, $t );
}
sub value-array-get-type is export {
  value_array_get_type;
}

sub byte_array_get_type is export {
  state ($n, $t);

  unstable_get_type( 'ByteArray', &g_value_array_get_type, $n, $t );
}
sub byte-array-get-type is export {
  byte_array_get_type;
}

sub ptr_array_get_type is export {
  state ($n, $t);

  unstable_get_type( 'PtrArray', &g_ptr_array_get_type, $n, $t );
}
sub ptr-array-get-type is export {
  ptr_array_get_type;
}
