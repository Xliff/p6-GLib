use v6.c;

use GLib::Raw::Definitions;
use GLib::Raw::Exceptions;

unit package GLib::Raw::Traits;

role GObjectDerived[$type?] is export {
  use NativeCall;

  # Unfortunate need for redefinition, but don't want to depend on
  # ::Roles::Object

  sub g_object_get_type
    returns uint64
    is native(gobject)
  { * }

  method object-type {
    $type // g_object_get_type()
  }
}

role GObjectVFunc[$vfn?] is export {
  method g-vfunc-name { $vfn }
}

role PropertyMethod       is export { }
role PseudoPropertyMethod is export { }
role AttributeMethod      is export { }
role AccessorMethod       is export { }

role BoxedType[$type?] is export {

  method boxed-type {
    # G_TYPE_BOXED
    $type // (18 +< 2)
  }

}

role GAttribute[$desc = ''] is export {
  method blurb { $desc }
}

role GDefault[$value] is export {
  method default-value { $value }
}

role GSignal         is export { }
role NoReturn        is export { }

role Signalling[@Signals] {
  method defined-signals { @Signals }
}

role RangedAttribute[$R] is export {
  method valid-range { $R }

  method range-max { $R.max }
  method range-min { $R.min }

  method handle-ranged-attribute-set (\v, Bool() :$clamp) {
    if v ~~ self.valid-range {
      self = v;
    } else {
      if $clamp {
        self = min(
          max(v, self.valid-range.min),
          self.valid-range.max
        )
      } else {
        $*ERR.say: X::GLib::Object::AttributeValueOutOfBounds.new(
          value     => v,
          range     => $R,
          attribute => self.name.substr(2)
        ).message;
      }
    }
  }
}

role OverridedAttribute[%O] is export {
}

multi sub trait_mod:<is> (Method:D \m, :a_property(:$a-property)! )
  is export
{
  m does PropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :g_property(:$g-property)! )
  is export
{
  m does PropertyMethod;
}

multi sub trait_mod:<is> (
  Method:D \m,
           :g_pseudo_property(:$g-pseudo-property)! )
  is export
{
  m does PropertyMethod;
  m does PseudoPropertyMethod;
}

multi sub trait_mod:<is> (
  Method:D \m,
           :a_pseudo_property(:$a-pseudo-property)! )
  is export
{
  m does PropertyMethod;
  m does PseudoPropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :an_attribute(:$an-attribute)! )
  is export
{
  m does AttributeMethod;
}

multi sub trait_mod:<is> (Method:D \m, :g_accessor(:$g-accessor)! )
  is export
{
  m does AccessorMethod;
}

multi sub trait_mod:<is> ( Method \m, :g_vfunc(:$g-vfunc)! ) is export {
  if $g-vfunc {
    m does GObjectVFunc[$g-vfunc];
  } else {
    m does GObjectVFunc;
  }
}

multi sub trait_mod:<is> (Attribute:D \a, :$ranged!) is export {
  a does RangedAttribute[$ranged];
}

multi sub trait_mod:<is> (
  Attribute:D \a,

  :g_object(:g-object(:$gobject))!
) is export {
  a does GObjectDerived;
}

multi sub trait_mod:<is> (
  Attribute:D \a,

  :g-override-property(:g_override_property(:$g-override)) is required
) is export {
  a does OverridedAttribute(:$g-override);
}

multi sub trait_mod:<is> (Attribute $a, :$gattribute!) is export {
  $a does GAttribute;
}

multi sub trait_mod:<is> (Attribute $a, :$gsignal!) is export {
  $a does GSignal;
}

multi sub trait_mod:<is> (Attribute $a, :$no-return!) is export {
  $a does NoReturn;
}

multi sub trait_mod:<is> (
  Attribute $a,

  :assigned_default_value(:$assigned-default-value)!
) {
  #cw: -XXX- Test to see if Attribute can accept $default-value!

  $a does GDefault[$assigned-default-value];
}

multi sub trait_mod:<is> ( Attribute $a, :default_value(:$default-value)! ) {
  #cw: -XXX- Test to see if Attribute can accept $default-value!

  trait_mod:<is>($a, assigned-default-value => $default-value);
}


# Thanks, guifa!
class X::StaticMethod::CalledWithInvocant is Exception {
  method message {
    "Attempting to call a static method with a defined invocant is not {
     '' }allowed!"
  }
}

multi sub trait_mod:<is> (Method:D \meth, Bool :$static!) is export {
  meth.wrap: anon method (|) {
    X::StaticMethod::CalledWithInvocant.throw if self.defined;
    callsame
  }
}

role TypeManifest  is export { }
role NotInManifest is export { }
