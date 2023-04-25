use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Class::Structs;
use GLib::Object::Raw::TypeModule;
use GLib::Class::Object;

use GLib::Roles::Object;
use GLib::Roles::TypePlugin;

our subset GTypeModuleAncestry is export of Mu
  where GTypeModule | GTypePlugin | GObject;

class GLib::Object::TypeModule {
  also does GLib::Roles::Object;
  also does GLib::Roles::TypePlugin;

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
    self.roleInit-GTypePlugin;
  }

  method GLib::Raw::Definitions::GTypeModule
    is also<GTypeModule>
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
  )
    is also<add-interface>
  {
    my GType ($ins, $int) = ($instance_type, $interface_type);

    g_type_module_add_interface($!tm, $ins, $int, $interface_info);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_type_module_get_type, $n, $t );
  }

  method register_enum (
    Str()      $name,
    GEnumValue $const_static_values
  )
    is also<register-enum>
  {
    g_type_module_register_enum($!tm, $name, $const_static_values);
  }

  method register_flags (
    Str()       $name,
    GFlagsValue $const_static_values
  )
    is also<register-flags>
  {
    g_type_module_register_flags($!tm, $name, $const_static_values);
  }

  our %class-defines is export;

  method register_static ($instance-struct, Mu :$class-struct is copy)
    is also<register-static>
  {
    # cw: If there is no <class-struct> then one must be created based on
    #     GObject.
    unless $class-struct.WHERE === Any.WHERE {
      $class-struct = Metamodel::ClassHOW.new_type(
        name => $instance-struct.^shortname ~ 'Class',
        repr => 'CStruct'
      );
      $class-struct.^add_attribute(
        Attribute.new(
          name         => '$.parent',
          has_accessor => True,
          package      => $class-struct,
          type         => GObjectClass,
          inlined      => True
        )
      );
      $class-struct.^compose;
    }

    say "Class struct is: { $class-struct === Any }";
    say "Class struct is called: { $class-struct.^name }";
    say "Class struct has attributes: { $class-struct.^attributes.gist }";
    say "Class Struct is sized: { nativesizeof($class-struct) }";

    # cw: Hold on to our definition, just in case.
    %class-defines{ $class-struct.^name } := $class-struct;

    # cw: Kinda boxed myself into a corner with this. The problem here
    #     is that our get_type methods are all tied to the raku porcelain
    #     rather than the plumbing, so we can't solely grab the parent from
    #     <$instance-struct> and run with it. We'll have to try and resolve
    #     from <MANIFEST> and fall back to GObject if nothing resolves.

    self.register_static_simple(
      # For now, we use GLib::Object.get_type
      GLib::Object.get_type,
      $instance-struct.^shortname,
      nativesizeof($instance-struct),

      class-size => nativesizeof($class-struct),

      instance-init => sub (*@a) {
        CATCH {
          default { .message.say; .backtrace.concise.say }
        }

        say "Instance init: { @a.gist }";
        standard_instance_init( $instance-struct, $class-struct, |@a )
      },

      class-init => sub (*@a) {
        CATCH {
          default { .message.say; .backtrace.concise.say }
        }

        say "Class init: { @a.gist }";
        standard_class_init($instance-struct, $class-struct.new)
      }

    );
  }

  proto method register_static_simple (|)
    is also<register-static-simple>
  { * }

  multi method register_static_simple (
    Int()       $parent_type,
    Str()       $type_name,
    Int()       $instance_size                 = 0,
    Int()      :class-size(:$class_size)       = 0,
               :class-init(:&class_init)       = &standard_class_init,
               :instance-init(:&instance_init) = &standard_instance_init,
    Int()      :$flags                         = 0
  ) {
    samewith(
      $parent_type,
      $type_name,
      $class_size,
      &class_init,
      $instance_size,
      &instance_init,
      $flags
    );
  }
  multi method register_static_simple (
    Int()      $parent_type,
    Str()      $type_name,
    Int()      $class_size,
               &class_init,
    Int()      $instance_size,
               &instance_init  = &standard_instance_init,
    Int()      $flags          = 0
  ) {
    my guint      ($c, $i) = ($class_size, $instance_size);
    my GType       $p      =  $parent_type;
    my GTypeFlags  $f      =  $flags;

    g_type_register_static_simple(
      $p,
      $type_name,
      $c,
      &class_init,
      $i,
      &instance_init,
      $f
    );
  }

  method register_type (
    Int()       $parent_type,
    Str()       $type_name,
    GTypeInfo() $type_info,
    Int()       $flags
  )
    is also<register-type>
  {
    my GType      $p = $parent_type;
    my GTypeFlags $f = $flags;

    g_type_module_register_type($!tm, $p, $type_name, $type_info, $f);
  }

  method set_name (Str() $name) is also<set-name> {
    g_type_module_set_name($!tm, $name);
  }

  method unuse {
    g_type_module_unuse($!tm);
  }

  method use {
    g_type_module_use($!tm);
  }

}

