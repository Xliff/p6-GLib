use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Exceptions;
use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Raw::Value;

use GLib::Object::Type;
use GLib::Variant;

use GLib::Roles::Implementor;
use GLib::Roles::TypedBuffer;

class GLib::Value {
  also does GLib::Roles::Implementor;

  has GValue $!v is implementor handles <p>;

  submethod BUILD (:$type, GValue :$value) {
    $!v = $value // GValue.new;

    die 'Cannot allocate GValue!' unless $!v;

    GLib::Value.init($!v, $type) if $type;
  }

  submethod DESTROY {
    #self.unref
  }

  proto method new (|c)
  { * }

  multi method new (GTypeEnum $t) {
    samewith($t.Int);
  }
  multi method new (Int $t = G_TYPE_NONE) {
    die "Invalid type passed to GLib::Value.new - { $t.^name }"
      unless $t ~~ Int || $t.^can('Int').elems;
    my $type = $t.Int;

    # Not elegible for a Nil check!
    self.bless( :$type );
  }
  multi method new-enum (\T) {
    ::?CLASS.new( ::?CLASS.typeFromEnum(T) );
  }
  multi method new ($v where { $_ ~~ GValue || .^can('GValue') }) {
    my $value = $v ~~ GValue ?? $v !! $v.GValue;

    $value ?? self.bless(:$value) !! GValue
  }

  method GLib::Raw::Structs::GValue
    is also<
      GValue
      gvalue
    >
  { $!v }

  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  method init (GValue $value, Int() $type) is static {
    g_value_init($value, $type);
  }

  method alloc (Int() $type) is static {
    my GType $t = $type;

    ::?CLASS.init( GValue.new, $type );
  }

  method get_boolean is also<get-boolean> {
    g_value_get_boolean($!v);
  }

  method get_boxed is also<get-boxed> {
    g_value_get_boxed($!v);
  }

  method get_char is also<get-char> {
    g_value_get_char($!v);
  }

  method get_double is also<get-double> {
    g_value_get_double($!v);
  }

  method get_enum is also<get-enum> {
    g_value_get_enum($!v);
  }

  method get_flags is also<get-flags> {
    g_value_get_enum($!v);
  }

  method get_float is also<get-float> {
    g_value_get_float($!v);
  }

  method get_int is also<get-int> {
    g_value_get_int($!v);
  }

  method get_int32 is also<get-int32> {
    g_value_get_int($!v);
  }

  method get_int64 is also<get-int64> {
    g_value_get_int64($!v);
  }

  method get_long is also<get-long> {
    g_value_get_long($!v);
  }

  method get_pointer is also<get-pointer> {
    g_value_get_pointer($!v);
  }

  # cw: -XXX- This one is dicey! A better method is in the works!
  method get_object ( :$raw = False ) is also<get-object> {
    propReturnObject(
      g_value_get_object($!v),
      $raw,
      |GLib::Object.getTypePair
    );
  }

  method get_schar is also<get-schar> {
    g_value_get_schar($!v);
  }

  method get_string is also<get-string> {
    g_value_get_string($!v);
  }

  method get_uchar is also<get-uchar> {
    g_value_get_uchar($!v);
  }

  method get_uint is also<get-uint> {
    g_value_get_uint($!v);
  }

  method get_uint32 is also<get-uint32> {
    g_value_get_uint($!v);
  }

  method get_uint64 is also<get-uint64> {
    g_value_get_uint64($!v);
  }

  method get_ulong is also<get-ulong> {
    g_value_get_ulong($!v);
  }

  method get_variant ( :$raw = False ) is also<get-variant> {
    propReturnObject(
      g_value_get_variant($!v),
      $raw,
      |GLib::Variant.getTypePair
    );
  }


  method unref {
    g_object_unref( nativecast(Pointer, $!v) );
  }

