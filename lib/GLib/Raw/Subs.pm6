use v6.c;

use NativeCall;
use NativeHelpers::Blob;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;

use GLib::Object::Supplyish;

use GLib::Roles::Pointers;

unit package GLib::Raw::Subs;

# Cribbed from https://github.com/CurtTilmes/perl6-dbmysql/blob/master/lib/DB/MySQL/Native.pm6
sub malloc         (size_t --> Pointer)                    is export is native { * }
sub realloc        (Pointer, size_t --> Pointer)           is export is native { * }
sub calloc         (size_t, size_t --> Pointer)            is export is native { * }
sub memcpy         (Pointer, Pointer, size_t --> Pointer)  is export is native { * }
sub memcmp         (Pointer, Pointer, size_t --> int32)    is export is native { * }
sub memset         (Pointer, int32, size_t)                is export is native { * }
sub dup2           (int32, int32 --> int32)                is export is native { * }
sub isatty         (int32 --> int32)                       is export is native { * }
# Needed for minimal I18n
sub setlocale      (int32, Str --> Str)                    is export is native { * }

sub native-open    (Str, int32, int32 $m = 0)
  is export
  is symbol('open')
  is native
{ * }

# So as not to collide with the CORE sub.
sub native-close   (int32 --> int32)
  is export
  is symbol('close')
  is native
{ * }

our proto sub free (|) is export { * }
multi sub free (Pointer)                           is export is native { * }

# Cribbed from https://stackoverflow.com/questions/1281686/determine-size-of-dynamically-allocated-memory-in-c
sub malloc_usable_size (Pointer --> size_t)        is export is native { * }

# Implement memcpy_pattern. Take pattern and write pattern.^elem bytes to successive areas in dest.

sub getEndian is export {
  ( $*KERNEL.endian == BigEndian, $*KERNEL.endian == LittleEndian );
}

sub cast($cast-to, $obj) is export {
  nativecast($cast-to, $obj);
}

sub real-resolve-uint64($v) is export {
  $v +& 0xffffffffffffffff;
}

sub p ($p) is export {
  cast(Pointer, $p);
}

# Moved from p6-GStreamer
sub nolf ($s) is export {
  $s.subst("\n", ' ', :g);
}

sub lf ($s) is export {
  $s.subst("\r\n", "\n", :g);
}

sub crlf ($s) is export {
  $s.subst("\n", "\r\n", :g);
}

proto sub intRange (|) is export
{ * }

multi sub intRange ($bits, $signed = False) {
  intRange(:$bits, :$signed);
}
multi sub intRange (:$bits, :$signed = False) {
  $signed ??
    2 ** $bits *-1 .. 2 ** $bits -1
    !!
    0 .. 2 ** $bits
}

# cw: Coerces the value of $a to a value within $r.
sub clamp($a, Range() $r) is export {
  max( $r.min, min($a, $r.max) )
}

sub unstable_get_type($name, &sub, $n is rw, $t is rw) is export {
  return $t if ($n // 0) > 0;
  repeat {
    $t = &sub();
    die "{ $name }.get_type could not get stable result"
      if $n++ > 20;
  } until $t == &sub();
  $t;
}

# This should be in CORE!
sub separate (Str() $s, Int() $p) is export {
  die '$p outside of string range!' unless $p ~~ 0 .. $s.chars;
  ( $s.substr(0, $p), $s.substr($p, *) )
}

sub createReturnArray (\T) is export {
  my \at = T.REPR eq 'CStruct' ?? Pointer[T] !! T;
  (my $a = CArray[at].new)[0] = at;
  $a;
}

sub resolveNativeType (\T) is export {
  say "Resolving { T.^name } to its Raku equivalent...";
  do given T {
    when num32 | num64     { Num }

    when int8  | uint8  |
         int16 | uint16 |
         int32 | uint32 |
         int64 | uint64
                           { Int }

    when str               { Str }

    default                {
      given T.REPR {
        when 'CArray'                { CArray }
        when 'CStruct' | 'CPointer'  { T }
      }
    }
  }
}

sub checkForType(\T, $v is copy) is export {
  if T !=== Nil {
    if T !~~ $v.WHAT {
      my $resolved-name = resolveNativeType(T).^name;
      $resolved-name ~= "[{ T.of.^name }]" if $resolved-name eq 'CArray';
      if $v.^lookup($resolved-name) -> $m {
        say "Using coercer at { T.^name }.$resolved-name...";
        $v = $m($v);
      }
      # Note reversal of usual comparison. This is due to the fact that
      # nativecall types must be compatible with the value, not the
      # other way around. In a;; other cases, T and $v should have
      # the same type value.
      die "Value does not support { $v.^name } variables. Will only accept {
        T.^name }!" unless T ~~ $v.WHAT;
    }
  }
  $v;
}

