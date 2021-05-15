use v6.c;

use NativeCall;

role GLib::Roles::TypedQueue[::T, $raw, ::O = Mu, :$ref = True] {

  method Array {
    my @a;

    die 'Cannot be unraw with unspecified object type!'
      if $raw.not && O =:= Mu;

    self.foreach(-> $d is copy, $ud {
      my $non-object = False;

      $d = nativecast(T, $d) unless T ~~ Int;
      given T {
        when Int       { $d = +$d; proceed  }
        when Int | Str { $non-object = True }

        when Pointer {
          if T.of ~~ (Num, Int).any {
            $d = $d[0];
            $non-object = True;
          } else {
            $d = T.of.REPR eq 'CStruct' ?? $d[0].deref !! $d[0];
          }
        }
      }

      unless $non-object {
        if O !=:= Mu {
          $d = O.new( $d, :$ref ) unless $raw;
        }
      }

      @a.push: $d;
    } );

    @a;
  }

  method foreach (|) { ... }

}
