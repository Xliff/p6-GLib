use v6.c;

use GLib::Raw::Types;

use GLib::Value;

use GLib::Roles::Implementor;
use GLib::Roles::Object;

role GLib::Roles::Value {

  method GValue {
    my $v;
    if self ~~ GLib::Roles::Object {
      return gv_obj(self.GObject);
    } elsif self.REPR eq 'CStruct'  {
      return gv_ptr(
        cast( gpointer, findProperImplementor(self.^attributes) )
      );
    } elsif self.REPR eq 'CPointer' {
      return gv_ptr( findProperImplementor(self.^attributes) )
    } else {
      my $t;
      if self ~~ Cool {
        given self.^name {
          when Str { return gv_str(self) }

          # cw: This needs a little more thought. Like: when do you
          #     employ the dynamics?!
          when Int {
            if $*signed {
              return $*double ?? gv_int64(self)  !! gv_int(self)
            } else {
              return $*double ?? gv_uint64(self) !! gv_uint(self)
            }
          }

          # cw: This needs a little more thought. Like: when do you
          #     employ the dynamics?!
          when Rat | Num {
            return $*double ?? gv_dbl(self) !! gv_flt(self)
          }

          when Bool { return gv_bool(self) }
        }
      }
    }

    X::GLib::UnknownType.new(
      message => "GValue conversion does not know how to handle a type {
                  '' }of { self.^name }"
    ).throw;
  }

}
