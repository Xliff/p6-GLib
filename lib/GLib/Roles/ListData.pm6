use v6.c;

use NativeCall;

use GLib::Raw::Types;

role GLib::Roles::ListData[::T, :$direct] {
  also does Positional;
  also does Iterable;

  has @!nat; #handles
    #«iterator elems AT-POS EXISTS-POS join :p6sort('sort')»;

  method !rebuild {
    say '-- !rebuild start';
    return unless self.dirty;

    my $l;

    @!nat = ();
    say '-- loop start';
    loop ($l = self.first; $l.defined; $l = $l.next) {
      say "L: { $l }";
      use nqp;

      # Must insure that results from C are properly prepared for the
      # High Level Language
      my $s = self.data($l);
      $s = nqp::unbox_s($s) if T ~~ Str;

      @!nat.push: $s;
    }
    say '-- loop end';
    self.cleaned;

    say '-- rebuild end';
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

  multi method data ($n) is rw {
    self!_data($n);
  }
  multi method data is rw {
    self!_data(self.cur);
  }


  method !_data($n) is rw {
    Proxy.new:
      FETCH => sub ($) {
        return "<< NULL { T.^name } VALUE!>>" unless $n.data;
        my $deref = False;
        given T {
          when  uint64 | uint32 | uint16 | uint8 |
                 int64 |  int32 |  int16 |  int8 |
                 num64 |  num32
          {
            if $direct {
              +$n.data;
            } else {
              $deref = True;
              proceed
            }
          }

          when .REPR eq 'CStruct' {
            $deref = True; proceed
          }

          when $deref.so {
            nativecast(
              Pointer.^parameterize(T),
              $n.data
            ).deref
          }

          when .REPR eq 'CPointer' {
            nativecast(T, $n.data);
          }

          when Str {
            # my $o = nativecast(CArray[uint8], $n.data);
            # my $c = 0;
            # my @a;
            # while $o[$c] {
            #   say "{ $c }: { $o[$c].chr }";
            #   @a.push: $o[$c++];
            # }
            # Buf.new(@a).decode;
            nativecast(str, $n.data);
          }

          default {
            die qq:to/DIE/.chomp;
              Unsupported type '{ .^name }' passed to{
              } GLib::List.new()
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