sub ArrayToCArray(\T, @a) is export {
  enum Handling <P NP>;
  my $handling;
  my $ca = (do given (T.REPR // '') {
    when 'P6opaque' {
      when T ~~ Str                      { $handling = P;  CArray[T]          }

      proceed
    }

    when 'CPointer' | 'P6str'  |
         'P6num'    | 'P6int'            { $handling = P;  CArray[T]          }
    when 'CStruct'  | 'CUnion'           { $handling = NP; CArray[Pointer[T]] }

    default {
      "ArrayToCArray does not know how to handle a REPR of '$_' for type {
       T.^name }"
    }
  }).new;
  for ^@a.elems {
    my $typed = checkForType(T, @a[$_]);

    $ca[$_] = $handling eq P ?? $typed !! cast(Pointer[T], $typed)
  }
  $ca;
}

multi sub CStringArrayToArray(CArray[Str] $sa, Int(Cool) $len) is export {
  CArrayToArray($sa, $len);
}
multi sub CStringArrayToArray (CArray[Str] $sa) is export {
  CArrayToArray($sa)
}

multi sub CArrayToArray(CArray $ca) is export {
  return Nil unless $ca;
  my ($i, @a) = (0);
  while $ca[$i] {
    @a.push: $ca[$i++];
  }
  @a;
}
multi sub CArrayToArray(CArray $ca, Int(Cool) $len) is export {
  return Nil unless $ca;
  my @a;
  @a[$_] = $ca[$_] for ^$len;
  @a;
}

sub get_flags($t, $s, $j = ', ') is export {
  $t.enums
    .map({ $s +& .value ?? .key !! '' })
    .grep(* ne '')
    .join($j);
}

# GLib-level
sub typeToGType (\t) is export {
  do given t {
    when Str             { G_TYPE_STRING  }
    when int16  | int32  { G_TYPE_INT     }
    when uint16 | uint32 { G_TYPE_UINT    }
    when int64           { G_TYPE_INT64   }
    when uint64          { G_TYPE_UINT64  }
    when num32           { G_TYPE_FLOAT   }
    when num64           { G_TYPE_DOUBLE  }
    when Pointer         { G_TYPE_POINTER }
    when Bool            { G_TYPE_BOOLEAN }
    when GObject         { G_TYPE_OBJECT  }
  };
}

sub resolve-gtype($gt) is export {
  die "{ $gt } is not a valid GType value"
    unless $gt ∈ GTypeEnum.enums.values;
  $gt;
}

multi sub resolve-gstrv(CArray[Str] $p, $length?) is export {
  my $l = $length // try $p.elems;
  die "Cannot determine the size of a CArray.{
       ''} Please use the \$length parameter in call to resolve-gstrv()!"
    if $l ~~ Failure;

  $p[ $l ] = Str unless $p[$l - 1] =:= Str;
  $p;
}
multi sub resolve-gstrv(@rg) is export {
  resolve-gstrv( |@rg );
}
multi sub resolve-gstrv( *@rg where *.all !~~ Positional ) is export {
  my $gs = CArray[Str].new;
  my $c = 0;
  for @rg {
    die "Cannot coerce element { $_.^name } to string."
      unless $_ ~~ Str || $_.^can('Str').elems;
    $gs[$c++] = $_.Str;
  }
  $gs[$gs.elems] = Str unless $gs[* - 1] =:= Str;
  $gs;
}

sub getBackupPath ($p is copy, $pre = 'bak') is export {
  $p .= IO if $p ~~ Str;
  my ($safe-fh, $serial);
  my $fhp = $p;
  repeat {
    $safe-fh = $fhp.extension("{ $pre }{ $serial++ }", parts => 0);
  } until $safe-fh.e.not;
  $safe-fh;
}

