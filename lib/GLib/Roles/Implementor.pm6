use v6.c;

# This is required for proper compilation.

our role Implementor is export {}

multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) is export {
  attr does Implementor;
}
