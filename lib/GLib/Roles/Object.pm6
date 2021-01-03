use v6.c;

use Method::Also;
use NativeCall;

use GLib::Object::IsType;
use GLib::Raw::Types;

use GLib::Value;;
use GLib::Object::Type;

use GLib::Class::Object;

use GLib::Roles::Bindable;
use GLib::Roles::TypedBuffer;

use GLib::Roles::Signals::Generic;

constant gObjectTypeKey = 'p6-GObject-Type';

my %data;

# To be rolled into GLib::Roles::Object at some point!
role GLib::Roles::Signals::GObject does GLib::Roles::Signals::Generic {
  has %!signals-object;

  method disconnect-object-signal ($name) {
    self.disconnect($name, %!signals-object);
  }

  # GObject, GParamSpec, gpointer
  method connect-notify (
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals-object{$signal} //= do {
      my $s = Supplier.new;
      $hid = g_connect_notify($obj, $signal,
        -> $, $ps, $ud --> gboolean {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $ps, $ud] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-object{$signal}[0].tap(&handler) with &handler;
    %!signals-object{$signal}[0];
  }

}

# cw: Time to grow up.
role GLib::Roles::Object {
  also does GLib::Roles::Bindable;
  also does GLib::Roles::Signals::GObject;

  has GObject $!o;

  submethod BUILD (:$object) {
    self!setObject($object) if $object;
  }

  # This will not work while ::Object is still a role!
  # method attributes ($key) {
  #   X::GLib::Object::AttributeNotFound.new(attribute => $key).throw;
  # }

  method gist-data {
    %data.gist;
  }

  method initAllRoles ($prefix) {
    self.?"roleInit-{ $prefix.tc }{ .[1] }"()
      for self.^roles.unique
                     .map({ [ .^name, .^shortname ] })
                     .grep({
                       [&&](
                         .[0].starts-with($prefix),
                         .[0].contains('Signals').not
                       )
                     });
  }

  method new-object-obj (GObject $object) {
    $object ?? self.bless( :$object ) !! Nil;
  }

  method new-object-ptr (Int() $type) {
    my GType $t = $type;

    g_object_new($t, Str);
  }

  proto method new_object_with_properties (|)
    is also<new-object-with-properties>
  { * }

  multi method new_object_with_properties (*@args) {
    die 'Array passed to .new_object_with_properties must have an even number of elements!'
      unless @args.elems % 2 == 0;

    samewith( |@args.Hash )
  }
  multi method new_object_with_properties (:$raw = False, *%props) {
    my (@names, @values);

    my %v-props = self.resolveCreationOptions( |%props );
    for %v-props.keys {
      @names.push:  $_;
      @values.push: %v-props{$_};
    }

    samewith(
      @names.elems,
      ArrayToCArray(Str, @names),
      GLib::Roles::TypedBuffer[GValue].new(@values),
      :$raw
    );
  }
  multi method new_object_with_properties (
    Int()       $num-props,
    CArray[Str] $names,
    Pointer     $values,
                :$raw       = False
  ) {
    my guint $n = $num-props;
    my GType $t = ::?CLASS.get-type;

    say "T: $t" if $DEBUG;

    my $object = g_object_new_with_properties(
      $t,
      $n,
      $names,
      $values
    );

    $object ?? ( $raw ?? $object !! self.bless( :$object ) )
            !! Nil;
  }

  # Not inherited. Punned directly to the object. So how is that gonna work?
  method resolveCreationOptions (*%options) {
    my (%new-opts; %not-found);

    say "A: { self.attributes.gist }" if $DEBUG;
    say "O: { %options.keys }"        if $DEBUG;

    for %options.pairs -> $a {
      say "K: { $a.key }" if $DEBUG;

      next if $a.value ~~ (GValue, GLib::Value).any;
      if self.attributes( $a.key ) -> $attr {
        say "V: { $attr !~~ Array
                    ?? $attr
                    !! ($attr[0], $attr[1].^name, $attr[2]).join(', ') }"
        if $DEBUG;

        # cw: Will NOT be able to handle ancestor attributes until ::Object
        #     becomes a class.
        given $attr {
          my $v = $a.value;

          when Array {

            quietly {
              # cw: WTF are UNDEF warnings being emitted on the 'when' lines,
              #     when there's no case of anything undef being used in
              #     string context, here! These needed to be muted, hence
              #     the `quietly` block. 09/10/2020

              when 'enum' {
                # ['enum', EnumTypeObject, EnumGType:optional ]
                .value = GLib::Value(
                  .[2].defined ?? .[2] !! GLib::Value.gtypeFromEnum( .[1] )
                );
                .value.valueFromEnum( .[1] ) = $v;
              }

              when 'boxed' | 'object' {
                # [ '<boxed | object>', ObjectType, ObjectGType ]
                my $meth = $_;
                $meth = 'pointer' if $meth eq 'boxed';

                  .value = GLib::Value.new( .[2] );
                  # cw: Assign .value the Pointer representation of an object, and
                  #     if necessary, coerce.s
                  .value."{ .[0] }"() =
                    ( $v ~~ .[1] ) ?? $v
                                   !! $v."{ .[1].^shortname }"()
              }
            }

            default {
              die "Invalid type! Valid attribute types are: 'boxed', 'enum' and 'object'"
                unless .[0] eq <boxed object>.any;
            }
          }

          when G_TYPE_OBJECT  { %new-opts{$a.key} = gv_obj($v)    }
          when G_TYPE_INT     { %new-opts{$a.key} = gv_int($v)    }
          when G_TYPE_UINT    { %new-opts{$a.key} = gv_uint($v)   }
          when G_TYPE_INT64   { %new-opts{$a.key} = gv_int64($v)  }
          when G_TYPE_UINT64  { %new-opts{$a.key} = gv_uint64($v) }
          when G_TYPE_STRING  { %new-opts{$a.key} = gv_str($v)    }
          when G_TYPE_FLOAT   { %new-opts{$a.key} = gv_flt($v)    }
          when G_TYPE_DOUBLE  { %new-opts{$a.key} = gv_dbl($v)    }
          when G_TYPE_BOOLEAN { %new-opts{$a.key} = gv_bool($v)   }
          when G_TYPE_POINTER { %new-opts{$a.key} = gv_ptr($v)    }
        }
        #%options{ $a.key }:delete;
      }
    }

    %new-opts;
  }

  method getImplementor {
    findProperImplementor(self.^attributes);
  }

  method roleInit-Object {
    my \i = findProperImplementor(self.^attributes);
    my $o = i.get_value(self);

    self!setObject($o);
  }

  method getClass (:$raw = False) {
    self.ρ-getClass(GObjectClass, ::('GLib::Class::Object'), :$raw);
  }
  method ρ-getClass ($CS is raw, $C is raw, :$raw = True) {
    my $p := cast(Pointer.^parameterize($CS), $!o.g_type_instance.g_class);
    my $c := $CS.REPR eq 'CStruct' ?? $p.deref !! $p;

    $c ??
      ( $raw ?? $c !! $C.new($c) )
      !!
      Nil;
  }

  # Move to camelCase for routines I've added to distinguish them from
  # GLib-linked methods.
  method objectType (:$raw = False) {
    my $t = $!o.g_type_instance.g_class.g_type;
    return $t if $raw;

    GLib::Object::Type.new($t);
  }

  method isType (Int() $type) {
    my GType $t  = $type;
    my       $gc = $!o.g_type_instance.g_class;

    return False unless $!o;
    return True  if     $gc && $gc.g_type == $t;

    return g_type_check_instance_is_a($!o.g_type_instance, $t);
  }

  # method !onFirstGObject ($value?) {
  #   # This REALLY should never be necessary.
  #   for self.^attributes {
  #     next unless .name eq '$!o';
  #     .set_value( self, $value ) if $value;
  #     return .get_value(self);
  #   }
  # }

  method !setObject ($obj) {
    say "SetObject ({ self }): { $obj }" if $DEBUG;
    $!o = $obj ~~ GObject ?? $obj !! cast(GObject, $obj);
    say "ObjectSet ({ self }): { $!o }" if $DEBUG;
  }

  method p { $!o.p }

  multi method Numeric { +self.p }

  method GLib::Raw::Object::GObject
  { $!o }

  method equals (GObject() $b) { +self.p == +$b.p }

  # Remove when Method::Also is fixed!
  method GObject ( :object(:$obj) ) { $obj ?? self !! $!o }

  method notify ($detail?) {
    my $sig-name = 'notify';
    $sig-name ~= "::{$detail}" if $detail;

    self.connect-notify($!o, $sig-name);
  }

  # We use these for inc/dec ops
  method ref   is also<upref>   {   g_object_ref($!o); self; }
  method unref is also<downref> { g_object_unref($!o); }

  method bind (
    Str()     $source_property,
    GObject() $target,
    Str()     $target_property,
    Int()     $flags            = 3    # G_BINDING_BIDIRECTIONAL +| G_BINDING_SYNC_CREATE
  ) {
    GLib::Object::Binding.bind(
      self,
      $source_property,
      $target,
      $target_property,
      $flags
    )
  }

  method bind_full (
    Str()                 $source_property,
    GObject()             $target,
    Str()                 $target_property,
    Int()                 $flags,
                          &transform_to   = Callable,
                          &transform_from = Callable,
    gpointer              $user_data      = Pointer,
                          &notify         = Callable
  ) {
    GLib::Object::Binding.bind_full(
      self,
      $source_property,
      $target,
      $target_property,
      $flags,
      &transform_to,
      &transform_from,
      $user_data,
      &notify
    );
  }

  method bind_with_closures (
    Str()      $source_property,
    GObject()  $target,
    Str()      $target_property,
    Int()      $flags,
    GClosure() $transform_to   = GClosure,
    GClosure() $transform_from = GClosure
  ) {
    GLib::Object::Binding.bind_with_closures(
      self,
      $source_property,
      $target,
      $target_property,
      $flags,
      $transform_to,
      $transform_from
    );
  }

  # cw: -YYY- Do we need this now that we have the .is_a method?
  method check_gobject_type($compare_type) {
    my $o = nativecast(GTypeInstance, $!o);

    $o.checkType($compare_type);
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
    g_object_get_string_data($o, gObjectTypeKey);
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
        .GValue;
      }
    });
  }

  method clear_object {
    # Until a better place can be found...
    sub g_clear_object ( CArray[Pointer[GObject]] )
      is native(gobject)
      { * }

    my $op = CArray[Pointer[GObject]].new;
    $op[0] = cast(Pointer[GObject], $!o);
    g_clear_object($op);
  }

  method is_type(GObjectOrPointer $t) {
    is_type($t, self);
  }

  method get_property (Str() $name, GValue() $value) is also<get-property> {
    g_object_get_property($!o, $name, $value);
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
    if @names.elems > 1 {
      # Return value
      %(do for (^@names.elems) {
        @names[$_] => @values[$_];
      });
    } else {
      # Return value
      @values[0];
    }
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
      my T $v = 0;

      f($_, $v, Str);
      $v;
    };

    @a.elems > 1 ?? @a !! @a[0];
  }

  method get_data_ptr (*@keys) {
    self!get-data-abstract(@keys, Pointer, &g_object_get_ptr);
  }
  method get_data_int64 (*@keys) {
    self!get-data-abstract(@keys,  gint64, &g_object_get_int64);
  }
  method get_data_uint64 (*@keys) {
    self!get-data-abstract(@keys, guint64, &g_object_get_uint64);
  }
  method get_data_int (*@keys) {
    self!get-data-abstract(@keys,    gint, &g_object_get_int);
  }
  method get_data_uint (*@keys) {
    self!get-data-abstract(@keys,   guint, &g_object_get_uint);
  }
  method get_data_string (*@keys) {
    self!get-data-abstract(@keys,     Str, &g_object_get_string);
  }
  method get_data_float (*@keys) {
    self!get-data-abstract(@keys, gdouble, &g_object_get_float);
  }
  method get_data_double (*@keys) {
    self!get-data-abstract(@keys, gdouble, &g_object_get_double);
  }

  method !set_data_abstract(@pairs, ::T, ::NT, $value, &f) {
    @pairs = @pairs.rotor(2).map({
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[0] ~~ Str || .^lookup('Str');
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[1] ~~ T || (my $m = .^lookup(T.^name));

      ( .[0].Str, $m(.[1]) );
    });

    for @pairs {
      my NT $v = $value;

      f($_, $v, Str);
    }
  }

  method set_data_ptr (*@pairs) {
    self!set-data-abstract(@pairs,   Mu, Pointer, &g_object_set_ptr);
  }
  method set_data_int64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int,  gint64, &g_object_set_int64);
  }
  method set_data_uint64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int, guint64, &g_object_set_uint64);
  }
  method set_data_int (*@pairs) {
    self!set-data-abstract(@pairs,  Int,    gint, &g_object_set_int);
  }
  method set_data_uint (*@pairs) {
    self!set-data-abstract(@pairs,  Int,   guint, &g_object_set_uint);
  }
  method set_data_string (*@pairs) {
    self!set-data-abstract(@pairs,  Str,     Str, &g_object_set_string);
  }
  method set_data_float (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_object_set_float);
  }
  method set_data_double (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_object_set_double);
  }

}

sub g_connect_notify (
  GObject $app,
  Str     $name,
          &handler (GObject $h_widget, GParamSpec $pspec, Pointer $h_data),
  Pointer $data,
  uint32  $connect_flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_object_get_property (GObject $o, Str $key, GValue $value)
  is native(gobject)
  is export
{ * }

multi sub infix:<=:=> (
  GLib::Roles::Object $a,
  GLib::Roles::Object $b
)
  is export
{
  $a.equals($b);
}