#sub create-signal-supply (%sigs, $signal, $s) is export {
#  GLib::Object::Supplyish.new($s.Supply, %sigs, $signal);
  # my $supply = $s.Supply;
  #
  # $supply.^lookup('tap').wrap: my method (|c) {
  #   %sigs{$signal} = True;
  #   # # cw: Wrap on the Callable in |c to add the default
    # #     exception handler.
    # if c.list[0] ~~ Callable {
    #   my $wrapped = sub (|a) {
    #     CATCH { default { .message.say; .backtrace.concise.say } }
    #     c.list[0](|a);
    #   }
    #   nextwith($supply, $wrapped, |c.hash)
    # } else {
    #   nextsame;
    # }
  #   nextsame;
  # };
  # $supply
#}

#| ppr(*@a) - Potential Pointer Return. Handles values, potentially pointers,
#|            that are wrapped in a CArray. If value is a Pointer type AND
#|            a CStruct, then that value will be dereferenced.
sub ppr (*@a) is export {
  @a .= map({
    if $_ ~~ CArray {
      if .[0].defined {
        if .[0].REPR.chars.not {
          .[0]
        } else {
          my $p = .[0];
          $p.defined ?? ( .[0] !~~ Pointer ?? .[0]
                                           !! (
                                               .[0].of.REPR eq 'CStruct'
                                                  ?? .[0].deref
                                                  !! .[0]
                                              )
                        )
                     !! Nil;
        }
      } else {
        Nil;
      }
    }
    else { $_ }
  });
  @a.elems == 1 ?? @a[0] !! @a;
}

sub return-with-all ($v) is export {
  $v[0] ?? ( $v.elems == 1 ?? $v !! $v.skip(1) )
        !! Nil
}

# The assumption here is "Transfer: Full"
sub propReturnObject ($oo, $raw, \P, $C? is raw, :$ref = False) is export {
  my $o = $oo;
  return Nil unless $o;

  $o = cast(P, $o);
  return $o if $raw || $C === Nil;

  $C.new($o, :$ref);
}
our &returnObject is export := &propReturnObject;

sub subarray ($a, $o) is export {
  my $b = nativecast(Pointer[$a.of], $a);
  nativecast(CArray[$a.of], $b.add($o) );
}

sub nativeSized (\T, *%options) is export {
  given T {
    when int8  | uint8                   { 1 }
    when int16 | uint16                  { 2 }
    when int32 | uint32                  { 4 }
    when int64 | uint64                  { 8 }
    when num32                           { 4 }
    when num64                           { 8 }
    when Str                             { $*KERNEL.bits div 8 }
    when Int   | Num                     { %options<double> ?? 32 !! 64 }
    when .REPR eq <CStruct CPointer>.any { $*KERNEL.bits div 8 }

    default {
      # cw: Really need to start typing these!!
      die "Do not have type sizing rules for { T.^name }!";
    }
  }
}

sub toPointer (
  $value,
  :$signed   = False,
  :$double   = False,
  :$direct   = False,
  :$encoding = 'utf8',
  :$typed
)
  is export
{
  # Properly handle non-Str Cool data.
  return $value if $value ~~ Pointer;
  return ($typed !=== Nil ?? $typed !! Nil) unless $value.defined;
  my ($ov, $use-arr, \t, $v) = ( checkForType($typed, $value), False );
  if $ov ~~ Int && $direct {
    $v = Pointer.new($ov);
  } else {
    given $ov {
      # For all implementor-based classes
      when .^lookup('p').so { $ov .= p }

      when Rat { $ov .= Num; proceed }
      when Int {
        $use-arr = True;
        when $signed.so { t := $double ?? CArray[int64] !!  CArray[int32]  }
        default         { t := $double ?? CArray[uint64] !! CArray[uint32] }
      }
      when Rat | Num {
        $use-arr = True;
        t := $double ?? CArray[num64] !!  CArray[num32]
      }

      # Str
      default {
        $ov = ~$ov unless $ov ~~ Str;
        # Better to use CArray[uint8] as it is less volatile than Str;
        my $ca = CArray[uint8].new( $ov.encode($encoding) );
        $ov = pointer-to($ca);
      }
    }
    if $use-arr {
      $v    = t.new;
      $v[0] = $ov;
    } else {
      $v = $ov;
    }
    $v = cast(Pointer, $v) unless $v ~~ Pointer;
  }
  $v
}

