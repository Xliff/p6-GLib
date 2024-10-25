use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;

role GLib::Roles::TypedBuffer[::T] does Positional {
  has         $!size;
  has Pointer $!b;

  # What if not all malloc'd at once?
  submethod BUILD (:$buffer, :$size, :$autosize = True, :$clear) {
    if $buffer.defined {
      # *********************************************
      # Please note this is NOT portable! Please see:
      # https://stackoverflow.com/questions/1281686/determine-size-of-dynamically-allocated-memory-in-c
      # *********************************************
      #$!size = malloc_usable_size($!b = $buffer) div nativesizeof(T);
      $!b = $buffer;
      $!size = $autosize ?? malloc_usable_size($!b) div nativesizeof(T)
                         !! $size;
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
  method AT-POS (Int $field) {
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
  }

  method elems {
    $!size;
  }

  proto method new (|)
  { * }

  # cw: These to be dropped for .new-typedbuffer-obj
  multi method new (Pointer $buffer, :$autosize = True, :$clear = False) {
    self.new-typedbuffer-obj($buffer, :$autosize, :$clear);
  }
  multi method new (@entries) {
    self.new-typedbuffer-obj(@entries);
  }

  method new-sized (Pointer $buffer, $size) {
    return Nil unless $buffer;
    self.bless( :$buffer, :$size, :!autosize );
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

sub bufferReturnTypedArray(
  $b,
  \T,
  $O?,
  :$size   = 0,
  :$buffer = False,
  :$raw    = False
)
  is export
{
  my $ta = $size ?? GLib::Roles::TypedBuffer[T].new-sized($b, $size)
                 !! GLib::Roles::TypedBuffer.new-typedbuffer-obj($b);
  return $ta if $buffer;

  [||]( $raw, $O === Any, $O =:= Mu )
    ?? $ta.Array
    !! $ta.Array.map({ $O.new($_) });
}
