use v6.c;

use NativeCall;

use GLib::Raw::Types;

sub HandleType (\type) {
  my $act;
  my \tp = do given type {
    when .repr eq 'CStruct'  { $act = 'cast'; Pointer[type]     }
    when Str                 { $act = 'aset'; CArray[type]      }
    when int8  | uint8       { $act = 'aset'; CArray[type]      }
    when int16 | uint16      { $act = 'aset'; CArray[type]      }
    when int32 | uint32      { $act = 'aset'; CArray[type]      }
    when int64 | uint64      { $act = 'aset'; CArray[type]      }
    when num32 | num64       { $act = 'aset'; CArray[type]      }
    when Int                 { $act = 'aset'; CArray[uint64] }
    when Num                 { $act = 'aset'; CArray[num64]  }
    when .repr eq 'CPointer' { $act = 'set';  type }

    default {
      die "GLib::ListData does not know how to handle key-type { type.^name }";
    }
  }
  ($act, tp);
}

role GLib::ListData[::K, ::V] {
  has %!keyCache;

  also does Associative[K, V];

  method AT-KEY(K $key) {
    return %!keyCache{$key} if %!keyCache{$key}:exists;

    my ($kact, \kt) = HandleType(K);
    my ($vact, \vt) = HandleType(V);

    # cw: $act values are holdovers from key-handling. I'm ambivalent about 'em.
    my $ka;
    given $kact {
      # cw: Removed due to compiler error - 3/20/22
      # when 'cast' { $ka = kt.new; $ka = cast(Pointer[K], $key) }
      when 'aset' { $ka = kt.new; $ka[0] = $key                }
      when 'set'  { $ka = $key                                 }
    }

    my $l = do given $vact {
      when 'cast' { -> $lv {   cast(vt, $lv)      } }
      when 'aset' { -> $lv { ( cast(vt, $lv) )[0] } }
      when 'set'  { -> $lv {   $lv                } }
    };

    %!keyCache{$key} =
      Proxy.new:
        FETCH => sub ($) {
          $l( self.lookup($ka) );
        },
        STORE => -> $, V $val {
          state $n = 0;

          if $val.defined {
            my $v = do given $vact {
              # cw: Removed due to compiler error - 3/20/22
              #when 'cast' { cast(Pointer[V], $val)        }
              when 'aset' { $v = vt.new; $v[0] = $val; $v }
              when 'set'  { $val }
            }

            $n++ ?? self.insert($ka, $v) !!
                    self.replace($ka, $v)
          } else {
            self.remove($ka);
            $n = 0;
          }
        };
  }

  method EXISTS-KEY (K $key) {
    my ($kact, \kt) = HandleType(K);

    my $ka;
    given $kact {
      # cw: Removed due to compiler error - 3/20/2022
      # when 'cast' {
      #   $ka = kt.new;
      #   $ka = cast(Pointer[K], $key)
      # }
      when 'aset' { $ka = kt.new; $ka[0] = $key                }
      when 'set'  { $ka = $key                                 }
    }
    self.lookup($ka).defined;
  }

}
