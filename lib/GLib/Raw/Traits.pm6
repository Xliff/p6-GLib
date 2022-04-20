use v6.c;

unit package GLib::Raw::Traits;

role PropertyMethod  is export { }
role AttributeMethod is export { }

multi sub trait_mod:<is> (Method:D \m, :$a-property!) is export {
  m does PropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :$g-property!) is export {
  m does PropertyMethod;
}

multi sub trait_mod:<is> (Method:D \m, :$an-attribute!) is export {
  m does AttributeMethod;
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
