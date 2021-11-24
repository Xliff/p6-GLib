use v6.c;

# This is required for proper compilation.

our role Implementor is export {}

multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) is export {
  attr does Implementor;
}

our role GLib::Roles::Implementor {

  method getTypePair {
    my \ft = self.getImplementor.type;

    (
      ft.HOW ~~ Metamodel::CoercionHOW ?? ft.^target_type !! ft,
      self.WHAT
    )
  }

}
