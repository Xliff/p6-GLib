use v6.c;

use NativeCall;

use CompUnit::Util :re-export;

need GLib::Roles::Implementor;
import GLib::Roles::Implementor;

BEGIN re-export-everything('GLib::Roles::Implementor');

# Number of times full project has needed to be compiled
my constant forced = 340;

# Mark
multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) is export {
  # YYY - Warning if a second attribute is marked?
  attr does Implementor;
}

multi sub trait_mod:<is>(Attribute:D \attr, :$boxed!) is export {
  # YYY - Warning if a second attribute is marked?
  attr does Implementor;
  attr does Boxed;
}

constant GRI = GLib::Roles::Implementor;

role GLib::Roles::Pointers {

  method p {
    if self.REPR eq <CStruct CPointer>.any {
      self ~~ Pointer ?? self !! nativecast(Pointer, self);
    } elsif GRI::findProperImplementor(self.^attributes) -> \i {
      nativecast( Pointer, i.get_value(self) )
    } else {
      self ~~ Pointer ?? self !! nativecast(Pointer, self);
    }
  }

  method Numeric {
    +self.p;
  }

}