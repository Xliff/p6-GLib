use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;

unit package GLib::Raw::Subs;

# Cribbed from https://github.com/CurtTilmes/perl6-dbmysql/blob/master/lib/DB/MySQL/Native.pm6
sub malloc  (size_t --> Pointer)                   is export is native {}
sub realloc (Pointer, size_t --> Pointer)          is export is native {}
sub calloc  (size_t, size_t --> Pointer)           is export is native {}
sub memcpy  (Pointer, Pointer ,size_t --> Pointer) is export is native {}
sub memset  (Pointer, int32, size_t)               is export is native {}

our proto sub free (|) is export { * }
multi sub free (Pointer)                           is export is native {}

# Cribbed from https://stackoverflow.com/questions/1281686/determine-size-of-dynamically-allocated-memory-in-c
sub malloc_usable_size (Pointer --> size_t)        is export is native {}

# Implement memcpy_pattern. Take pattern and write pattern.^elem bytes to successive areas in dest.

sub cast($cast-to, $obj) is export {
  nativecast($cast-to, $obj);
}

sub real-resolve-uint64($v) is export {
  $v +& 0xffffffffffffffff;
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

sub g_destroy_none(Pointer)
  is export
{ * }

sub g_object_new (uint64 $object_type, Str)
  returns gpointer
  is native(gobject)
  is export
{ * }

sub g_object_ref(GObject $p)
  is native(gobject)
  is export
{ * }

sub g_object_unref(GObject $p)
  is native(gobject)
  is export
{ * }

sub g_object_set_string(Pointer $o, Str $key, Str $data)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
{ * }

sub g_object_get_string(Pointer $o, Str $key)
  returns Str
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

# Now in GTK::Roles::Properties!!
#
# sub g_object_set_int(Pointer $o, Str $key, int32 $data is rw)
#   is native(gobject)
#   is symbol('g_object_set_data')
#   is export
#   { * }

sub g_object_get_ptr(Pointer $o, Str $key)
  returns Pointer
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_ptr(Pointer $o, Str $key, Pointer $data is rw)
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

sub g_object_get_int (
  Pointer $object,
  Str $name,
)
  returns CArray[gint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_int (
  Pointer $object,
  Str $name,
  gint $value is rw
)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
  { * }

sub g_object_get_uint (
  Pointer $object,
  Str $name,
)
  returns CArray[guint]
  is native(gobject)
  is symbol('g_object_get_data')
  is export
{ * }

sub g_object_set_uint (
  Pointer $object,
  Str $name,
  guint $value is rw
)
  is native(gobject)
  is symbol('g_object_set_data')
  is export
  { * }

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

sub get_flags($t, $s) is export {
  $t.enums
    .map({ $s +& .value ?? .key !! '' })
    .grep(* ne '')
    .join(', ');
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

sub resolve-gstrv(*@rg) is export {
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

sub g_signal_handler_disconnect(Pointer $app, uint64 $handler)
  is native(gobject)
  is export
{ * }
