use v6.c;

use NativeCall;

# Number of times full project has needed to be compiled
my constant forced = 98;

our role Implementor is export {};

# Mark
multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) is export {
  # YYY - Warning if a second attribute is marked?
  attr does Implementor;
}

# Find.
sub findProperImplementor ( $attrs, :rev(:$reverse) ) is export {
  # Will need to search the entire attributes list for the
  # proper main variable. Then sort for the one with the largest
  # MRO.
  my @implementors = $attrs.grep( * ~~ Implementor )
                           .sort( -*.package.^mro.elems );
  @implementors .= reverse if $reverse;
  @implementors[0];
}


role GLib::Roles::Pointers {

  method p {
    if self.REPR eq <CStruct CPointer>.any {
      self ~~ Pointer ?? self !! nativecast(Pointer, self);
    } elsif findProperImplementor(self.^attributes) -> \i {
      nativecast( Pointer, i.get_value(self) )
    } else {
      self ~~ Pointer ?? self !! nativecast(Pointer, self);
    }
  }

}