use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Subs;

class GLib::Enum::GType {

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_gtype_get_type, $n, $t );
  }

}

sub g_gtype_get_type
  returns GType
  is      export
  is      native(glib)
{ * }
