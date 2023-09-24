use v6.c;

use Method::Also;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Raw::Type;

use GLib::Roles::StaticClass;

class GLib::Object::Type {
  has GType $!t;

  submethod BUILD (:$type) {
    $!t = $type;
  }

  method Int is also<GType> {
    # use nqp;
    #
    # nqp::hllize($!t) if $!t;
    $!t;
  }
  method GLib::Raw::Enums::GTypeEnum { GTypeEnum($!t) }

  method new (Int() $type) {
    $type.defined ?? self.bless(:$type) !! Nil;
  }

  method add_class_cache_func (
    gpointer $cache_data,
             &cache_func
  )
    is static
    is also<add-class-cache-func>
  {
    g_type_add_class_cache_func($cache_data, &cache_func);
    &cache_func;
  }

  # method add_class_private (Int() $private_size) {
  #   my gsize $p = $private_size;
  #
  #   g_type_add_class_private($!t, $p);
  # }

  # method add_instance_private (gsize $private_size) {
  #   g_type_add_instance_private($!t, $private_size);
  # }

  method add_interface_check (
    gpointer $check_data,
             &check_func
  )
    is static
    is also<add-interface-check>
  {
    g_type_add_interface_check($check_data, &check_func);
    &check_func
  }

  method add_interface_dynamic (Int() $interface_type, GTypePlugin $plugin)
    is also<add-interface-dynamic>
  {
    my GType $it = $interface_type;

    g_type_add_interface_dynamic($!t, $it, $plugin);
  }

  method add_interface_static (Int() $interface_type, GInterfaceInfo $info)
    is also<add-interface-static>
  {
    my GType $it = $interface_type;

    g_type_add_interface_static($!t, $it, $info);
  }

  multi method children (:$raw = False) {
    samewith($, :$raw);
  }
  multi method children ($n_children is rw, :$raw = False) {
    my guint $n = 0;

    my $ca = g_type_children($!t, $n);
    $n_children = $n;

    CArrayToArray($ca, $n);
  }

  method create_instance is also<create-instance> {
    g_type_create_instance($!t);
  }

  method default_interface_peek is also<default-interface-peek> {
    g_type_default_interface_peek($!t);
  }

  method default_interface_ref is also<default-interface-ref> {
    g_type_default_interface_ref($!t);
  }

  method default_interface_unref is also<default-interface-unref> {
    g_type_default_interface_unref($!t.p);
  }

  method depth {
    g_type_depth($!t);
  }

  method ensure {
    g_type_ensure($!t);
  }

  method free_instance (GTypeInstance $instance)
    is static
    is also<free-instance>
  {
    g_type_free_instance($instance);
  }

  method from_name (Str() $name, :$raw = False) is also<from-name> {
    my $t = g_type_from_name($name);

    return $t if $raw;

    GLib::Object::Type.new($t);
  }

  method fundamental ( :$enum = False, :$raw = False ) {
    my $t = g_type_fundamental($!t);

    return $t            if $raw;
    return GTypeEnum($t) if $enum;

    GLib::Object::Type.new($t);
  }

  method fundamental_next ( :$raw = False ) is also<fundamental-next> {
    my $t = g_type_fundamental_next();
    return $t if $raw;

    GLib::Object::Type.new($t);
  }

  method get_instance_count is also<get-instance-count> {
    g_type_get_instance_count($!t);
  }

  method get_plugin is also<get-plugin> {
    g_type_get_plugin($!t);
  }

  method get_qdata (Int() $quark) is also<get-qdata> {
    my GQuark $q = $quark;

    g_type_get_qdata($!t, $q);
  }

  method get_type_registration_serial is also<get-type-registration-serial> {
    g_type_get_type_registration_serial();
  }

  # method init {
  #   g_type_init($!t);
  # }

  # method init_with_debug_flags () {
  #   g_type_init_with_debug_flags($!t);
  # }

  # method instance_get_private (Int() $private_type) {
  #   my GType $pt = $private_type;
  #
  #   g_type_instance_get_private($!t, $pt);
  # }

