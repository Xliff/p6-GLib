use v6.c;
use Method::Also;
use NativeCall;

use GLib::Object::IsType;
use GLib::Raw::Types;
use GLib::Raw::Traits;
use GLib::Raw::Signal;
use GLib::Raw::Debug;
use GLib::Object::Raw::Binding;
use GLib::Object::Raw::ParamSpec;

use GLib::Array;
use GLib::Quark;
use GLib::Signal;
use GLib::Value;
use GLib::Object::Type;
use GLib::Class::Object;

#use GLib::Roles::Bindable;
use GLib::Roles::TypedBuffer;

use GLib::Roles::Protection;
use GLib::Roles::Implementor;
use GLib::Roles::NewGObject;
use GLib::Roles::Signals::Generic;

constant gObjectTypeKey   = 'p6-GObject-Type';
constant gObjectTypeClass = 'raku-GObject-Class';

my (%data, %object-references);

class ProvidesData does Associative {
  has $!p;

  submethod BUILD (:$p) {
    say 'ProvidesData created for ' ~ +($!p = $p)
      if $DEBUG > 3;
  }

  method new ($p) {
    say "ProvidesData P - $p" if $DEBUG // 0 > 3;
    self.bless( :$p );
  }

  method AT-KEY (\k) is rw {
    %data{$!p // ''}{k // ''}
  }

  method EXISTS-KEY (\k) {
    %data{$!p}{k}:exists;
  }

  method clear (\k) {
    %data{$!p}{k}:delete;
  }

  method clear-all {
    self.clear($_) for self.keys;
  }

  method keys {
    %data{$!p // ''}.keys;
  }

  method pairs {
    %data{$!p // '' }.pairs;
  }

}

role GObjectVirtualFunction { }
role DefinedSignalFunction  { }

multi trait_mod:<is> (Method \m, :$vfunc is required) is export {
  m does GObjectVirtualFunction;
}
multi trait_mod:<is> (Method \m, :$signal is required) is export {
  m does DefinedSignalFunction;
}

# To be rolled into GLib::Roles::Object at some point!
role GLib::Roles::Signals::GObject does GLib::Roles::Signals::Generic {

  method connectMultiple (*@specs) {
    for @specs.rotor(2) -> ($name, &callback) {
      self."$name"().tap(&callback);
    }
  }

  # GObject, GParamSpec, gpointer
  method connect-notify (
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    return $_ with self.getSignal($signal);
    my $sig //= do {
      my $s = Supplier.new;
      $hid = g_connect_notify($obj, $signal,
        -> $, $ps, $ud --> gboolean {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $ps, $ud] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    $sig[0].tap(&handler) with &handler;
    self.setSignal($signal, $sig)[0];
  }

}

# cw: Time to grow up.
my %cleanup-classes;

sub register-gobject-cleanup-class ($c, &callback) is export {
  %cleanup-classes{ $c } = &callback;
}

role GLib::Roles::Object::Cleanup[$class] {
  method cleanup-classes { callsame(), $class }
}

role GLib::Roles::Object {
#  also does GLib::Roles::Bindable;
  also does GLib::Roles::Protection;
  also does GLib::Roles::Implementor;
  also does GLib::Roles::Signals::GObject;

  has GObject $!o;

  has         $!run-cleanup = True;

  has $!data-proxy;
  has $!object-set;

  submethod DESTROY {
    $!data-proxy.clear-all;

    return unless $!run-cleanup;

    if self.?cleanup-classes -> $c {
      for $c.Array {
        if %cleanup-classes{ $_ } -> &f {
          &f(self)
        }
      }
    }
  }

  method unregister-cleanup {
    $!run-cleanup = False;
  }

  # cw: A method for proper GObject destruction? Also see: !setObject
  # submethod DESTROY {
  #   my $r := %object-references{ +$!o.p };
  #
  #   $r--;
  #   %object-references{ +$!o.p }:delete unless $r;
  # }

  # cw: Must be called using the self.GLib::Roles::Objects.attributes
  #     form.
  method attributes ($key) {
    if self ~~ GLib::Roles::NewGObject {
      # cw: Search for trait added attributes if this is a pure
      #     Raku object
    }

    # cw: -XXX- This is obviously incomplete. Please finish!

    X::GLib::Object::AttributeNotFound.new(attribute => $key).throw;
  }

  # method get_property is vfunc {
  #   # cw: Better, except where are you going to get self from when this
  #   #     needs to be set BEFORE an instance can be created.
  #   my $s = self;
  #   my $c = ::?CLASS;
  #   sub ($, $idx, $v is copy, $p is copy) {
  #     $v = GLib::Value.new($v);
  #     $p = GLib::Object::ParamSpec.new($p);
  #
  #     if $idx !~~ 0 .. $c.^attributes.elems {
  #         X::GLib::Object::AttributeNotFound.new(
  #           attribute => $p.name
  #         ).throw
  #       }
  #       # cw: This CANNOT be done. The value needs to come from the
  #       #     paramspec and then passed to Raku.
  #       $v.value = $c.^attributes[$idx].get_value($s);
  #     }
  #   }
  # }

  method gist-data {
    %data.gist;
  }

  method initAllRoles ($prefix) {
    self.?"roleInit-{ $prefix.tc }{ .[1] }"()
      for self.^roles.unique
                     .map({ [ .^name, .^shortname ] })
                     .grep({
                       [&&](
                         .[0].starts-with($prefix),
                         .[0].contains('Signals').not
                       )
                     });
  }

  method new-object-obj (::?CLASS:U: GObject $object) {
    $object ?? self.bless( :$object ) !! Nil;
  }

  method new-object-ptr (::?CLASS:U: Int() $type) {
    my GType $t = $type;

    g_object_new($t, Str);
  }

  method new-raw {
    self.new-object-ptr( self.get_type );
  }
  method new_raw {
    self.new-raw
  }

  proto method new_object_with_properties (|c)
    is also<new-object-with-properties>
  {
    say "{ '-' x 20 }";

    for |c.list.kv -> $k, $v {
      say "Positional Param #{ $k.succ }: { $v.^name }";
    }

    for |c.hash.pairs {
      say "Named Param { .key }: { .value.^name }";
    }

    {*}
  }

  # RAW capitalized to prevent conflict with a potential GObject's "raw"
  # property
  multi method new_object_with_properties (
    *@args,
    :$TYPE,
    :$RAW                   =  False,
    :pairs(:$p) is required
  ) {
    if checkDEBUG() {
      say "P: \@args";
      say "\tK: { .key } / V: { .value // '<<NIL!>' }" for @args;
    }
    die 'Array passed to .new_object_with_properties must have an even number of elements!'
      unless @args.elems %% 2;

    samewith( :$TYPE, |@args.Hash )
  }
  multi method new_object_with_properties (:$RAW = False, :$TYPE, *%props) {
    my (@names, @values);

    if checkDEBUG() {
      say "P: \%props";
      say "\tK: { .key } / V: { .value // '<<NIL!>>' }" for %props.pairs;
    }

    my %v-props = self.resolveCreationOptions( |%props );
    for %v-props.keys {
      @names.push:  $_;
      @values.push: %v-props{$_};
    }

    samewith(
      @names.elems,
      ArrayToCArray(Str, @names),
      GLib::Roles::TypedBuffer[GValue].new(@values).p,
      raw  => $RAW,
      type => $TYPE
    );
  }
  multi method new_object_with_properties (
    Int()        $num-props,
    CArray[Str]  $names,
    Pointer      $values,
                :$raw        = False,
    Int()       :$type       = Int,
  ) {
    my guint $n = $num-props;
    my GType $t = $type // ::?CLASS.get_type;

    say "T: { GLib::Object::Type.new($t).name }" if checkDEBUG(2);
    say "CLASS = { ::?CLASS.^name }"             if checkDEBUG(2);

    my $object = g_object_new_with_properties(
      $t,
      $n,
      $names,
      $values
    );

    say "Object name: { ::?CLASS.^name }" if checkDEBUG(2);
    say "Object value: { $$object }"      if checkDEBUG(2);

    $object ?? ( $raw ?? $object !! self.new( $object, :!ref ) )
            !! Nil;
  }

  multi method setAttributes (@pairs) {
    my ($keys, $values);

    for @pairs {
        $keys.push: .key;
      $values.push: .value;
    }
    samewith($keys, $values);
  }
  multi method setAttributes (*%hash) {
    samewith(%hash);
  }
  multi method setAttributes (%hash) {
    samewith( %hash.keys, %hash.values );
  }
  multi method setAttributes ($names, $values) {
    for $names.pairs {
      say "Setting { .value } to {
           $values[ .key ].gist } for a { self.^name } object"
      if checkDEBUG(2);

      if self.^can( .value ) {
        self."{ .value }"() = $values[ .key ];
        next;
      }

      if .value.contains('-') || .value.contains('_') {
        my $fallback = .value.&switch-dash;
        if self.^can($fallback) {
          self."{ $fallback }"() = $values[ .key ];
          next;
        }
      }

      warn "Unknown key '{ .value }' used in .setAttributes!";
      Backtrace.new.concise.say if checkDEBUG;
    }
    self;
  }

  # Not inherited. Punned directly to the object. So how is that gonna work?
  method resolveCreationOptions (*%options) {
    my (%new-opts, %not-found);

    say "O: { %options.keys }" if checkDEBUG(3);
    for %options.pairs -> $a {
      say "K: { $a.key }" if checkDEBUG(3);

      next if $a.value ~~ (GValue, GLib::Value).any;
      if self.attributes( $a.key ) -> $attr {
        say "V: { $attr !~~ Array
                    ?? $attr
                    !! ($attr[0], $attr[1].^name, $attr[2]).join(', ') }"
        if checkDEBUG(3);

        # Available for GLib::Object descendents
        given $attr {
          my $v = $a.value;

          when Array {

            quietly {
              # cw: WTF are UNDEF warnings being emitted on the 'when' lines,
              #     when there's no case of anything undef being used in
              #     string context, here! These needed to be muted, hence
              #     the `quietly` block. 09/10/2020

              when 'enum' {
                # ['enum', EnumTypeObject, EnumGType:optional ]
                .value = GLib::Value(
                  .[2].defined ?? .[2] !! GLib::Value.gtypeFromEnum( .[1] )
                );
                .value.valueFromEnum( .[1] ) = $v;
              }

              when 'boxed' | 'object' {
                # [ '<boxed | object>', ObjectType, ObjectGType ]
                my $meth = $_;
                $meth = 'pointer' if $meth eq 'boxed';

                  .value = GLib::Value.new( .[2] );
                  # cw: Assign .value the Pointer representation of an object, and
                  #     if necessary, coerce.s
                  .value."{ .[0] }"() =
                    ( $v ~~ .[1] ) ?? $v
                                   !! $v."{ .[1].^shortname }"()
              }
            }

            default {
              die "Invalid type! Valid attribute types are: 'boxed', 'enum' and 'object'"
                unless .[0] eq <boxed object>.any;
            }
          }

          when G_TYPE_OBJECT  { %new-opts{$a.key} = gv_obj($v)    }
          when G_TYPE_INT     { %new-opts{$a.key} = gv_int($v)    }
          when G_TYPE_UINT    { %new-opts{$a.key} = gv_uint($v)   }
          when G_TYPE_INT64   { %new-opts{$a.key} = gv_int64($v)  }
          when G_TYPE_UINT64  { %new-opts{$a.key} = gv_uint64($v) }
          when G_TYPE_STRING  { %new-opts{$a.key} = gv_str($v)    }
          when G_TYPE_FLOAT   { %new-opts{$a.key} = gv_flt($v)    }
          when G_TYPE_DOUBLE  { %new-opts{$a.key} = gv_dbl($v)    }
          when G_TYPE_BOOLEAN { %new-opts{$a.key} = gv_bool($v)   }
          when G_TYPE_POINTER { %new-opts{$a.key} = gv_ptr($v)    }
        }
        #%options{ $a.key }:delete;
      }
    }

    %new-opts;
  }

  method roleInit-Object {
    my \i = findProperImplementor(self.^attributes);
    my $o = i.get_value(self);

    self!setObject($o);
  }

  my %signal-object-cache;
  method Signal {
    # cw: Cached by class name?
    my $s = self;

    %signal-object-cache{ $s.^name } = (class :: {
      also does Associative;

      method AT-KEY (\k) {
        my $key = k.split(/ <[_\ -]> /).map( *.lc.tc ).join('-');
        say "Signal: { $key }" if checkDEBUG();
        $s."{ $key }"()
      }
    }).new;
  }

  # cw: This one is is NOT overridable
  multi method getClass ( :$base is required where *.so, :$raw = False ) {
    self.ρ-getClass(GObjectClass, ::('GLib::Class::Object'), :$raw);
  }
  multi method getClass ( ::?CLASS:U: :$raw = False) {
    self.ρ-getClass(self.class_ref, ::('GLib::Class::Object'), :$raw);
  }
  method ρ-getClass ($CS is raw, $C is raw, :$raw = True) {
    my $p := cast(Pointer.^parameterize($CS), $!o.g_type_instance.g_class);
    my $c := $CS.REPR eq 'CStruct' ?? $p.deref !! $p;

    #say "ρ-getClass: { $CS.^name }, { $C.^name }, { $raw }";

    $c ??
      ( $raw ?? $c !! $C.new($c) )
      !!
      Nil;
  }

  # Move to camelCase for routines I've added to distinguish them from
  # GLib-linked methods.
  multi method objectType (::?CLASS:D: :$raw = False) {
    ::?CLASS.objectType($!o, :$raw);
  }
  multi method objectType (::?CLASS:U: :$raw = False ) {
    say "S: { self.^name }";
    my $t = self.get_type;
    say "T:  { $t }";
    GLib::Object::Type.new($t);
  }
  multi method objectType (::?CLASS:U: $o where *.defined, :$raw = False) {
    my $t = $o.g_type_instance.g_class.g_type;
    return $t if $raw;

    GLib::Object::Type.new($t);
  }

  method list_properties {
    # flat do for self.^mro -> \o {
    #   last if     o === Any;
    #   next unless o ~~  GLib::Roles::Object;

    my guint $np = 0;
    my $a = CArrayToArray(
      g_object_class_list_properties(
        self.GObject.p,
        $np
      ),
      |GLib::Object::ParamSpec.getTypePair
    );
    say "{ self.^name } - {$a.elems }";
    $a;
    # }
  }
  method list-properties {
    self.list_properties;
  }

  method isType (Int() $type) {
    my GType $t  = $type;
    my       $gc = $!o.g_type_instance.g_class;

    return False unless $!o;
    return True  if     $gc && $gc.g_type == $t;

    return g_type_check_instance_is_a($!o.g_type_instance, $t);
  }

  # method !onFirstGObject ($value?) {
  #   # This REALLY should never be necessary.
  #   for self.^attributes {
  #     next unless .name eq '$!o';
  #     .set_value( self, $value ) if $value;
  #     return .get_value(self);
  #   }
  # }

  method !setObject ($obj) {
    say "SetObject ({ self }): { $obj }" if checkDEBUG;
    $!o = $obj ~~ GObject ?? $obj !! cast(GObject, $obj);
    say "ObjectSet ({ self })-+-: { $!o }" if checkDEBUG;
    $!data-proxy = ProvidesData.new(+$!o.p);
    self.setObjectClass;
    # Raku reference count of a GObject
    #%object-references{ +$!o.p }++
  }

        method p       { $!o.p }
  multi method Numeric { +self.p }

  method GLib::Raw::Object::GObject
  { $!o }

  # Remove when Method::Also is fixed!
  method GObject { $!o }

  method equals (GObject() $b) { self.p.equals($b) }
  method is     (GObject() $b) { self.equals($b)   }
  method eq     (GObject() $b) { self.equals($b)   }

  method notify ($detail?) {
    my $sig-name = 'notify';
    $sig-name ~= "::{$detail}" if $detail;

    self.connect-notify($!o, $sig-name);
  }

  method emit-notify ($prop) {
    self.emit_notify($prop);
  }
  method emit_notify ($prop) {
    g_object_notify($prop);
  }

  multi method emit (Str() $signal) {
    g_signal_emit_by_name($!o, $signal, Str);
  }

  multi method emit ( $signal, *@a, :$detail, :$raw = False ) {
    my $d = GQuark;
    $d = GLib::Quark.from-string($detail) if $detail;

    my $signal-id = g_signal_lookup($signal, self.get_type);
    return unless $signal-id;

    # This should probably be moved to a generic routine.
    # Check ::Raw::Subs for prior art!
    @a.unshift: .GObject;
    my @ap = do gather for @a {
      if $_ ~~ GValue {
        take $_;
        next;
      }

      if $_ ~~ GLib::Value {
        take .GValue;
        next;
      }

      if $_ ~~ (GObject, GLib::Roles::Object).any {
        take gv_obj($_);
        next;
      }

      if $_ ~~ Array {
        my $v = do given .tail {
          when G_TYPE_CHAR     { gv_str($_)    }
          when G_TYPE_UCHAR    { gv_str($_)    }
          when G_TYPE_BOOLEAN  { gv_bool($_)   }
          when G_TYPE_INT      { gv_int($_)    }
          when G_TYPE_UINT     { gv_uint($_)   }
          when G_TYPE_LONG     { gv_int64($_)  }
          when G_TYPE_ULONG    { gv_uint64($_) }
          when G_TYPE_INT64    { gv_int64($_)  }
          when G_TYPE_UINT64   { gv_uint64($_) }
        }
        take $v if $v;

        X::GLib::Error.new(
          "A value type of { .tail } is not currently known to
           the emit type resolution handler for a { .head.^name } value"
        ).throw;
      }

      take valueToGValue($_);
    }
    my $iAndP = GLib::Array.new(@ap);

    my $r = GValue.new;

    g_signal_emitv($iAndP, $signal-id, $d, $r);
    propReturnObject($r, $raw, |GLib::Value.getTypePair);
  }

  method freeze-notify {
    self.freeze_notify;
  }
  method freeze_notify {
    g_object_freeze_notify($!o);
  }

  method unfreeze_notify {
    self.thaw_notify;
  }
  method unfreeze-notify {
    self.thaw_notify;
  }
  method thaw-notify {
    self.thaw_notify;
  }
  method thaw_notify {
    g_object_thaw_notify($!o);
  }

  # We use these for inc/dec ops
  method ref   is also<upref>   {   g_object_ref($!o); self; }
  method unref is also<downref> { g_object_unref($!o); }

  method !processFlags ($default, $create, $dual, $not, $flags) {
    my $f = 0;
    $f = $flags if $flags;
    unless $f {
      $f +|= G_BINDING_DEFAULT        if $default;
      $f +|= G_BINDING_BIDIRECTIONAL  if $dual;
      $f +|= G_BINDING_SYNC_CREATE    if $create;
      $f +|= G_BINDING_INVERT_BOOLEAN if $not;
    }
    $f;
  }

  multi method bind (
    Str  $source_property,
    Str  $target_property,
        :$create                    = True,
        :$default                   = True,
        :bi(:both(:$dual))          = False,
        :invert(:$not)              = False,
        :$flags            is copy  = 0
  ) {
    samewith(
      $source_property,
      self,
      $target_property,

      flags => self!processFlags($default, $create, $dual, $not, $flags)
    );
  }
  multi method bind (
    Str()      $source_property,
    GObject()  $target,
              *%a where *.elems == 0
  ) {
    samewith($source_property, $target, :create);
  }
  multi method bind (
    *%args,
    :$create                    = True,
    :$default                   = False,
    :bi(:both(:$dual))          = False,
    :invert(:$not)              = False,
    :$flags            is copy  = 0
  ) {
    for %args.pairs {
      samewith(
        .key,
        .value,
        flags => self!processFlags($default, $create, $dual, $not, $flags)
      );
    }
  }
  multi method bind (
    Str()      $source_property,
    GObject()  $target,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    samewith(
      $source_property,
      $target,
      $source_property,
      self!processFlags($default, $create, $dual, $not, $flags)
    );
  }
  multi method bind (
    Str()      $source_property,
    GObject()  $target,
    Str        $target_property,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    samewith(
      $source_property,
      $target,
      $target_property,
      self!processFlags($default, $create, $dual, $not, $flags)
    );
  }

  multi method bind-swapped (
    Str()      $source_property,
    GObject()  $target,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    samewith(
      $source_property,
      $target,
      $source_property,
      self!processFlags($default, $create, $dual, $not, $flags)
    );
  }
  multi method bind-swapped (
    Str()      $source_property,
    GObject()  $target,
    Str        $target_property,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    samewith(
      $source_property,
      $target,
      $target_property,
      self!processFlags($default, $create, $dual, $not, $flags)
    );
  }

  # Arity 3 will conflict with another multi
  method bind-property (
    Str()      $source_property,
    GObject()  $target,
    Str        $target_property,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    self.bind_property(
       $source_property,
       $target,
       $target_property,
      :$create,
      :$default,
      :$dual,
      :$not,
      :$flags
    );
  }

  method bind_property (
    Str()      $source_property,
    GObject()  $target,
    Str        $target_property,
              :$create                    = True,
              :$default                   = False,
              :bi(:both(:$dual))          = False,
              :invert(:$not)              = False,
              :$flags            is copy  = 0
  ) {
    self.bind(
      $source_property,
      $target,
      $target_property,
      self!processFlags($default, $create, $dual, $not, $flags)
    );
  }


  multi method bind (
    Str()     $source_property,
    GObject() $target,
    Int       $flags            is copy
  ) {
    $flags .= Int unless $flags ~~ Int;
    samewith($source_property, $target, $source_property, $flags);
  }
  multi method bind (
    Str()     $source_property,
    GObject() $target,
    Str()     $target_property,
    Int()     $flags
  ) {
    say "Binding { $source_property } of { self } to {
         $target_property } of { $target } with flags of { $flags }"
    if checkDEBUG;

    g_object_bind_property(
      $!o,
      $source_property,
      $target,
      $target_property,
      $flags
    )
  }

    multi method bind-swapped (
      Str()     $source_property,
      GObject() $target,
      Str()     $target_property,
      Int()     $flags
    ) {
      say "Binding to { $source_property } of { self } from {
           $target_property } of { $target } with flags of { $flags }";

      g_object_bind_property(
        $target,
        $target_property,
        $!o,
        $source_property,
        $flags
      )
    }

