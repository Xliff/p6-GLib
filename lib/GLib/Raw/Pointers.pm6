use v6.c;

use NativeCall;

unit package GLib::Raw::Pointers;

sub p ($p) is export {
  cast(Pointer, $p);
}
