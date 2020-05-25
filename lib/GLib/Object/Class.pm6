use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Object::Raw::Class;

use GLib::Object::ParamSpec;

use GLib::Roles::StaticClass;

class GLib::Object::Class {
  has GObjectClass $!c;

  submethod BUILD (:$object-class) {
    $!c = $object-class;
  }

  method new (GObjectClass $object-class) {
    $object-class ?? self.bless( :$object-class ) !! Nil
  }

  method GLib::Raw::Structs::GObjectClass
    is also<GObjectClass>
  { $!c }

  method install_property (Int() $property_id, GParamSpec() $pspec)
    is also<install-property>
  {
    my guint $pid = $property_id;

    g_object_class_install_property($!c, $pid, $pspec);
  }

  method find_property (Str() $property_name, :$raw = False)
    is also<find-property>
  {
    my $p = g_object_class_find_property($!c, $property_name);

    $p ??
      ( $raw ?? $p !! GLib::Object::ParamSpec.new($p) )
      !!
      Nil;
  }

  proto method list_properties (|)
    is also<list-properties>
  { * }

  multi method list_properties (:$list = False, :$raw = False) {
    samewith($, :$list, :$raw)
  }
  multi method list_properties (
    $n_properties is rw,
    :$list = False,
    :$raw = False
  ) {
    my guint $n = 0;
    my $pl = g_object_class_list_properties($!c, $n);

    return Nil unless $pl && $pl[0];
    return $pl[0] if $list && $raw;

    $pl = GLib::Roles::TypedBuffer[GParamSpec].new($pl[0]);
    $pl.setSize($n_properties = $n);
    return $pl if $list;

    $raw ?? $pl.Array !! $pl.Array.map({ GLib::Object.ParamSpec.new($_) });
  }

  method override_property (Int() $property_id, Str() $property_name)
    is also<override-property>
  {
    my guint $pid = $property_id;

    g_object_class_override_property($!c, $pid, $property_name);
  }

  proto method install_properties (|)
    is also<install-properties>
  { * }

  multi method install_properties (@pspecs) {
    my @vetted-pspecs = do for @pspecs {
      die '@pspecs must contain GParamSpec-compatible entries!'
        unless $_ ~~ GParamSpec || ( my $m = .^lookup('GParamSpec') );
      $m ?? $m($_) !! $_;
    }

    my $gpb = GLib::Roles::TypedBuffer[GParamSpec].new(@vetted-pspecs);
    my $gpa = CArray[Pointer[GParamSpec]].new;
    $gpa[0] = $gpb.p;

    samewith(@pspecs.elems, $gpa);
  }
  multi method install_properties (
    Int() $n_specs,
    CArray[Pointer[GParamSpec]] $pspecs
  ) {
    g_object_class_install_properties($!c, $n_specs, $pspecs);
  }

}

# cw: -XXX- NYI
# class GLib::Object::Interface {
#   also does GLib::Roles::StaticClass;
#
#   method install_property
#   method find_property
#   method list_properties
# }
