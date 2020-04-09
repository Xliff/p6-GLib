use v6.c;

use Method::Also;
use NativeCall;

use GLib::Object::IsType;
use GLib::Raw::Types;

use GLib::Value;

constant gObjectTypeKey = 'p6-GObject-Type';

my %data;

role GLib::Roles::Object {
  has GObject $!o;

  submethod BUILD (:$object) {
    $!o = $object if $object;
  }

  method gist-data {
    %data.gist;
  }

  method new-object-obj (GObject $object) {
    $object ?? self.bless( :$object ) !! Nil;
  }

  method getImplementor {
    findProperImplementor(self.^attributes);
  }

  method roleInit-Object {
    my \i = findProperImplementor(self.^attributes);
    my $o = i.get_value(self);

    self!setObject($o);
  }

  method !setObject($obj) {
    $!o = $obj ~~ GObject ?? $obj !! cast(GObject, $obj)
  }

  method p { $!o.p }

  multi method Numeric { +self.p }

  method GLib::Raw::Definitions::GObject
  { $!o }

  # Remove when Method::Also is fixed!
  method GObject { $!o }

  # We use these for inc/dec ops
  method ref   is also<upref>   {   g_object_ref($!o); self; }
  method unref is also<downref> { g_object_unref($!o); }

  method check_gobject_type($compare_type) {
    my $o = nativecast(GTypeInstance, $!o);

    $o.checkType($compare_type);
  }

  method get_gobject_type {
    my $o = nativecast(GTypeInstance, $!o);

    $o.getType;
  }

  method setType($typeName) {
    my $oldType = self.getType;
    self.prop_set_string(gObjectTypeKey, $typeName) unless $oldType.defined;
    warn "WARNING -- Using a $oldType as a $typeName"
      unless [||](
        %*ENV<P6_GTK_DEBUG>.defined.not,
        $oldType.defined.not,
        $oldType eq $typeName
      );
  }

  multi method getType {
    self.prop_get_string(gObjectTypeKey);
  }
  multi method getType (::?CLASS:U: GObject $o) {
    g_object_get_string($o, gObjectTypeKey);
  }

  # For storing Raku data types.
  method get-data ($k) {
    %data{+$!o.p}{$k};
  }

  method set-data ($k, $v) {
    say "Setting { $k } to { $v } for { +$!o.p }..." if $DEBUG;

    %data{+$!o.p}{$k} = $v;
  }

  method unset-data ($k) {
    %data{+$!o.p}{$k}:delete if %data{+$!o.p}{$k}:exists;
  }

  method !checkNames(@names) {
    @names.map({
      if $_ ~~ Str {
        $_;
      } else {
        unless .^can('Str').elems {
          die "$_ value cannot be coerced to string.";
        }
        .Str;
      }
    });
  }

  method !checkValues(@values) {
    @values.map({
      if $_ ~~ GValue {
        $_;
      } else {
        unless .^can('GValue').elems {
          die "$_ value cannot be coerced to GValue";
        }
        .gvalue();
      }
    });
  }

  method is_type(GObjectOrPointer $t) {
    is_type($t, self);
  }

  method prop_set(Str() $name, GValue() $value) is also<prop-set> {
    self.set_prop($name, $value);
  }

  proto method set_prop (|)
    is also<set-prop>
  { * }

  multi method set_prop(Str() $name, GValue() $value) {
    samewith( [$name], [$value] );
  }
  multi method set_prop(@names, @values) {
    say "N: { @names.join(', ') }" if $DEBUG;
    say "V0: { @values[0].^name }" if $DEBUG;

    my @n = self!checkNames(@names);
    my @v = self!checkValues(@values);

    die 'Mismatched number of names and values when setting GObject properties.'
      unless +@n == +@v;

    my guint $ne = @n.elems;

    die 'Cannot set properties with an empty array!' unless $ne > 0;

    say "V1: { @v[0].p }" if $DEBUG;

    g_object_setv( $!o, $ne, ArrayToCArray(Str, @names), @v[0].p );
  }

  method prop_get(Str() $name, $value is copy, :$raw = True)
    is also<prop-get>
  {
    my $compatible = $value ~~ GValue;
    my $coercible  = $value.^lookup('GValue');

    die '$value must be GValue-compatible!' unless $compatible || $coercible;

    $value .= GValue if $coercible && $value ~~ GLib::Value;

    self.get_prop($name, $value, :$raw);
  }

  proto method get_prop (|)
    is also<get-prop>
  { * }

  multi method get_prop (Str $name, Int $type, :$raw = True) {
    my @v = ( GLib::Value.new($type).GValue );

    samewith( [ $name ], @v );
    $raw ?? @v[0].GValue !! @v[0];
  }
  multi method get_prop (Str() $name, GLib::Value $value, :$raw = True) {
    my $vp = $value.GValue;

    samewith($name, $vp);
    $raw ?? $vp !! $value;
  }
  multi method get_prop (Str() $name, GValue $value, :$raw = True) {
    my @v = ($value);

    samewith( $name.Array, @v );
    $raw ?? $value !! GLib::Value.new($value);
  }
  multi method get_prop (@names, @values) {
    my @n = self!checkNames(@names);
    my @v = self!checkValues(@values);

    die 'Mismatched number of names and values when setting GObject properties.'
      unless +@n == +@v;

    my CArray[Str] $n = CArray[Str].new;
    my $i = 0;
    $n[$i++] = $_ for @n;
    # my CArray[GValue] $v = CArray[GValue].new;
    # $i = 0;
    # $v[$i++] = $_ for @v;

    # -XXX- NOT a general purpose fix, but will work for now.
    my guint32 $ne = $n.elems;
    die 'Cannot get properties with an empty array!' unless $ne > 0;

    g_object_getv( $!o, $ne, $n, @v[0].p );

    # @values = ();
    # @values.push( GLib::Value.new($v[$_]) ) for (^$v.elems);

    # Be perlish with the return. -- Maybe do @values[$_].value
    %(do for (^@names.elems) {
      @names[$_] => @values[$_];
    });
  }

  method prop_set_bool(Str() $key, Int() $val)
    is also<prop-set-bool>
  {
    my gboolean $v = $val.so.Int;

    self.prop_set_uint_data($v);
  }

  method prop_get_bool (Str() $key) is also<prop-get-bool> {
    so self.prop_get_uint_data($key);
  }

  method prop_set_string(Str() $key, Str() $val)
    is also<prop-set-string>
  {
    g_object_set_string_data($!o, $key, $val);
  }

  method prop_get_string(Str() $key) is also<prop-get-string> {
    g_object_get_string_data($!o, $key);
  }

  method prop_set_ptr (Str() $key, Pointer $val = Pointer)
    is also<prop-set-ptr>
  {
    g_object_set_ptr_data($!o, $key, $val);
  }

  method prop_get_ptr (Str() $key) is also<prop-get-ptr> {
    g_object_get_ptr_data($!o, $key);
  }

  method prop_set_int (Str() $name, Int() $value) is also<prop-set-int> {
    g_object_set_int_data($!o, $name, $value);
  }

  method prop_get_int (Str() $name) is also<prop-get-int> {
    my $a = g_object_get_int_data($!o, $name);

    ( $a && $a[0] ) ?? $a[0] !! Nil;
  }

  method prop_set_uint (Str() $name, Int() $value) is also<prop-set-uint> {
    my $v = CArray[guint].new;
    $v[0] = $value;

    g_object_set_uint_data($!o, $name, $v);
  }

  method prop_get_uint(Str() $name) is also<prop-get-uint> {
    my $a = g_object_get_uint_data($!o, $name);

    ( $a && $a[0] ) ?? $a[0] !! Nil;
  }

  method delete_data (Str() $key) {
    %data{+$!o.p}{$key}:delete;
  }

  method clear_data (Str() $key) is also<clear-data> {
    g_object_set_ptr($!o, $key, Pointer);
  }

  method !get_data_abstract(@keys, ::T, &f) {
    @keys = @keys.map({
      die 'Elements in @keys must be Str-compatible!'
        unless $_ ~~ Str || .^lookup('Str');
      .Str;
    });

    my @a = do for @keys {
      my NT $v = 0;

      f($key, $v, Str);
      $v;
    };

    @a.elems > 1 ?? @a !! @a[0];
  }

  method get_data_int64 (*@keys) {
    self!get-data-abstract(@keys,  gint64, &g_double_get_int64);
  }
  method get_data_uint64 (*@keys) {
    self!get-data-abstract(@keys, guint64, &g_double_get_uint64);
  }
  method get_data_int (*@keys) {
    self!get-data-abstract(@keys,    gint, &g_double_get_int);
  }
  method get_data_uint (*@keys) {
    self!get-data-abstract(@keys,   guint, &g_double_get_uint);
  }
  method get_data_string (*@keys) {
    self!get-data-abstract(@keys,     Str, &g_double_get_string);
  }
  method get_data_float (*@keys) {
    self!get-data-abstract(@keys, gdouble, &g_double_get_float);
  }
  method get_data_double (*@keys) {
    self!get-data-abstract(@keys, gdouble, &g_double_get_double);
  }

  method !set_data_abstract(@paors, ::T, ::NT, $value, &f) {
    @pairs = @pairs.rotor(2).map({
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[0] ~~ Str || .^lookup('Str');
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[1] ~~ T || (my $m = .^lookup(T.^name));

      ( .[0].Str, $m(.[1]) );
    )}

    for @pairs {
      my NT $v = $value;

      f($key, $v, Str);
    }
  }

  method set_data_int64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int,  gint64, &g_double_set_int64);
  }
  method set_data_uint64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int, guint64, &g_double_set_uint64);
  }
  method set_data_int (*@pairs) {
    self!set-data-abstract(@pairs,  Int,    gint, &g_double_set_int);
  }
  method set_data_uint (*@pairs) {
    self!set-data-abstract(@pairs,  Int,   guint, &g_double_set_uint);
  }
  method set_data_string (*@pairs) {
    self!set-data-abstract(@pairs,  Str,     Str, &g_double_set_string);
  }
  method set_data_float (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_double_set_float);
  }
  method set_data_double (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_double_set_double);
  }

}