  method valueFromType (\T) is also<valueFromEnum> is rw {
    X::GLib::InvalidArgument.new(
      message => 'The parameter to valueFromType must be a type object!'
    ).throw if T.defined;

    do given T {
      when uint32   { self.uint   }
      when int32    { self.int    }
      when uint64   { self.uint64 }
      when int64    { self.int64  }
      when num32    { self.float  }
      when num64    { self.double }

      default {
        X::GLib::InvalidType.new(
          message => ".valueFromType does not recognize the {
                      .^name } type!"
        ).throw;
      }
    }
  }

  method gtypeFromType (GLib::Value:U: \T)
    is also<
      gtypeFromEnum
      typeFromEnum
    >
  {
    # cw: I don't know where this is coming from but it's the best I can do
    #     for now.
    return T if T ~~ GTypeEnum;

    X::GLib::InvalidArgument.new(
      message => "The parameter to gtypeFromType must be a type object, not {
                  T.^name }"
    ).throw if T.defined;

    do given T {
      when uint32               { G_TYPE_UINT    }
      when int32                { G_TYPE_INT     }
      when num32                { G_TYPE_FLOAT   }
      when num64                { G_TYPE_DOUBLE  }
      when uint64               { G_TYPE_UINT64  }
      when int64                { G_TYPE_INT64   }
      when Str                  { G_TYPE_STRING  }
      when Bool                 { G_TYPE_UINT    }
      when Pointer              { G_TYPE_POINTER }
      when T.REPR eq 'CStruct'  { G_TYPE_POINTER }
      when T.REPR eq 'CPointer' { G_TYPE_POINTER }

      when GOBJECT() {
        .?get_type // G_TYPE_OBJECT
      }
    }
  }

  method typeFromGType (GLib::Value:U: \T) {
    X::GLib::InvalidArgument.new(
      message => 'The parameter to typeFromGType must be a type object!'
    ).throw if T.defined;

    typeFromGType(T);
  }

  method valueFromGType (GTypeEnum $_) is rw {
    when G_TYPE_CHAR     { self.char;       }
    when G_TYPE_UCHAR    { self.uchar;      }
    when G_TYPE_BOOLEAN  { self.boolean;    }
    when G_TYPE_INT      { self.int;        }
    when G_TYPE_UINT     { self.uint;       }
    when G_TYPE_LONG     { self.long;       }
    when G_TYPE_ULONG    { self.ulong;      }
    when G_TYPE_INT64    { self.int64;      }
    when G_TYPE_UINT64   { self.uint64;     }

    # Enums and Flags will need to be checked, since they can be either
    # 32 or 64 bit depending on the definition.
    when G_TYPE_ENUM     { self.enum;       }
    when G_TYPE_FLAGS    { self.flags;      }

    when G_TYPE_FLOAT    { self.float;      }
    when G_TYPE_DOUBLE   { self.double      }
    when G_TYPE_STRING   { self.string;     }
    when G_TYPE_POINTER  { self.pointer;    }
    when G_TYPE_BOXED    { self.boxed;      }
    #when G_TYPE_PARAM   { }
    when G_TYPE_OBJECT   { self.object;     }
    #when G_TYPE_VARIANT { }
    default {
      "<< { $_.Str } type NYI >>";
    }
  }

  method value is rw {
    self.valueFromGType( self.type( :fundamental, :!enum ) );
  }

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  method boolean is rw {
    Proxy.new(
      FETCH => sub ($) {
        so $.get_boolean
      },
      STORE => sub ($, Int() $v_boolean is copy) {
        my gboolean $v = $v_boolean.so.Int;

        g_value_set_boolean($!v, $v);
      }
    );
  }

  method boxed is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_boxed;
      },
      STORE => -> $, $val is copy {
        g_value_set_boxed($!v, nativecast(Pointer, $val))
      }
    );
  }

  method char is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_char
      },
      STORE => sub ($, Str() $v_char is copy) {
        g_value_set_char($!v, $v_char);
      }
    );
  }

  method double is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_double;
      },
      STORE => sub ($, Num() $v_double is copy) {
        my num64 $vd = $v_double;

        g_value_set_double($!v, $vd);
      }
    );
  }

  method float is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_float;
      },
      STORE => sub ($, Num() $v_float is copy) {
        my num32 $vf = $v_float;

        g_value_set_float($!v, $vf);
      }
    );
  }

  # Alias back to original name of gtype.
  method type ( :$fundamental = False, :$enum = True ) is rw {
    Proxy.new(
      FETCH => sub ($) {
        my $t = $!v.g_type;
        return $t unless $enum;
        my $ap = GTypeEnum.enums.antipairs.Hash;
        unless $fundamental {
          if $ap{$t} -> $e {
            return $e;
          }
          return $t
        }
        $t = GLib::Object::Type.new($t).fundamental.Int;
        return Nil    unless $t.defined;
        return $t unless $enum;
        if $ap{$t} -> $e {
          return $e;
        }
        $t;
      },

      STORE => sub ($, Int() $v_gtype is copy) {
        $!v.g_type = $v_gtype;
      }
    );
  }

  method enum is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_enum;
      },
      STORE => sub ($, Int() $v_int is copy) {
        g_value_set_enum($!v, $v_int);
      }
    );
  }

  method flags is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_enum;
      },
      STORE => sub ($, Int() $v_uint is copy) {
        g_value_set_enum($!v, $v_uint);
      }
    );
  }

  method int is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_int;
      },
      STORE => sub ($, Int() $v_int is copy) {
        g_value_set_int($!v, $v_int);
      }
    );
  }

  method int64 is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_int64;
      },
      STORE => sub ($, Int() $v_int64 is copy) {
        g_value_set_int64($!v, $v_int64);
      }
    );
  }

  method long is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_long;
      },
      STORE => sub ($, $v_long is copy) {
        g_value_set_long($!v, $v_long);
      }
    );
  }

  method pointer is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_pointer;
      },
      STORE => sub ($, $v_pointer is copy) {
        g_value_set_pointer($!v, nativecast(Pointer, $v_pointer) );
      }
    );
  }

  method object ( :$raw = False ) is rw {
    Proxy.new(
      FETCH => -> $ {
        $.get_object( :$raw );
      },

      STORE => -> $, $obj is copy where *.^can('p') {
        g_value_set_object( $!v, $obj.p );
      }
    );
  }

  method schar is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_schar;
      },
      STORE => sub ($, $v_char is copy) {
        g_value_set_schar($!v, $v_char);
      }
    );
  }

  method string is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_string;
      },
      STORE => sub ($, Str() $v_string is copy) {
        g_value_set_string($!v, $v_string);
      }
    );
  }

  method uchar is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_uchar;
      },
      STORE => sub ($, $v_uchar is copy) {
        g_value_set_uchar($!v, $v_uchar);
      }
    );
  }

  method uint is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_uint;
      },
      STORE => sub ($, Int() $v_uint is copy) {
        g_value_set_uint($!v, $v_uint);
      }
    );
  }

  method uint64 is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_uint64;
      },
      STORE => sub ($, Int() $v_uint64 is copy) {
        g_value_set_uint64($!v, $v_uint64);
      }
    );
  }

  method ulong is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_ulong;
      },
      STORE => sub ($, Int() $v_ulong is copy) {
        g_value_set_ulong($!v, $v_ulong);
      }
    );
  }

  method variant is rw {
    Proxy.new(
      FETCH => sub ($) {
        $.get_variant;
      },
      STORE => sub ($, $variant is copy) {
        g_value_set_variant($!v, $variant);
      }
    );
  }
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_value_get_type, $n, $t );
  }

  # Begin static methods
  method g_gtype_get_type {
    g_gtype_get_type();
  }

  method g_pointer_type_register_static(Str() $name) {
    g_pointer_type_register_static($name);
  }
  # End static methods

  # ↓↓↓↓ METHODS ↓↓↓↓
  method dup_string {
    g_value_dup_string($!v);
  }

  method dup_variant {
    g_value_dup_variant($!v);
  }

  method g_strdup_value_contents {
    g_strdup_value_contents($!v);
  }

  method set_static_string (Str() $v_string) {
    g_value_set_static_string($!v, $v_string);
  }

  method set_string_take_ownership (Str() $v_string) {
    g_value_set_string_take_ownership($!v, $v_string);
  }

  method take_string (Str() $v_string) {
    g_value_take_string($!v, $v_string);
  }

  method take_variant (GVariant() $variant) {
    g_value_take_variant($!v, $variant);
  }

  method dup_param (:$raw = False) {
    my $p = g_value_dup_param($!v);

    $p ??
      ( $raw ?? $p !! ::('GLib::GObject::ParamSpec').new($p, :!ref) )
      !!
      Nil;
  }

  method get_param (:$raw = False) {
    my $p = g_value_get_param($!v);

    $p ??
      ( $raw ?? $p !! ::('GLib::GObject::ParamSpec').new($p, :!ref) )
      !!
      Nil;
  }

  method set_param (GParamSpec() $param) {
    g_value_set_param($!v, $param);
  }

  method take_param (GParamSpec() $param) {
    g_value_take_param($!v, $param);
  }


  # ↑↑↑↑ METHODS ↑↑↑↑

}