  multi method bind_full(
    Str()      $source_property,
    GObject()  $target,
               &transform_to               = Callable,
               &transform_from             = Callable,
    gpointer   $user_data                  = Pointer,
               &notify                     = %DEFAULT-CALLBACKS<GDestroyNotify>,
              :$create                     = True,
              :$default                    = False,
              :bi(:both(:$dual))           = False,
              :invert(:$not)               = False,
              :$flags            is copy   = 0
  ) {
    samewith(
      $source_property,
      $target,
      $source_property,
      self!processFlags($default, $create, $dual, $not, $flags),
      &transform_to,
      &transform_from,
      $user_data,
      &notify
    );
  }
  multi method bind_full (
    Str()     $source_property,
    GObject() $target,
    Int()     $flags,
              &transform_to   = Callable,
              &transform_from = Callable,
    gpointer  $user_data      = Pointer,
              &notify         = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    samewith(
      $source_property,
      $target,
      $source_property,
      $flags,
      &transform_to,
      &transform_from,
      $user_data,
      &notify
    );
  }
  multi method bind_full (
    Str()                 $source_property,
    GObject()             $target,
    Str()                 $target_property,
    Int()                 $flags,
                          &transform_to   = Callable,
                          &transform_from = Callable,
    gpointer              $user_data      = Pointer,
                          &notify         = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    g_object_bind_property_full(
      $!o,
      $source_property,
      $target,
      $target_property,
      $flags,
      &transform_to,
      &transform_from,
      $user_data,
      &notify
    );
  }

