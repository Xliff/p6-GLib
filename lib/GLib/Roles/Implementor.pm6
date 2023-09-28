use v6.c;

# This is required for proper compilation.

our role Implementor is export {}
our role Boxed       is export {}

multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) {
  attr does Implementor;
}

# Find.
our sub findProperImplementor ( $attrs, :rev(:$reverse) ) is export {
  # Will need to search the entire attributes list for the
  # proper main variable. Then sort for the one with the largest
  # MRO.
  my @attributes   = $attrs.cache;
  my @implementors = @attributes.grep( * ~~ Implementor )
                                .sort( -*.package.^mro.elems );
  @implementors .= reverse if $reverse;

  my ($idx, $attr) = (0);

  if +@implementors {
    unless $attr === (Any, Nil).any {
      repeat {
        $attr = @implementors[$idx++];

        my $type = $attr.type;
        return $type unless $type === (Any, Nil).any;
      } until $idx > +@implementors;
    }
  }

  $idx = 0;
  repeat {
    $attr = @attributes[$idx++];

    #print  " FPI: { $attr.type.^name } / { $attr.name } ";
  } until $attr.type.^name ne 'Mu';
  $attr;
}

our role GLib::Roles::Implementor {

  method getImplementor {
    findProperImplementor(self.^attributes);
  }

  method getImplementorValue {
    self.getProperImplementor.get_value(self);
  }

  method getTypePair {
    my \ft = self.getImplementor.type;

    (
      ft.HOW ~~ Metamodel::CoercionHOW ?? ft.^target_type !! ft,
      self.WHAT
    )
  }

}
