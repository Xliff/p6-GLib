use v6.c;

use GLib::Raw::Exceptions;

unit package GLib::Raw::Traits;

role PropertyMethod  is export { }
role AttributeMethod is export { }

role Signalling[@Signals] {

  method defined-signals {
    @Signals;
  }

}

role RangedAttribute[$R] is export {
  method valid-range { $R }

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

multi sub trait_mod:<is> (Method:D \m, :$a-property!) is export {
  m does PropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :$g-property!) is export {
  m does PropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :$an-attribute!) is export {
  m does AttributeMethod;
}

multi sub trait_mod:<is> (Attribute:D \a, :$ranged!) is export {
  a does RangedAttribute[$ranged];
}

multi sub trait_mod:<is> (
  Attribute:D \a,
              :g-override-property(:$g-override) is required
) is export {
  a does OverridedAttribute(:$g-override);
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
