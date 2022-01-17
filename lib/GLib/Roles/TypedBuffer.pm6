use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Subs;

role GLib::Roles::TypedBuffer[::T] does Positional {
  has $!size;
  has Pointer $!b;

  # What if not all malloc'd at once?
  submethod BUILD (
    :$buffer,
    :$null-terminated,
    :$size,
    :$autosize         is copy = True,
    :$clear
  ) {
    $autosize = False if $null-terminated;

    if $buffer.defined {
      # *********************************************
      # Please note this is NOT portable! Please see:
      # https://stackoverflow.com/questions/1281686/determine-size-of-dynamically-allocated-memory-in-c
      # *********************************************
      #$!size = malloc_usable_size($!b = $buffer) div nativesizeof(T);
      $!b = $buffer;

      # $autosize is not portable, and should be subject to SERIOUS checks before
      # its use. The correct thing to here is use $null-terminated!
      $!size = do {
        when $autosize.so        { malloc_usable_size($!b) div nativesizeof(T) }

        when $null-terminated.so {
          my $c = 0;

          # cw: --DANGER-- This loop has the potential to run endlessly!
          loop {
            given T {
              when .REPR eq 'CStruct' {
                my $e  = self[$c++];

                $e .= deref if T.of         ~~ Pointer              &&
                               T.of.of.REPR eq <CStruct CUnion>.any;
                last if $e.^attributes[0].get_value($e).not;
              }

              default { last if self[$c++].not }
            }
          }
        }
      };

      # cw: Zero out existing buffer
      if $clear {
        loop (my $i = 0; $i < $!size; $i++) {
          self.bind($i, T.new);
        }
      }

    } else {
      die 'Must pass in $size' unless $size.defined;

      my uint64 $s1 = $!size = $size;

      $!b = calloc( $s1, nativesizeof(T) )
    }
  }

  method bufferSize {
    malloc_usable_size($!b);
  }

  submethod DESTROY {
    # Free individual elements, as well!
    #if $!size.defined {
    #  free(self[$_]) for ^$!size;
    #}
    #free( $!b // nativecast(Pointer, self) );
  }

  method NativeCall::Types::Pointer
  { $!b }

  method p (:$typed = True)
    is also<Pointer>
  {
    $typed ?? nativecast(Pointer.^parameterize(T), $!b) !! $!b;
  }

  # Cribbed from MySQL::Native. Thanks, ctilmes!
  method AT-POS(Int $field) {
    nativecast(
      T,
      Pointer.new( $!b + $field * nativesizeof(T) )
    )
  }

  method Array {
    die 'Must set size of buffer via .setSize!' unless $!size;

    # There may be a temptation to usse CArrayToArray, here. Resist it.
    my @a;
    @a[$_] = self[$_] for ^$!size;
    @a;
  }

  # For use on externally retrieved data.
  method setSize(Int() $s, :force(:$forced) = False) {
    if $!size.defined && $forced.not {
      warn 'Cannot reset size!'
    } else {
      $!size = $s;
    }
  }

  # cw: XXX - Yes, but what happens with the return value?
  #           Ideally what should happen is that we allocate a whole block
  #           of memory to cover the entire buffer and then bind to
  #           individual structs inside. Is that happening here?
  #
  #           In many cases when passed a buffer, this should do NOTHING!
  method bind (Int() $pos, T $elem) {
    my uint64 $p = $pos;

    memcpy(
      Pointer.new( $!b + $p * nativesizeof(T) ),
      nativecast(Pointer, $elem),
      nativesizeof(T)
    );
    $elem;
  }

  method elems {
    $!size;
  }

  # cw: These to be dropped for .new-typedbuffer-obj
  multi method new (Pointer $buffer, :$null-terminated is required) {
    return Nil unless $buffer;

    self.bless( :$buffer, :$null-terminated );
  }
  multi method new (
    Pointer $buffer,
            :$null-terminated where *.not,
            :$autosize                     = True,
            :$clear                        = False
  ) {
    self.new-typedbuffer-obj($buffer, :$autosize, :$clear);
  }
  multi method new (@entries) {
    self.new-typedbuffer-obj(@entries);
  }

  multi method new-typedbuffer-obj (
    $s,
    :$clear        =  True,
    :sized(:$size) is required
  ) {
    self.bless( size => $s, :$clear );
  }
  multi method new-typedbuffer-obj (
    Pointer $buffer,
    :$autosize = True,
    :$clear    = False
  ) {
    $buffer ?? self.bless( :$buffer, :$autosize, :$clear ) !! Nil;
  }
  multi method new-typedbuffer-obj (@entries) {
    return (Pointer but GLib::Roles::Pointers) unless @entries;

    die "TypedBuffer type must be a CStruct, not a { T.REPR } via { T.^name }"
      unless T.REPR eq 'CStruct';

    @entries = @entries.map({
      if $_ !~~ T {
        if .^lookup(T.^shortname) -> $m {
          $_ = $m($_);
        }
      }

      die qq:to/D/.chomp unless $_ ~~ T;
        { ::?CLASS.^name } can only be initialized if all entries are a {
          T.^name }, not a { .^name }
        D

      $_;
    });

    my $o = self.bless( size => @entries.elems );
    for ^@entries.elems {
      $o.bind( $_, @entries[$_] );
    }

    $o;
  }

}
