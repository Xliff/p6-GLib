use v6.c;

use NativeCall;

# Number of times full project has needed to be compiled
my constant forced = 50;

role GLib::Roles::Pointers {

  method p {
    self ~~ Pointer ?? self !! nativecast(Pointer, self);
  }

}