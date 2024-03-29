use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;

use GLib::Object::Raw::Binding;

use GLib::Roles::Object;

class GLib::Object::Binding {
  also does GLib::Roles::Object;

  has GBinding $!b is implementor;

  submethod BUILD (:$binding) {
    self!setObject($!b = $binding);
  }

  method GLib::Raw::Definitions::GBinding
    is also<GBinding>
  { $!b }

  method get_flags is also<get-flags> {
    GBindingFlagsEnum( g_binding_get_flags($!b) );
  }

  method get_source (:$raw = False) is also<get-source> {
    my $obj = g_binding_get_source($!b);

    $obj ??
      ( $raw ?? $obj !! GLib::Roles::Object.new-object-obj($obj) )
      !!
      Nil;
  }

  method get_source_property is also<get-source-property> {
    g_binding_get_source_property($!b);
  }

  method get_target (:$raw = False) is also<get-target> {
    my $obj = g_binding_get_target($!b);

    $obj ??
      ( $raw ?? $obj !! GLib::Roles::Object.new-object-obj($obj) )
      !!
      Nil;
  }

  method get_target_property is also<get-target-property> {
    g_binding_get_target_property($!b);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_binding_get_type, $n, $t );
  }

  method unbind {
    g_binding_unbind($!b);
  }

}
