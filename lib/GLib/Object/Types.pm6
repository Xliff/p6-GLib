use v6.c;

use GLib::Raw::Subs;
use GLib::Object::Raw::Types;

use GLib::Roles::StaticClass;

class GLib::StringV {
  also does GLib::Roles::StaticClass;

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_strv_get_type, $n, $t );
  }
}