  multi method bind_with_closures (
    Str()      $source_property,
    GObject()  $target,
    Int()      $flags,
    GClosure() $transform_to   = GClosure,
    GClosure() $transform_from = GClosure
  ) {
    samewith(
      $source_property,
      $target,
      $source_property,
      $flags,
      $transform_to,
      $transform_from
    );
  }
  multi method bind_with_closures (
    Str()      $source_property,
    GObject()  $target,
    Str()      $target_property,
    Int()      $flags,
    GClosure() $transform_to      = GClosure,
    GClosure() $transform_from    = GClosure
  ) {
    g_object_bind_property_with_closures(
      $!o,
      $source_property,
      $target,
      $target_property,
      $flags,
      $transform_to,
      $transform_from
    );
  }

  # cw: -YYY- Do we need this now that we have the .is_a method?
  method check_gobject_type($compare_type) {
    my $o = nativecast(GTypeInstance, $!o);

    $o.checkType($compare_type);
  }

  method getType {
    self.prop_get_string(gObjectTypeKey);
  }

  method getObjectClass {
    self.prop_get_string(gObjectTypeClass);
  }

  method setType ($typeName) {
    my $oldType = self.getType;
    self.prop_set_string(gObjectTypeKey, $typeName) unless $oldType.defined;
    warn "WARNING -- Using a $oldType as a $typeName"
      unless [||](
        %*ENV<P6_GTK_DEBUG>.defined.not,
        $oldType.defined.not,
        $oldType eq $typeName
      );
  }

