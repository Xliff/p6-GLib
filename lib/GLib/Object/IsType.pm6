use v6.c;

use NativeCall;

use GLib::Raw::Types;

use GLib::Roles::Pointers;

unit package GLib::Object::IsType;

sub is_type (GObjectOrPointer $t, $object) is export {
  $t .= GObject if $t ~~ ::('GLib::Roles::Object');
  my ($to, $ot) =
    ( nativecast(GObject, $t), $object.get_type );
  $to.checkType($ot);
}

sub get_gtype_name (GObjectOrPointer $t) is export {
  $t .= GObject if $t ~~ ::('GLib::Roles::Object');

  my $to = nativecast(GObject, $t);

  g_type_name($to.getType);
}

sub g_type_name (GType $gtype)
  returns Str
  is native(gobject)
{ * }