sub standard_class_init ($instance-struct, $class-struct) is export {
  for $class-struct.^attributes {
    my $name = .name.substr(2);

    $class-struct.parent.g_type_class.g_type = GLib::Object.get_type;
    
    say "GType: { $class-struct.parent.g_type_class.g_type }";

    given $name {
      my \sf = $instance-struct.^can($_);

      next unless sf ~~ GObjectVFunc;
      next unless sf.g-v-func eq $name;

      when 'get_property' {
        unless sf {
          sf = sub ($i, $idx, $v, $p) {
            if $idx !~~ 0 .. $instance-struct.^attributes.elems {
              X::GLib::Object::AttributeNotFound.new(
                attribute => $p.name
              ).throw
            }
            $v.value = $instance-struct.^attributes[$idx].get_value($i);
          }
        }

        $class-struct.parent.get_property =
          set_func_pointer( &(sf), &sprintf-obj-prop)
      }

      when 'set_property' {
        unless sf {
          sf = sub ($i, $idx, $v, $p) {
            if $idx !~~ 0 .. $instance-struct.^attributes.elems {
              X::GLib::Object::AttributeNotFound.new(
                attribute => $p.name
              ).throw
            }
            $instance-struct.^attributes[$idx].set_value($i, $v);
          }
        }

        $class-struct.parent.set_property =
          set_func_pointer( &(sf), &sprintf-obj-prop)
      }

      default {
        $class-struct.parent."$_"() = sf if sf
      }
    }
  }
}

sub standard_instance_init (\struct, \c_struct, $s is copy, $p) is export {
  constant P = GLib::Object::ParamSpec;

  $s = cast(struct, $s);

  my @props;
  for $s.^attributes {
    my $att = $_;

    when GAttribute {
      # Create property
      my (
        $name,
        $nick,
        $blurb,
        $minimum,
        $maximum,
        $default_value,
        $flags,
        $boxed_type,
        $object_type
      ) = (
        .name.substr(2),
        .?nick           // '',
        .blurb           // '',
        .?range-min      // 0,
        .?range-max      // 0,
        .?default-value  // 0,
        .?flags          // 0,
        .?boxed-type     // 0,
        .?object-type    // 0
      );

      say "Processing property { $att.name }";

      @props.push: do given .type {
        my ($raw-typed, $std-typed) = False;

        when BoxedType | GObjectDerived {
          # cw: These are also manifest based, but in the case of GObject
          #     will fallback to GObject. For <BoxedType> values, if an
          #     object match is not found, it is OK for it to not have one.
          $s.^add_method("set_{ $att.name }", method (\v) {
            $att.set_value($s, v);
            self.emit("notify::{ $att.name }");
          });

          $s.^add_method("get_{ $att.name }", method ( :$raw = False ) {
            $att.get_value($s);
            # cw: Return comparable object.
          });
        }

        when BoxedType {
          P.new_boxed(
            $name,
            $nick,
            $blurb,
            $boxed_type,
            $flags
          )
        }

        when GObjectDerived {
          P.new_object(
            $name,
            $nick,
            $blurb,
            $object_type,
            $flags
          );
        }

        when bool     |
             int8     |
             uint8    |
             int16    |
             int32    |
             uint16   |
             uint32   |
             int64    |
             uint64   |
             Str      |
             Pointer
        {
          $s.^add_method("set_{ $att.name }", method (\v) {
            $att.set_value($s, v);
            self.emit("notify::{ $att.name }");
          });

          $s.^add_method("get_{ $att.name }", method () {
            $att.get_value($s);
          });
          proceed;
        }

        when bool {
          P.new_boolean(
            $name,
            $nick,
            $blurb,
            $default_value,
            $flags
          );
        }

        when int8    {
          P.new_char(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when uint8 {
          P.new_uchar(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        # when int16   { }
        # when uint16  { }

        when int16 | int32 {
          P.new_int(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when uint16 | uint32 {
          P.new_uint(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when int64  {
          P.new_int64(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when uint64 {
          P.new_uint64(
           $name,
           $nick,
           $blurb,
           $minimum,
           $maximum,
           $default_value,
           $flags
          );
        }

        when num32 {
          P.new_float(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when num64 {
          P.new_double(
            $name,
            $nick,
            $blurb,
            $minimum,
            $maximum,
            $default_value,
            $flags
          );
        }

        when Str {
          P.new_string(
            $name,
            $nick,
            $blurb,
            $default_value,
            $flags
          );
        }

        when Pointer {
          P.new_pointer(
            $name,
            $nick,
            $blurb,
            $flags
          )
        }

      }
    }

    when GSignal {
      # Create signal
    }
  }

  say "Class: { c_struct.^name }";

  g_object_class_install_properties(
    # cw: May not always be at .parent. Need's a better mechanism but fine
    #     for now.
    c_struct,
    @props.elems,
    ArrayToCArray( GParamSpec, @props )
  );
}
