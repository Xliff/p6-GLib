use v6.c;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GLib::Raw::Subs;

use GLib::Raw::TypePlugin;

use GLib::Roles::Object;
use GLib::Roles::Implementor;

role GLib::Roles::TypePlugin {
  has GTypePlugin $!tp;

  method roleInit-GTypePlugin {
    return if $!tp;

    my \i = findProperImplementor(self.^attributes);
    $!tp = cast( GTypePlugin, i.get_value(self) );
  }

  method complete_interface_info (
    Int()          $instance_type,
    Int()          $interface_type,
    GInterfaceInfo $info
  ) {
    my GType ($ist, $int) = ($instance_type, $interface_type);

    g_type_plugin_complete_interface_info($!tp, $ist, $int, $info);
  }

  method complete_type_info (
    Int()           $g_type,
    GTypeInfo       $info,
    GTypeValueTable $value_table
  ) {
    my GType $g = $g_type;

    g_type_plugin_complete_type_info($!tp, $g, $info, $value_table);
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_type_plugin_get_type, $n, $t );
  }

  method unuse {
    g_type_plugin_unuse($!tp);
  }

  method use {
    g_type_plugin_use($!tp);
  }
}

our subset GTypePluginAncestry is export of Mu
  where GTypePlugin | GObject;

class GLib::Object::TypePlugin {
  also does GLib::Roles::TypePlugin;
  also does GLib::Roles::Object;

  submethod BUILD (:$plugin) {
    self.setGTypedPlugin($plugin) if $plugin;
  }

  method setGTypePlugin (GTypePluginAncestry $_) {
    my $to-parent;

    $!tp = do {
      when GTypePlugin {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTypePlugin, $_);
      }
    }
    self!setObject($to-parent);
  }

  method Evolution::Raw::Definitions::GTypePlugin
  { $!tp }

  method new (GTypePluginAncestry $plugin, :$ref = True) {
    return Nil unless $plugin;

    my $o = self.bless( :$plugin );
    $o.ref if $ref;
    $o;
  }

}