# Add Role to redefine name of method (guifa++)
sub buildAccessors (\O) is export {
	my $proxy = sub ($n, \attr) {
		my $m = method :: is rw {
			Proxy.new(
				FETCH => -> $,    { my $p = attr.get_value(self);
                            ($p does GLib::Roles::Pointers)
                              if $p ~~ (Pointer, CArray).any;
                            $p },
				STORE => -> $, \v { attr.set_value(self, v) }
			);
		}
    $m.set_name($n);
    $m;
	}

	for O.^attributes.kv -> $k, \a {
		my $full-name = a.name;
    my ($, $attr-name) = $full-name.&separate(2);
		next if a.has_accessor;

		print "  Adding { $attr-name } to { O.^name }..." if $DEBUG;
		O.^add_method(
			$attr-name,
			$proxy($attr-name, a)    #= $proxy() returns Method
		);
		say 'done' if $DEBUG;
	}
}

sub nullTerminatedBuffer (CArray[uint8] $data) is export {
  my $t-idx = 0;
  repeat { } while $data[$t-idx++];
  CArray[uint8].new( $data[^$t-idx] );
}

sub g_destroy_none(Pointer)
  is export
{ * }

sub g_object_new (uint64 $object_type, Str)
  returns GObject
  is native(gobject)
  is export
{ * }

sub g_object_ref (GObject $p)
  is native(gobject)
  is export
{ * }

sub g_object_unref (GObject $p)
  is native(gobject)
  is export
{ * }

sub g_object_set_string_data (GObject $o, Str $key, Str $data)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub _g_object_get_string_data (GObject $o, Str $key)
  returns CArray[uint8]
  is native(gobject)
  is symbol('g_object_get_data')
{ * }

sub g_object_get_string_data (GObject $o, Str $key) is export {
  my $d = _g_object_get_string_data($o, $key);

  my $c = 0;
  my @d;
  while $d[$c++] -> $nc { @d.push: $nc }
  my $s = Buf.new(@d).decode;
  free( cast(Pointer, $d) );
  $s;
}

# sub g_object_set_int(GObject $o, Str $key, int32 $data is rw)
#   is native(gobject)
#   is symbol('g_object_set_data')
#   is export
#   { * }

sub g_object_get_ptr_data (GObject $o, Str $key)
  returns Pointer
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_ptr_data (GObject $o, Str $key, Pointer $data)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub g_object_setv (
  GObject     $object,
  uint32      $n_properties,
  CArray[Str] $names,
  Pointer     $v             #CArray[GValue] $values
)
  is native(gobject)
  is export
{ * }

sub g_object_getv (
  GObject     $object,
  uint32      $n_properties,
  CArray[Str] $names,
  Pointer     $v             #CArray[GValue] $values
)
  is native(gobject)
  is export
{ * }

sub g_object_get_int_data (
  GObject $object,
  Str     $name,
)
  returns CArray[gint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_int_data (
  GObject      $object,
  Str          $name,
  CArray[gint] $value
)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub g_object_get_uint_data (
  GObject $object,
  Str     $name,
)
  returns CArray[guint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_uint_data (
  GObject       $object,
  Str           $name,
  CArray[guint] $value
)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub g_object_get_string (GObject $object, Str $key, Str $val)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_string (GObject $object, Str $key, Str $val)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_ptr (GObject $object, Str $key, Pointer $val)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_ptr (GObject $object, Str $key, Pointer $val)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_float (GObject $object, Str $key, CArray[gfloat] $val)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_float (GObject $object, Str $key, CArray[gfloat] $val, Str)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_double (
  GObject         $object,
  Str             $key,
  CArray[gdouble] $val,
  Str
)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_double (
  GObject         $object,
  Str             $key,
  CArray[gdouble] $val,
  Str
)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_int (GObject $object, Str $key, CArray[gint] $val, Str)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_int (GObject $object, Str $key, CArray[gint] $val, Str)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_uint (GObject $object, Str $key, CArray[gint] $val, Str)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_uint (GObject $object, Str $key, CArray[gint] $val, Str)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_int64 (GObject $object, Str $key, CArray[gint64] $val, Str)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_int64 (GObject $object, Str $key, CArray[gint64] $val, Str)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }

sub g_object_get_uint64 (
  GObject         $object,
  Str             $key,
  CArray[guint64] $val,
  Str
)
  is native(gobject)
  is symbol('g_object_get')
  is export
{ * }

sub g_object_set_uint64 (
  GObject         $object,
  Str             $key,
  CArray[guint64] $val,
  Str
)
  is native(gobject)
  is symbol('g_object_set')
  is export
{ * }