  method setObjectClass {
    self.prop_set_string(gObjectTypeClass, self.^name) unless
      self.getObjectClass.defined
  }

  # For storing Raku data types.
  method get-data ($k) {
    %data{+$!o.p}{$k};
  }

  method set-data ($k, $v) {
    say "Setting { $k } to { $v } for { +$!o.p }..." if $DEBUG;

    %data{+$!o.p}{$k} = $v;
  }

  method unset-dassta ($k) {
    %data{+$!o.p}{$k}:delete if %data{+$!o.p}{$k}:exists;
  }

  # cw: Provides a hash-like interface at this method.
  #     Will To replace the above 3 methods.
  method data {
    $!data-proxy = ProvidesData.new($!o) unless $!data-proxy;
    $!data-proxy;
  }

  method !checkNames(@names) {
    @names.map({
      if $_ ~~ Str {
        $_;
      } else {
        unless .^can('Str').elems {
          die "$_ value cannot be coerced to string.";
        }
        .Str;
      }
    });
  }

  method !checkValues(@values) {
    @values.map({
      if $_ ~~ GValue {
        $_;
      } else {
        unless .^can('GValue').elems {
          die "$_ value cannot be coerced to GValue";
        }
        .GValue;
      }
    });
  }

  method clear_object {
    # Until a better place can be found...
    sub g_clear_object ( CArray[Pointer[GObject]] )
      is native(gobject)
      { * }

    my $op = CArray[Pointer[GObject]].new;
    $op[0] = cast(Pointer[GObject], $!o);
    g_clear_object($op);
  }