  multi method interfaces (:$list = False, :$raw = False) {
    samewith($, :$list, :$raw);
  }
  multi method interfaces (
     $n_interfaces is rw,
    :$c-array             = False,
    :$raw                 = False
  ) {
    my guint $n  = 0;
    my       $ia = g_type_interfaces($!t, $n);

    return Nil unless $ia;
    return $ia if     $c-array;

    $n_interfaces = $n;
    my $a = CArrayToArray($ia);
    $a = $a.map({ GLib::Object::Type.new($_) }) unless $raw;
    $a;
  }

  method is_a (Int() $is_a_type) is also<is-a> {
    my GType $isa = $is_a_type;

    g_type_is_a($!t, $isa);
  }

  method is_fundamentally (Int() $type) is also<is-fundamentally> {
    my GType $t = $type;
    my $t0 = g_type_fundamental($!t);

    $t == $t0;
  }

  method is_boxed  is also<is-boxed>  { self.is_a(G_TYPE_BOXED)  }
  method is_object is also<is-object> { self.is_a(G_TYPE_OBJECT) }

  method name {
    g_type_name($!t);
  }

  method name_from_class (GLib::Object::Type:U: GTypeClass $class)
    is also<name-from-class>
  {
    g_type_name_from_class($class);
  }

  method name_from_instance (GLib::Object::Type:U: GTypeInstance $instance)
    is also<name-from-instance>
  {
    g_type_name_from_instance($instance);
  }

  method next_base (Int() $root_type) is also<next-base> {
    my GType $rt = $root_type;

    g_type_next_base($!t, $rt);
  }

  method parent (:$raw = False) {
    my $p = g_type_parent($!t);

    $p ??
      ( $raw ?? $p !! GLib::Object::Type.new($p) )
      !!
      Nil;
  }

  method qname {
    g_type_qname($!t);
  }

  method query (GTypeQuery $query) {
    g_type_query($!t, $query);
  }

  method remove_class_cache_func (
    GLib::Object::Type:U:
    gpointer $cache_data,
    &cache_func
  )
    is also<remove-class-cache-func>
  {
    g_type_remove_class_cache_func($cache_data, &cache_func);
  }

  method remove_interface_check (
    GLib::Object::Type:U:
    gpointer $check_data,
    &check_func
  )
    is also<remove-interface-check>
  {
    g_type_remove_interface_check($!t, &check_func);
  }

  method set_qdata (Int() $quark, gpointer $data) is also<set-qdata> {
    my GQuark $q = $quark;

    g_type_set_qdata($!t, $q, $data);
  }

  method test_flags (Int() $flags) is also<test-flags> {
    my guint $f = $flags;

    so g_type_test_flags($!t, $f);
  }

  method value_table_peek is also<value-table-peek> {
    g_type_value_table_peek($!t);
  }

  # cw: Find a better interface for this. I am very wary of having anything
  #     starting with "class_" in an object. However, this being GType
  #     I'm willing to make an exception for the following:
  method class_ref is also<class-ref> {
    g_type_class_ref($!t);
  }

  method class_unref (GLib::Object::Type:U: gpointer $c)
    is also<class-unref>
  {
    g_type_class_unref($c);
  }

}

class GObject::Type::Interface {
  also does GLib::Roles::StaticClass;

  method add_prerequisite (
    Int() $type,
    Int() $prerequisite_type
  )
    is also<add-prerequisite>
  {
    my GType ($t, $pt) = ($type, $prerequisite_type);

    g_type_interface_add_prerequisite($t, $pt);
  }

  method get_plugin (Int() $type, Int() $interface_type) is also<get-plugin> {
    my GType ($t, $it) = ($type, $interface_type);

    g_type_interface_get_plugin($t, $it);
  }

  method peek (GTypeClass $instance_class, Int() $iface_type) {
    my GType $it = $iface_type;

    g_type_interface_peek($instance_class, $it);
  }

  method peek_parent (GTypeInstance $iface) is also<peek-parent> {
    g_type_interface_peek_parent($iface);
  }

