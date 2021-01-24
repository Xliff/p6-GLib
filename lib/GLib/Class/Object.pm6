use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Object::ParamSpec;



class GObjectClass          is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GTypeClass      $.g_type_class;
  # Private
  has GSList          $!construct_properties;
  # Public
  has Pointer         $.constructor;                 #= GObject*   (*constructor)     (GType                  type,
                                                     #=                                guint                  n_construct_properties,
                                                     #=                                GObjectConstructParam *construct_properties);
  # overridable methods
  has Pointer         $.set_property;                #= void       (*set_property)            (GObject        *object,
                                                     #=                                        guint           property_id,
                                                     #=                                        const GValue   *value,
                                                     #=                                        GParamSpec     *pspec);
  has Pointer         $.get_property;                #= void       (*get_property)            (GObject        *object,
                                                     #=                                        guint           property_id,
                                                     #=                                        GValue         *value,
                                                     #=                                        GParamSpec     *pspec);
  has Pointer         $.dispose;                     #= void       (*dispose)                 (GObject        *object);
  has Pointer         $.fiinalize;                   #= void       (*finalize)                (GObject        *object);
  # seldom overriden
  has Pointer         $.dispatch_properties_changed; #= void       (*dispatch_properties_changed) (GObject      *object,
                                                     #=                                            guint         n_pspecs,
                                                     #=                                            GParamSpec  **pspecs);
  # signals
  has Pointer         $.notify;                      #= void       (*notify)                  (GObject        *object,
                                                     #=                                        GParamSpec     *pspec);

  # called when done constructing
  has Pointer         $.constructed;                 #= void       (*constructed)             (GObject        *object);

  # Private
  has gsize           $!flags;
  HAS gpointer        @!pdummy[6] is CArray;
}

constant GInitiallyUnownedClass is export := GObjectClass;

use GLib::Roles::TypedBuffer;

class GLib::Class::Object is export {
  has GObjectClass $!c;

  submethod BUILD (:$object-class) {
    self.setObjectClass($object-class) if $object-class;
  }

  method setObjectClass(GObjectClass $_) {
    $!c = $_;
  }

  method new (GObjectClass $object-class) {
    $object-class ?? self.bless( :$object-class ) !! Nil
  }

  method GLib::Class::Object::GObjectClass
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

  multi method list_properties (:$raw = False) {
    samewith($, :$raw)
  }
  multi method list_properties (
    $n_properties is rw,
    :$raw = False
  ) {
    my guint $n = 0;
    my $pl = g_object_class_list_properties($!c, $n);

    $n_properties = $n;
    my @properties;
    for ^$n {
      my $e = $pl[$_].deref;
      @properties.push: $raw ?? $e !! GLib::Object::ParamSpec.new($e)
    }
    @properties;
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

sub g_initially_unowned_get_type ()
  returns GType
  is native(gobject)
  is export
{ * }

sub g_object_class_install_property (
  GObjectClass $oclass,
  guint        $property_id,
  GParamSpec   $pspec
)
  is native(gobject)
  is export
{ * }

sub g_object_class_find_property (
  GObjectClass $oclass,
  Str          $property_name
)
  returns GParamSpec
  is native(gobject)
  is export
{ * }

sub g_object_class_list_properties (
  GObjectClass $oclass,
  guint        $n_properties is rw
)
  returns CArray[Pointer[GParamSpec]]
  is native(gobject)
  is export
{ * }

sub g_object_class_override_property  (
  GObjectClass $oclass,
  guint        $property_id,
  Str          $name
)
  is native(gobject)
  is export
{ * }

sub g_object_class_install_properties (
  GObjectClass                $oclass,
  guint                       $n_pspecs,
  CArray[Pointer[GParamSpec]] $pspecs # GParamSpec**
)
  is native(gobject)
  is export
{ * }

sub g_object_interface_install_property (
  gpointer    $g_iface,
  GParamSpec  $pspec
)
  is native(gobject)
  is export
{ * }

sub g_object_interface_find_property (
  gpointer $g_iface,
  Str      $property_name
)
  returns GParamSpec
  is native(gobject)
  is export
{ * }

sub g_object_interface_list_properties (
  gpointer $g_iface,
  guint    $n_properties_p is rw
)
  returns CArray[Pointer[GParamSpec]]
  is native(gobject)
  is export
{ * }
