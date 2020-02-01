use v6.c;

use Method::Also;
use NativeCall;

use GLib::Object::IsType;
use GLib::Raw::Types;

use GLib::Value;

constant gObjectTypeKey = 'p6-GObject-Type';

role GLib::Roles::Object {
  has GObject $!o;

  submethod BUILD (:$object) {
    $!o = $object;
  }

  method new-object-obj (GObject $object) {
    self.bless( :$object );
  }

  method roleInit-Object {
    my \i = findProperImplementor(self.^attributes);

    $!o = cast( GObject, i.get_value(self) );
  }

  method !setObject($obj) {
    $!o = nativecast(GObject, $obj);
  }

  method GLib::Raw::Types::GObject
    is also<GObject>
  { $!o }

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

  method get_data_bool (Str() $key)
    is also<get-data-bool>
  {
    so self.get_data_uint($key);
  }
  method set_data_bool(Str() $key, Int() $val)
    is also<set-data-bool>
  {
    my gboolean $v = $val.so.Int;

    self.set_data_uint($v);
  }

  method get_data_string(Str() $key)
    is also<get-data-string>
  {
    g_object_get_string($!o, $key);
  }
  method set_data_string(Str() $key, Str() $val)
    is also<set-data-string>
  {
    g_object_set_string($!o, $key, $val);
  }

  method get_data_uint(Str() $key)
    is also<get-data-uint>
  {
    my $pi = g_object_get_uint($!o, $key);

    $pi.defined ?? $pi[0] !! Nil;
  }
  method set_data_uint(Str() $key, Int() $val)
    is also<set-data-uint>
  {
    my $v = CArray[guint].new;

    $v[0] = $val;
    g_object_set_uint($!o, $key, $v);
  }

  method get_data_int(Str() $key)
    is also<get-data-int>
  {
    my $pi = g_object_get_int($!o, $key);

    $pi.defined ?? $pi[0] !! Nil;
  }
  method set_data_int(Str() $key, Int() $val)
    is also<set-data-int>
  {
    my $v = CArray[gint].new;

    $v[0] = $val;
    g_object_set_int($!o, $key, $v);
  }

  method set_data_ptr(Str() $key, Pointer $val = Pointer)
    is also<set-data-ptr>
  {
    g_object_set_ptr($!o, $key, $val);
  }
  method get_data_ptr(Str() $key)
    is also<get-data-ptr>
  {
    g_object_get_ptr($!o, $key);
  }

  method setType($typeName) {
    my $oldType = self.getType;
    self.set_data_string(gObjectTypeKey, $typeName) unless $oldType.defined;
    warn "WARNING -- Using a $oldType as a $typeName"
      unless [||](
        %*ENV<P6_GTK_DEBUG>.defined.not,
        $oldType.defined.not,
        $oldType eq $typeName
      );
  }

  multi method getType {
    self.get_data_string(gObjectTypeKey);
  }
  multi method getType (::?CLASS:U: GObject $o) {
    g_object_get_string($o, gObjectTypeKey);
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
    my @n = self!checkNames(@names);
    my @v = self!checkValues(@values);

    die 'Mismatched number of names and values when setting GObject properties.'
      unless +@n == +@v;

    my guint $ne = @n.elems;

    die 'Cannot set properties with an empty array!' unless $ne > 0;
    g_object_setv( $!o, $ne, ArrayToCArray(Str, @names), @v[0].p );
  }

  method prop_get(Str() $name, GValue() $value) is also<prop-get> {
    self.get_prop($name, $value.g_type);
  }

  proto method get_prop (|)
    is also<get-prop>
  { * }

  multi method get_prop(Str $name, Int $type, :$raw = False) {
    my @v = ( GLib::Value.new($type).GValue );

    samewith( [ $name ], @v );
    $raw ?? @v[0].GValue !! @v[0];
  }
  multi method get_prop(Str() $name, GLib::Value $value) {
    samewith($name, $value.GValue);
  }
  multi method get_prop(Str() $name, GValue $value) {
    my @v = ($value);

    samewith( $name.Array, @v );
  }
  multi method get_prop(@names, @values) {
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
    my $ne = $n.elems;
    die 'Cannot get properties with an empty array!' unless $ne > 0;
    g_object_getv( $!o, $ne, $n, @v[0].p );

    # @values = ();
    # @values.push( GLib::Value.new($v[$_]) ) for (^$v.elems);

    # Be perlish with the return. -- Maybe do @values[$_].value
    %(do for (^@names.elems) {
      @names[$_] => @values[$_];
    });
  }

  method prop_get_int(Str() $name) is also<prop-get-int> {
    my $a = g_object_get_int($!o, $name);
    $a[0];
  }

  method prop_set_int (Str() $name, Int() $value) is also<prop-set-int> {
    g_object_set_int($!o, $name, $value, Str);
  }

  method prop_get_uint(Str() $name) {
    my $a = g_object_get_uint($!o, $name);

    $a[0];
  }

  method prop_set_uint (Str() $name, Int() $value) is also<prop-set-uint> {
    g_object_set_uint($!o, $name, $value, Str);
  }

}
