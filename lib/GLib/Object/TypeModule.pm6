use v6.c;

use experimental :rakuast;

use Method::Also;
use NativeCall;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Class::Structs;
use GLib::Object::Raw::TypeModule;
use GLib::Class::Object;
use GLib::Object::Type;

use GLib::Roles::Object;
use GLib::Roles::TypePlugin;

our subset GTypeModuleAncestry is export of Mu
  where GTypeModule | GTypePlugin | GObject;

my %checkAttributes;

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
    Str() $name,
    Int() $const_static_values
  )
    is also<register-enum>
  {
    my GEnumValue $c = $const_static_values;

    g_type_module_register_enum($!tm, $name, $c);
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

  method add-registration-callback($class-name, &callback) {
    %checkAttributes{ $class-name } = &callback;
  }

  method register_vfunc ($name) {
  }

  method register_static (
        $instance-tp,
    Mu :$class-struct                    is copy,
       :class-init(:&class_init)                  = &standard_class_init,
       :instance-init(:&instance_init)            = &standard_instance_init,
       :register-vfunc(:&register_vfunc)          = &standard_register_vfunc,

  )
    is also<register-static>
  {
    # cw: If there is no <class-struct> then one must be created based on
    #     GObject.
    my @vfunc-names;

    unless $class-struct.WHERE === Any.WHERE {
      $class-struct = Metamodel::ClassHOW.new_type(
        name => $instance-tp.head.^shortname ~ 'Class',
        repr => 'CStruct'
      );
      # cw: Go through instance-struct and look for any vfuncs!
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

    say "Class struct is Any: { $class-struct === Any }";
    say "Class struct is called: { $class-struct.^name }";
    say "Class struct attributes: { $class-struct.^attributes.gist }";
    say "Class Struct is sized: { nativesizeof($class-struct) }";

    # cw: Hold on to our definition, just in case.
    %class-defines{ $class-struct.^name } := $class-struct;

    # cw: Resolve parent object throw HOW instead of Struct since the
    #     Class Struct may not exist.
    my $p;
    for self.^mro {
      if .HOW ~~ Metamodel::ClassHOW {
        next if $_ === self.WHAT;
        $p := $_;
        last;
      }
    }
    $p := GLib::Object if $p =:= Any;

    say "P Object: { $p.^name }";
    self.register_static_simple(
      $p.get_type,
      $instance-tp.head.^shortname,
      nativesizeof($instance-tp.head),

      class-size => nativesizeof($class-struct),

      instance-init => sub (*@a) {
        CATCH {
          default { .message.say; .backtrace.concise.say }
        }

        say "Instance init: { @a.gist }";
        instance_init( $instance-tp.head, $class-struct, |@a )
      },

      class-init => sub ( *@a ) {
        CATCH {
          default { .message.say; .backtrace.concise.say }
        }

        say "Class init: { @a.gist }";
        class_init($instance-tp.head, $class-struct, |@a);
        if +@vfunc-names {
          register_vfunc($_) for @vfunc-names;
        }
      }

    );
  }

  proto method register_static_simple (|)
    is also<register-static-simple>
  { * }

  multi method register_static_simple (
    Int()       $parent_type,
    Str()       $type_name,
    Int()       $instance_size                   = 0,
    Int()      :class-size(:$class_size)         = 0,
               :class-init(:&class_init)         = &standard_class_init,
               :instance-init(:&instance_init)   = &standard_instance_init,
    Int()      :$flags                           = 0
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

sub standard_class_init ($itp, $cs, $cc is copy, $p) is export {
  say "CC: { +$cc }";

  multi sub checkAttributes( $cs where  *.defined ) {
    say "CS: { $cs }";
    checkAttributes($cs.?parent);

    for $cs.^attributes {
      my \f = $itp.tail,.^can($_);

      if %checkAttributes{ $cs.^name } -> &cb {
        my $r = &cb($cc, $_, f);
        next unless $r;
      }

      my $n = .substr(2);
      $cs."$n"() = f if f && $cs.^can($n)
    }
  }
  multi sub checkAttributes( $cs where *.defined.not ) {
  }

  #checkAttributes($cc);

  constant P = GLib::Object::ParamSpec;

  $cc = cast($cs, $cc);
  my $cct = $cc.parent.g_type_class.g_type;
  my $ncn = GLib::Object::Type.new($cct).name;

  say "CC Type: { $cct }";
  say "CC Type Name: { $ncn }";

  # cw: @props list starts with NULL
  my @props = (GParamSpec);

  my (@prop-get-add, @prop-set-add);
  my $a-idx = 0;

  for $itp.^attributes {
    my $att = $_;

    say "Attribute: { .gist }";

    @prop-set-add.push: RakuAST::Statement::When.new(
      condition => RakuAST::Literal.from-value($a-idx),
      body      => RakuAST::Block.new(
        body => RakuAST::Blockoid.new(
          RakuAST::StatementList.new(
            RakuAST::Statement::Expression.new(
              expression => RakuAST::ApplyPostfix.new(
                operand => RakuAST::Var::Lexical.new("\$is"),
                postfix => RakuAST::Call::Method.new(
                  name => RakuAST::Name.from-identifier("set_attribute"),
                  args => RakuAST::ArgList.new(
                    RakuAST::Var::Lexical.new("\$val")
                  )
                )
              )
            ),
            # cw: Is wrong! Should be a call to the Raw equivalent!
            RakuAST::Statement::Expression.new(
              expression => RakuAST::ApplyPostfix.new(
                operand => RakuAST::Term::Self.new,
                postfix => RakuAST::Call::Method.new(
                  name => RakuAST::Name.from-identifier("emit"),
                  args => RakuAST::ArgList.new(
                    RakuAST::StrLiteral.new("notify::{ .name.substr(2) }"),
                  )
                )
              )
            )
          )
        )
      )
    );

    # @prop-get-add:

    when GAttribute {
      say "Attribute...";

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

      # cw: Now must handle G_PARAM_READABLE and G_PARAM_WRITABLE

      my $acc = $itp.^can( $att.name.substr(2) ).head;

      say "Accessor: { $acc.name }" if $acc;

      $flags +|= G_PARAM_READABLE if $att.name.starts-with('$.') || $acc;
      $flags +|= G_PARAM_WRITABLE if $att.rw  || ( $acc && $acc.rw );

      say "Setting flags { $flags } on { $att.name } of type {
           .type.^name }.";

      my $p = do given .type {
        my ($raw-typed, $std-typed) = False;

        when BoxedType | GObjectDerived {
          # cw: These are also manifest based, but in the case of GObject
          #     will fallback to GObject. For <BoxedType> values, if an
          #     object match is not found, it is OK for it to not have one.
          $cs.^add_method("set_{ $att.name }", method (\v) {
            $att.set_value(self, v);
            # Get paramspec matching $att.name
            # if attribute is GObject or GBoxed, then increment the reference
            #   count. The reference count can be unref'd in the objects
            #   DESTROY.
            self.emit("notify::{ $att.name }");
          });

          $cs.^add_method(
            "get_{ $att.name }",
            method ( :$raw = False, :$value = False ) {
              # Get paramspec matching $att.name
              my $attr;
              # Get type from paramspec
              # Initialize a GValue from that type
              my $v;
              self.get_property($name, $v);
              $attr.set_value(self, $v.value);
              return $v if $raw;
              my $o = propReturnObject($v, $raw, |GLib::Value);
              $value ?? $o !! $o.value;
            }
          );

          proceed;
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
          P.new_object(  #
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
          $cs.^add_method("set_{ $att.name }", method (\v) {
            $att.set_value(self, v);
            self.emit("notify::{ $att.name }");
          });

          $cs.^add_method("get_{ $att.name }", method () {
            $att.get_value(self);
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
          say "New paramspec { $name } is a Str";
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
      say "ParamSpec: { $p // '»NOP«' }";
      @props.push: $p if $p;
    }

    when GSignal {
      # Create signal
    }

    $a-idx++;
  }

  CONTROL {
    when CX::Warn { .message.say; .backtrace.concise.say }
  }

  # cw: NEVERMIND!
  # This HAS to be done locally for each class in the ancestry chain!
  # Note that $idx IS PROBABLY local enough.
  my $lc = $cc;
  while ($lc === Any).not {
    say "CC: { $lc.^name }";
    for $lc.^attributes -> $f {
      # my &f;
    #
    #   next unless $_ ~~ GObjectVFunc;
    #
      my $fn = $f.?name // '';
      $fn .= substr(2) if $fn;
      say "VFName: { $fn }";
    #
      # next unless [||](
      #   $_ eq $fn,
      #   $_ eq $fn.&switch-dash
      # );
      given $fn {
        when 'get_property' {
          my &f = sub ($i, $id, $v is copy, $p) {
            if $id !~~ 0 .. $i.^attributes.elems {
              X::GLib::Object::AttributeNotFound.new(
                attribute => $p.name
              ).throw
            }
            $v = GLib::Value.new($v);
            $v.value;
          }

          $lc.get_property = &f;

          say "Get Property: { $lc.get_property }";
        }

        when 'set_property' {
          my &f = sub ($i, $id, $v is copy, $p) {
            say "Setting { $id } to $v.value ({ $v.type }}...";
            $v = GLib::Value.new($v);
            if $id !~~ 0 .. $i.^attributes.elems {
              X::GLib::Object::AttributeNotFound.new(
                attribute => $p.name
              ).throw
            }
            $i.^attributes[$id].set_value($i, $v.value);
          }

          say "Set Property0: { $lc.set_property // '»Null«' }";
          $lc.set_property = &f;
          say "Set Property1: { $lc.set_property }";
        }
      }
    }

    say "Props: { @props.gist }";
    say "LC0: { $lc.^name }";
    $lc = $lc.?parent;
    say "LC1: { $lc.^name }";
    last if $lc =:= Any;
  }

  g_object_class_install_properties(
    # cw: May not always be at .parent. Need's a better mechanism but fine
    #     for now.
    $cc,
    @props.elems,
    ArrayToCArray( GParamSpec, @props )
  );
}

sub standard_instance_init (\struct, \c_struct, $cc is copy, $p) is export {

}

sub register-class-callbacks ($class) {
  say "Registering callbacks for { $class }";

  GLib::Object::TypeModule.add-registration-callback(
    $class,
    # sub ($cc, $_, $is, \f) {
    sub ($cc, $_, \f) {

      my $rcc = cast( ::("{ $class }::Class"), $cc);
      given .gname.substr(2) {
        say "Class Attribute Name: { $_ }";

        return 1;
      }
    }
  )
}

sub standard_register_vfunc ($name) is export {

}


sub resolveToStr ($_ is copy) is export {
  do {
    when GValue {
      my $v = GLib::Value.new($_);

      $v.gtype == G_TYPE_STRING
        ?? $v.string
        !! warn (
             "Cannot resolve GValue to stirng since it says it's a {
             $v.gtype }"
           );
    }

    when gpointer {
      $_ = cast(CArray[uint8], $_); proceed;
    }

    when CArray[uint8] {
      $_ = cast(Str, $_);
    }
  }
}
