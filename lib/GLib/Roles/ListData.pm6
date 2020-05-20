use v6.c;

use NativeCall;

use GLib::Raw::Types;

role GLib::Roles::ListData[::T] {
  also does Positional;
  also does Iterable;

  has @!nat; #handles
    #«iterator elems AT-POS EXISTS-POS join :p6sort('sort')»;

  method !rebuild {
    return unless self.dirty;

    my GList $l;

    @!nat = ();
    loop ($l = self.first; $l.defined; $l = $l.next) {
      @!nat.push: self.data($l);
    }
    self.cleaned;
    @!nat;
  }

  method DataType { T }

  method Array {
    self!rebuild;
    @!nat;
  }

  method List {
    self.Array.clone.List;
  }

  # Not sure about this, but just writing this out to solidify my thoughts.
  method iterator {
    self!rebuild;
    @!nat.iterator;
  }

  method elems {
    self!rebuild;
    @!nat.elems;
  }

  method AT-POS (|c) {
    self!rebuild;
    @!nat.AT-POS(|c);
  }

  method join (|c) {
    self!rebuild;
    @!nat.join(|c);
  }

  method EXISTS-POS (|c) {
    self!rebuild;
    @!nat.EXISTS-POS(|c);
  }

  method p6sort (|c) {
    self!rebuild;
    @!nat.sort(|c);
  }

  #method cur { ... }

  multi method data (GList $n) is rw {
    self!_data($n);
  }
  multi method data is rw {
    self!_data(self.cur);
  }

  method !_data(GList $n) is rw {
    Proxy.new:
      FETCH => sub ($) {
        my $deref = False;
        given T {
          when  uint64 | uint32 | uint16 | uint8 |
                 int64 |  int32 |  int16 |  int8 |
                 num64 |  num32
          {
            $deref = True; proceed
          }

          when .REPR eq 'CStruct' {
            $deref = True; proceed
          }

          when $deref.so {
            # Run time, or will this break then?
            nativecast(
              Pointer.^parameterize(T),
              $n.data
            ).deref
          }

          when .REPR eq 'CPointer' {
            nativecast(T, $n.data);
          }

          when Str {
            my $o = nativecast(Str, $n.data);
            say "Str: $o" if $DEBUG;
            $o;
          }

          default {
            die qq:to/DIE/.chomp;
              Unsupported type '{ .^name }' passed to{
              } GTK::Compat::List.new()
              DIE
          }
        }
      },
      STORE => -> $, T $nd {
        # This WILL need some work!

        # Int/Num -> CArray[T] -> Pointer[T] -> Pointer
        # Str -Pointer
        # CPointer/CStruct -> Pointer
        $n.data = $nd;
      };
  }

}
