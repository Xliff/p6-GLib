use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

unit package GLib::Raw::Struct_Subs;

sub sprintf-v ( Blob, Str, & () )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-P ( Blob, Str, & (Pointer) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-SP ( Blob, Str, & (Str, Pointer) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

# Also is -SUP
sub sprintf-SBP ( Blob, Str, & (Str, gboolean, Pointer) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-v-L (Blob, Str, & (--> int64) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-P-L (Blob, Str, & (Pointer --> int64) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-DP ( Blob, Str, & (gdouble, Pointer) )
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-PSƒP(
  Blob,
  Str,
  & (
    gpointer,
    GSource,
    & (gpointer --> guint32),
    gpointer
  ),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-p-b (
  Blob,
  Str,
  & (gpointer --> gboolean),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-SCi-b (
  Blob,
  Str,
  & (GSource, CArray[gint] --> gboolean),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-S-b (
  Blob,
  Str,
  & (GSource --> gboolean),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-SƒP-b (
  Blob,
  Str,
  & (GSource, & (gpointer --> gboolean), gpointer --> gboolean),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub set_func_pointer(
  \func,
  &sprint = &sprintf-v
) is export {
  my $buf = buf8.allocate(20);
  my $len = &sprint($buf, '%lld', func);

  Pointer.new( $buf.subbuf(^$len).decode.Int );
}
