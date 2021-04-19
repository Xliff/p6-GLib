use v6.c;

use GLib::Raw::Types;
use GLib::Class::Structs;
use GLib::Object::Raw::TypeModule;

use GLib::Roles::Object;

our subset GTypeModuleAncestry is export of Mu
  where GTypeModule | GObject;

class GLib::Object::TypeModule {
  also does GLib::Roles::Object;

  has GTypeModule $!tm is implementor;

  submethod BUILD (:$type-module) {
    self.setGTypeModule($type-module) if $type-module;
  }

  method setGTypeModule (GTypeModuleAncestry $_) {
    my $to-parent;
    $!tm = do {
      when GTypeModule {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTypeModule, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GLib::Raw::Definitions::GTypeModule
  { $!tm }

  method new (GTypeModuleAncestry $type-module, :$ref = True) {
    return Nil unless $type-module;

    my $o = self.bless( :$type-module );
    $o.ref if $ref;
    $o;
  }

  method add_interface (
    Int()            $instance_type,
    Int()            $interface_type,
    GInterfaceInfo() $interface_info
  ) {
    my GType ($ins, $int) = ($instance_type, $interface_type);

    g_type_module_add_interface($!tm, $ins, $int, $interface_info);
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_type_module_get_type, $n, $t );
  }

  method register_enum (
    Str()      $name,
    GEnumValue $const_static_values
  ) {
    g_type_module_register_enum($!tm, $name, $const_static_values);
  }

  method register_flags (
    Str()       $name,
    GFlagsValue $const_static_values
  ) {
    g_type_module_register_flags($!tm, $name, $const_static_values);
  }

  method register_type (
    Int()       $parent_type,
    Str()       $type_name,
    GTypeInfo() $type_info,
    Int()       $flags
  ) {
    my GType      $p = $parent_type;
    my GTypeFlags $f = $flags;

    g_type_module_register_type($!tm, $p, $type_name, $type_info, $f);
  }

  method set_name (Str() $name) {
    g_type_module_set_name($!tm, $name);
  }

  method unuse {
    g_type_module_unuse($!tm);
  }

  method use {
    g_type_module_use($!tm);
  }

}
