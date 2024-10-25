use v6.c;

class GLib::Raw::ReturnedValue is export {

  has $.val is rw;

  method r is rw { $!val }
}

# role GLib::Raw::ReturnedValue::Type[::T] {
#
#   method rv {
#     my T $rv = T(self.r);
#     $rv;
#   }
#
# }
