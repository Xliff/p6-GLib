use v6.c;

use NativeCall;

role GLib::Roles::Pointers {

  method p {
    self ~~ Pointer ?? self !! nativecast(Pointer, self);
  }

}