  multi method prerequisites (
    Int()  $interface_type,
          :$raw             = False
  ) {
    samewith($interface_type, $, :$raw);
  }
  multi method prerequisites (
    Int()  $interface_type,
           $n_prerequisites is rw,
          :$raw                    = False
  ) {
    my GType $it = $interface_type;
    my guint $n = 0;
    my $pa = g_type_interface_prerequisites($it, $n);

    $n_prerequisites = $n;
    CArrayToArray($pa);
  }
}

# class GLib::Object::Type::Class {
#   also does GLib::Roles::StaticClass;
#
#   # method class_add_private (gsize $private_size) {
#   #   g_type_class_add_private($!t, $private_size);
#   # }
#
#   method class_adjust_private_offset (gint $private_size_or_offset) {
#     g_type_class_adjust_private_offset($!t, $private_size_or_offset);
#   }
#
#   method class_get_instance_private_offset () {
#     g_type_class_get_instance_private_offset($!t);
#   }
#
#   method class_get_private (GType $private_type) {
#     g_type_class_get_private($!t, $private_type);
#   }
#
#   method class_peek () {
#     g_type_class_peek($!t);
#   }
#
#   method class_peek_parent () {
#     g_type_class_peek_parent($!t);
#   }
#
#   method class_peek_static () {
#     g_type_class_peek_static($!t);
#   }
#
#
#
#   method class_unref_uncached () {
#     g_type_class_unref_uncached($!t);
#   }
#
# }

# cw: Check to ensure this is in scope... it should be!
# class GLib::Object::Type::Check {
#
#   method class_cast (GType $is_a_type) {
#     g_type_check_class_cast($!t, $is_a_type);
#   }
#
#   method class_is_a (GType $is_a_type) {
#     g_type_check_class_is_a($!t, $is_a_type);
#   }
#
#   method instance {
#     g_type_check_instance($!t);
#   }
#
#   method instance_cast (GType $iface_type) {
#     g_type_check_instance_cast($!t, $iface_type);
#   }
#
#   method instance_is_a (GType $iface_type) {
#     g_type_check_instance_is_a($!t, $iface_type);
#   }
#
#   method instance_is_fundamentally_a (GType $fundamental_type) {
#     g_type_check_instance_is_fundamentally_a($!t, $fundamental_type);
#   }
#
#   method is_value_type {
#     g_type_check_is_value_type($!t);
#   }
#
#   method value {
#     g_type_check_value($!t);
#   }
#
#   method value_holds (GType $type) {
#     g_type_check_value_holds($!t, $type);
#   }
#
# }

class GLib::Object::Type::Register {
  also does GLib::Roles::StaticClass;

  method dynamic (
    Int()       $type;
    Str         $type_name,
    GTypePlugin $plugin,
    Int()       $flags
  ) {
    my GType      $t = $type;
    my GTypeFlags $f = $flags;

    g_type_register_dynamic($t, $type_name, $plugin, $flags);
  }

  method fundamental (
    Int()                $type,
    Str()                $type_name,
    GTypeInfo            $info,
    GTypeFundamentalInfo $finfo,
    Int()                $flags
  ) {
    my GType      $t = $type;
    my GTypeFlags $f = $flags;

    g_type_register_fundamental($t, $type_name, $info, $finfo, $flags);
  }

  method static (
    Int()     $parent_type,
    Str()     $type_name,
    GTypeInfo $info,
    Int()     $flags
  ) {
    my GType      $pt = $parent_type;
    my GTypeFlags $f  = $flags;

    g_type_register_static($pt, $type_name, $info, $f);
  }

  method static_simple (
    Int()     $parent_type,
    Str()     $type_name,
    Int()     $class_size,
    gpointer  $class_init, #= GClassInitFunc
    Int()     $instance_size,
    gpointer  $instance_init, #= GInstanceInitFunc
    Int()     $flags
  )
    is also<static-simple>
  {
    my GType       $pt       =  $parent_type;
    my guint      ($cs, $is) = ($class_size, $instance_size);
    my GTypeFlags  $f        =  $flags;

    g_type_register_static_simple(
      $pt,
      $type_name,
      $cs,
      $class_init,
      $is,
      $instance_init,
      $f
    );
  }

}
