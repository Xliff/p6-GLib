use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;

use GLib::Roles::Pointers;

unit package GLib::Raw::Subs;

# Cribbed from https://github.com/CurtTilmes/perl6-dbmysql/blob/master/lib/DB/MySQL/Native.pm6
sub malloc         (size_t --> Pointer)                   is export is native { * }
sub realloc        (Pointer, size_t --> Pointer)          is export is native { * }
sub calloc         (size_t, size_t --> Pointer)           is export is native { * }
sub memcpy         (Pointer, Pointer ,size_t --> Pointer) is export is native { * }
sub memset         (Pointer, int32, size_t)               is export is native { * }
sub dup2           (int32, int32 --> int32)               is export is native { * }
sub isatty         (int32 --> int32)                      is export is native { * }

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
sub nocr ($s) is export {
  $s.subst("\n", ' ', :g);
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

sub ArrayToCArray(\T, @a) is export {
  my $ca =  CArray[T].new;
  $ca[$_] = @a[$_] for ^@a.elems;
  $ca;
}

multi sub CStringArrayToArray(CArray[Str] $sa, Int(Cool) $len) {
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
multi sub resolve-gstrv(*@rg) is export {
  my $gs = CArray[Str].new;
  my $c = 0;
  for @rg {
    die "Cannot coerce element { $_.^name } to string."
      unless $_ ~~ Str || $_.^can('Str').elems;
    $gs[$c++] = $_.Str;
  }
  $gs[$gs.elems] = Str unless $gs[*-1] =:= Str;
  $gs;
}

sub create-signal-supply (%sigs, $signal, $s) is export {
  my $supply = $s.Supply;
  $supply.^lookup('tap').wrap: my method (|c) {
    %sigs{$signal} = True;
    nextsame;
  };
  $supply
}

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

sub g_destroy_none(Pointer)
  is export
{ * }

sub g_object_new (uint64 $object_type, Str)
  returns gpointer
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

sub g_object_get_string_data (GObject $o, Str $key)
  returns Str
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

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
  GObject $object,
  uint32 $n_properties,
  CArray[Str] $names,
  # Note... not an array.
  #CArray[GValue] $values
  Pointer $v
)
  is native(gobject)
  is export
{ * }

sub g_object_getv (
  GObject $object,
  uint32 $n_properties,
  CArray[Str] $names,
  #CArray[GValue] $values
  Pointer $v
)
  is native(gobject)
  is export
{ * }

sub g_object_get_int_data (
  GObject $object,
  Str $name,
)
  returns CArray[gint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_int_data (
  GObject $object,
  Str $name,
  CArray[gint] $value
)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub g_object_get_uint_data (
  GObject $object,
  Str $name,
)
  returns CArray[guint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_uint_data (
  GObject $object,
  Str $name,
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