# Helper functions

sub gv-str (Str() $s) is export
  { gv_str($s) }
sub gv_str (Str() $s is copy) is export {
  $s = '' if $s === Str;

  say "Using gv_str for '{ $s // '»NIL«' }'..." if checkDEBUG(3);
  my $gv = GLib::Value.new( G_TYPE_STRING );
  $gv.string = $s;
  say "Resulting value is '{ $gv.value // '»NIL«' }'..." if checkDEBUG(3);
  $gv;
}

sub gv-bool (Int() $b) is export
  { gv_bool($b) }
sub gv_bool (Int() $b) is export {
  my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
  $gv.boolean = $b;
  $gv;
}

sub gv-int (Int() $i) is export
  { gv_int($i) }
sub gv_int (Int() $i) is export {
  my $gv = GLib::Value.new( G_TYPE_INT );
  $gv.int = $i;
  $gv;
}

sub gv-uint (Int() $i) is export
  { gv_uint($i) }
sub gv_uint (Int() $i) is export {
  my $gv = GLib::Value.new( G_TYPE_UINT );
  $gv.uint = $i;
  $gv;
}

sub gv-int64 (Int() $i) is export
  { gv_int64($i) }
sub gv_int64 (Int() $i) is export {
  my $gv = GLib::Value.new( G_TYPE_INT64 );
  $gv.int64 = $i;
  $gv;
}