  method is_type(GObjectOrPointer $t) {
    is_type($t, self);
  }

  method gobject_get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_object_get_type, $n, $t );
  }


  multi method get_property (|)
    is also<get-property>
  { * }

  multi method get_property (Str() $name, GValue() $value, :$raw = False)  {
    g_object_get_property($!o, $name, $value);

    propReturnObject($value, $raw, |GLib::Value.getTypePair);
  }

  method set_property (Str() $name, GValue() $value) {
    g_object_set_property($!o, $name, $value);
  }

  method getPropertyNames {
    self.^attributes.grep( * ~~ PropertyMethod ).map( *.name );
  }

  method getAttributeNames {
    self.^attributes.grep( * ~~ AttributeMethod ).map( *.name );
  }

  method prop_set (Str() $name, GValue() $value) is also<prop-set> {
    self.set_prop($name, $value);
  }

  proto method set_prop (|)
    is also<set-prop>
  { * }

  multi method set_prop(Str() $name, GValue() $value) {
    samewith( [$name], [$value] );
  }
  multi method set_prop(@names, @values) {
    say "N: { @names.join(', ') }" if $DEBUG;
    say "V0: { @values[0].^name }" if $DEBUG;

    my @n = self!checkNames(@names);
    my @v = self!checkValues(@values);

    die 'Mismatched number of names and values when setting GObject properties.'
      unless +@n == +@v;

    my guint $ne = @n.elems;

    die 'Cannot set properties with an empty array!' unless $ne > 0;

    say "V1: { @v[0].p }" if $DEBUG;

    g_object_setv( $!o, $ne, ArrayToCArray(Str, @names), @v[0].p );
  }

  method prop_get(Str() $name, $value is copy, :$raw = True)
    is also<prop-get>
  {
    my $compatible = $value ~~ GValue;
    my $coercible  = $value.^lookup('GValue');

    die '$value must be GValue-compatible!' unless $compatible || $coercible;

    $value .= GValue if $coercible && $value ~~ GLib::Value;

    self.get_prop($name, $value, :$raw);
  }

  proto method get_prop (|)
    is also<get-prop>
  { * }

  multi method get_prop (Str $name, Int $type, :$raw = True) {
    my @v = ( GLib::Value.new($type).GValue );

    samewith( [ $name ], @v );

    propReturnObject(@v[0], $raw, |GLib::Value.getTypePair);
  }
  multi method get_prop (Str() $name, GLib::Value $value, :$raw = True) {
    my $vp = $value.GValue;

    samewith($name, $vp);
    propReturnObject($vp, $raw, |GLib::Value.getTypePair);
  }
  multi method get_prop (Str() $name, GValue $value, :$raw = True) {
    my @v = ($value);

    samewith( $name.Array, @v );
    propReturnObject($value, $raw, |GLib::Value.getTypePair);
  }
  multi method get_prop (@names, @values) {
    my @n = self!checkNames(@names);
    my @v = self!checkValues(@values);

    die 'Mismatched number of names and values when setting GObject properties.'
      unless +@n == +@v;

    my CArray[Str] $n = CArray[Str].new;
    my $i = 0;
    $n[$i++] = $_ for @n;
    # my CArray[GValue] $v = CArray[GValue].new;
    # $i = 0;
    # $v[$i++] = $_ for @v;

    # -XXX- NOT a general purpose fix, but will work for now.
    my guint32 $ne = $n.elems;
    die 'Cannot get properties with an empty array!' unless $ne > 0;

    g_object_getv( $!o, $ne, $n, @v[0].p );

    # @values = ();
    # @values.push( GLib::Value.new($v[$_]) ) for (^$v.elems);

    # Be perlish with the return. -- Maybe do @values[$_].value
    if @names.elems > 1 {
      # Return value
      %(do for (^@names.elems) {
        @names[$_] => @values[$_];
      });
    } else {
      # Return value
      @values[0];
    }
  }

  method prop_set_bool(Str() $key, Int() $val)
    is also<prop-set-bool>
  {
    my gboolean $v = $val.so.Int;

    self.prop_set_uint_data($v);
  }

  method prop_get_bool (Str() $key) is also<prop-get-bool> {
    so self.prop_get_uint_data($key);
  }

  method prop_set_string(Str() $key, Str() $val)
    is also<prop-set-string>
  {
    g_object_set_string_data($!o, $key, $val);
  }

  method prop_get_string(Str() $key) is also<prop-get-string> {
    g_object_get_string_data($!o, $key);
  }

  method prop_set_ptr (Str() $key, Pointer $val = Pointer)
    is also<prop-set-ptr>
  {
    g_object_set_ptr_data($!o, $key, $val);
  }

  method prop_get_ptr (Str() $key) is also<prop-get-ptr> {
    g_object_get_ptr_data($!o, $key);
  }

  method prop_set_int (Str() $name, Int() $value) is also<prop-set-int> {
    g_object_set_int_data($!o, $name, $value);
  }

  method prop_get_int (Str() $name) is also<prop-get-int> {
    my $a = g_object_get_int_data($!o, $name);

    ( $a && $a[0] ) ?? $a[0] !! Nil;
  }

  method prop_set_uint (Str() $name, Int() $value) is also<prop-set-uint> {
    my $v = CArray[guint].new;
    $v[0] = $value;

    g_object_set_uint_data($!o, $name, $v);
  }

  method prop_get_uint(Str() $name) is also<prop-get-uint> {
    my $a = g_object_get_uint_data($!o, $name);

    ( $a && $a[0] ) ?? $a[0] !! Nil;
  }

  method delete_data (Str() $key) {
    %data{+$!o.p}{$key}:delete;
  }

  method clear_data (Str() $key) is also<clear-data> {
    g_object_set_ptr($!o, $key, Pointer);
  }

  method !get-data-abstract(@keys, \T, &f) {
    @keys = @keys.map({
      die 'Elements in @keys must be Str-compatible!'
        unless $_ ~~ Str || .^lookup('Str');
      .Str;
    });

    my @a = do for @keys {
      my $v = CArray[T].new;
      $v[0] = T;

      say "{ $_ }: { $v.^name } ({ &f.name })";

      f($!o, $_, $v, Str);
      cast(CArray[uint8], $v);
    };

    @a.elems == 1 ?? @a.head !! @a;
  }

  method get_data_ptr (*@keys) {
    self!get-data-abstract(@keys, Pointer, &g_object_get_ptr);
  }
  method get_data_int64 (*@keys) {
    self!get-data-abstract(@keys,  gint64, &g_object_get_int64);
  }
  method get_data_uint64 (*@keys) {
    self!get-data-abstract(@keys, guint64, &g_object_get_uint64);
  }
  method get_data_int (*@keys) {
    self!get-data-abstract(@keys,    gint, &g_object_get_int);
  }
  method get_data_uint (*@keys) {
    self!get-data-abstract(@keys,   guint, &g_object_get_uint);
  }
  method get_data_string (*@keys) {
    self!get-data-abstract(@keys,     Str, &g_object_get_string);
  }
  method get_data_float (*@keys) {
    self!get-data-abstract(@keys,  gfloat, &g_object_get_float);
  }
  method get_data_double (*@keys) {
    self!get-data-abstract(@keys, gdouble, &g_object_get_double);
  }

  method !set-data-abstract(@pairs, ::T, ::NT, &f) {
    @pairs .= map({ $_ ~~ Pair ?? |(.key, .value) !! $_ });

    die 'Cannot use array with odd number of elements!'
 +@pairs % 2 == 0;

    @pairs = @pairs.rotor(2).map({
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[0] ~~ Str || .^lookup('Str');
      die 'Elements in @pairs must be Str, { T.^name } groups!'
        unless .[1] ~~ T || ( my $m = .^lookup(T.^name) );

      ( .[0].Str, $m( .[1] ) );
    });

    for @pairs -> ($k, $v) {
      f($!o, $k, $v, Str);
    }
  }

  method set_data_ptr (*@pairs) {
    self!set-data-abstract(@pairs,   Mu, Pointer, &g_object_set_ptr);
  }
  method set_data_int64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int,  gint64, &g_object_set_int64);
  }
  method set_data_uint64 (*@pairs) {
    self!set-data-abstract(@pairs,  Int, guint64, &g_object_set_uint64);
  }
  method set_data_int (*@pairs) {
    self!set-data-abstract(@pairs,  Int,    gint, &g_object_set_int);
  }
  method set_data_uint (*@pairs) {
    self!set-data-abstract(@pairs,  Int,   guint, &g_object_set_uint);
  }
  method set_data_string (*@pairs) {
    self!set-data-abstract(@pairs,  Str,     Str, &g_object_set_string);
  }
  method set_data_float (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_object_set_float);
  }
  method set_data_double (*@pairs) {
    self!set-data-abstract(@pairs,  Num, gdouble, &g_object_set_double);
  }

  method listSignals ( :$raw = False ) {
    my $t = self.objectType;

    my $ids = GLib::Signal.list_ids($t.Int);
    return $ids if $raw;

    $ids ?? $ids.map({ GLib::Signal.query($_) }) !! Nil;
  }

  method getPropertyMethods {
    self.^methods.grep( * ~~ PropertyMethod )
  }

  method listProperties {
    self.getPropertyMethods.map( *.name );
  }

  method getProperties {
    my %dup;
    self.getPropertyMethods.map({
      do unless %dup{ .name } {
        %dup{ .name } = 1;
        |[ .name, $_(self) ]
      }
    }).Hash;
  }

  method Str {
    self.defined.not
      ?? "({ self.^name })"
      !! ( self.^can('debug') ?? self.debug !! nextsame )
  }

  method debug ($n = 1) {
    qq:to/RAKU/;
      { self.^name } -->
      { self.getProperties.pairs
                          .map({
                             my $v = .value;
                             do if $v {
                               "{ "\t" x $n }{ .key } = { $v.^can('debug')
                                   ?? $v.debug($n + 1)
                                   !! $v.Str }"
                             }
                           })
                          .join("\n") }
      RAKU
  }

  method registerClasses {
    say 'NYI - Class registration!'
  }

  # cw: Find a better interface for this. I am very wary of having anything
  #     starting with "class_" in an object. However, this being GType
  #     I'm willing to make an exception for the following:
  method class_ref is also<class-ref> {
    g_type_class_ref(self.get_type);
  }

  method class_unref (GLib::Object::Type:U: gpointer $c)
    is also<class-unref>
  {
    g_type_class_unref($c);
  }

}

