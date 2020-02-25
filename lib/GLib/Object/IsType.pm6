use v6.c;

use NativeCall;

use GLib::Raw::Types;

use GLib::Roles::Pointers;

unit package GLib::Object::IsType;

sub is_type (GObjectOrPointer $t, $object) is export {
  $t .= GObject if $t ~~ ::('GLib::Roles::Object');
  my ($to, $ot) =
    ( nativecast(GObjectStruct, $t), $object.get_type );
  $to.checkType($ot);
}