sub gv-uint64 (Int() $i) is export
  { gv_uint64($i) }
sub gv_uint64 (Int() $i) is export {
  my $gv = GLib::Value.new( G_TYPE_UINT64 );
  $gv.uint64 = $i;
  $gv;
}

sub gv-flt (Num() $f) is export
  { gv_flt($f) }
sub gv_flt (Num() $f) is export {
  my $gv = GLib::Value.new( G_TYPE_FLOAT );
  $gv.float = $f;
  $gv;
}

sub gv-dbl (Num() $d) is export
  { gv_dbl($d) }
sub gv_dbl (Num() $d) is export {
  my $gv = GLib::Value.new( G_TYPE_DOUBLE );
  $gv.double = $d;
  $gv;
}

sub gv-flag (Int() $f) is export
  { gv_flag($f) }
sub gv_flag (Int() $f) is export {
  my $gv = GLib::Value.new( G_TYPE_FLAGS );
  $gv.flags = $f;
  $gv;
}

sub gv-obj ($o, :$type) is export
  { gv_obj($o, :$type) }
sub gv_obj ($o, :$type is copy) is export {
  $type = $o.?get_type
    if ( $o ~~ ::('GLib::Roles::Object') ) && $type.defined.not;
  my $gv = GLib::Value.new( $type // G_TYPE_OBJECT );
  $gv.object = $o;
  $gv;
}

sub gv-ptr ($p) is export
  { gv_ptr($p) }
sub gv_ptr ($p) is export {
  my $gv = GLib::Value.new( G_TYPE_POINTER );
  $gv.pointer = $p;
  $gv;
}

sub valueToGValue (
  $_,
  :$signed,
  :$unsigned  is copy,
  :$single,
  :$double    is copy
) is export {
  $unsigned //= $signed.so.not;
  $double   //= $single.so.not;

  say "valueToGValue - Converting [{ $_ // '»NIL«' }]..." if checkDEBUG(3);

  when GValue                        { $_                 }
  when .^can('GValue')               { .GValue            }
  when Str                           { gv_str($_)         }
  when GOBJECT()                     { gv_obj( .GObject ) }
  when GObject                       { gv_obj($_)         }
  when .REPR eq <CStruct CUnion>.any { gv_ptr($_)         }

  when Num                           { $double ?? gv_dbl($_) !! gv_flt($_) }

  when Int                           {
    # cw: Beware the law of unintended consequences!
    if $_ < 0 && $signed.not && $single {
      .abs.log(2) < 32 ?? gv_int($_) !! gv_int64($_);
    } else {
      $signed ?? ( $single ?? gv_int($_)  !! gv_int64($_)  )
              !! ( $single ?? gv_uint($_) !! gv_uint64($_) )
    }
  }

  default {
    X::GLib::InvalidValue.new(
      routine => &?ROUTINE.name,
      message => "Do not know how to handle object of type {
                  .^name } in update!"
    ).throw
  }
}

class GLib::Value::Array {
  has GValueArray $!ga  is implementor;
  has             $!raw is built;

  submethod BUILD ( :$glib-value-array ) {
    $!ga = $glib-value-array if $glib-value-array;
  }

  method new (GValueArray $glib-value-array, :$raw) {
    return Nil unless $glib-value-array;

    $glib-value-array ?? self.bless( :$glib-value-array, :$raw ) !! Nil;
  }

  method GLib::Raw::Structs::GValueArray
    is also<GValueArray>
  { $!ga }

  method values ( :$raw = False ) {
    say "VA values: { $!ga.values }" if checkDEBUG(3);

    bufferReturnTypedArray(
      $!ga.values,
      |GLib::Value.getTypePair,

      size => $!ga.n_values,
      raw  => $raw
    );
  }

  method Array ( :$raw = False ) {
    self.values( :$raw ).Array
  }

}