class GLib::Object does GLib::Roles::Object {

  submethod BUILD ( :$object, *%a ) {
    self!setObject($object) if $object;

    # Check if Object type needs to be registered by smartmatching
    # against NewGObject
    if self ~~ GLib::Roles::NewGObject {
      self.GLib::Roles::NewGObject::BUILD( |%a );
      # Add signals if the object does Signalling

      # Add properties based on traits set on attributes if
      # said attribute names appear via the RegisteredAttribute class
      # trait.

      # cw: Check on availability of 'will' trait which might make #3
      #     more gramatically palatable.
    }
  }

  method setGObject (GObject $_) {
    self!setObject($_);
  }

  multi method new (
     $object where $object ~~ GObject || $object.^can('GObject'),
    :$ref                                                         = True
  ) {
    $object .= GObject unless $object ~~ GObject;

    return Nil unless $object;

    my $o = self.bless( :$object );
    $o.ref if $ref;
    $o;
  }

  multi method new (
     $obj-type where $obj-type ~~ Int || $obj-type.can('Int'),

    :$no-bless = False
  ) {
    my $object = g_object_new($obj-type, Str);
    return $object if $no-bless;

    $object ?? self.bless( :$object ) !! Nil;
  }

  method get_type is also<get-type> {
    self.gobject_get_type;
  }

}

