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