&GOBJECT     = sub { GLib::Roles::Object }
&GLIB-OBJECT = sub { GLib::Object        }

role GLib::Roles::Object::RegisteredType[$gtype] {

  method get_type is also<get-type> { $gtype };

}

my @classes-to-register;

role GLib::Object::RegisterClass {
  INIT @classes-to-register.push: ::?CLASS;
}

role GLib::Roles::Object::Registrar[$n] {

  method registers-for { $n }

}

my %object-registrar;

sub add-object-registrar( GLib::Roles::Object::Registrar $r ) is export {
  %object-registrar{ $r.registers-for } := $r;
}


sub g_connect_notify (
  GObject $app,
  Str     $name,
          &handler (GObject $h_widget, GParamSpec $pspec, Pointer $h_data),
  Pointer $data,
  uint32  $connect_flags
)
  returns uint64
  is native('gobject-2.0')
  is symbol('g_signal_connect_object')
{ * }

sub g_object_get_property (GObject $o, Str $key, GValue $value)
  is native(gobject)
  is export
{ * }

sub g_object_set_property (GObject $o, Str $key, GValue $value)
  is native(gobject)
  is export
{ * }

sub g_object_get_type
  returns GType
  is      native(gobject)
  is      export
{ * }

sub g_type_class_ref (GType $type)
  returns Pointer
  is      native(gobject)
  is      export
{ * }

sub g_type_class_unref (gpointer $g_class)
  is      native(gobject)
  is      export
{ * }

multi sub infix:<=:=> (
  GLib::Roles::Object $a,
  GLib::Roles::Object $b
)
  is export
{
  $a.equals($b);
}
