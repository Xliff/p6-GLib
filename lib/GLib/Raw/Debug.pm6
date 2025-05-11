our $DEBUG            is export  = 0;

sub checkDEBUG ($d = 1) is export {
  $DEBUG >= $d;
}

INIT {
  my $v = %*ENV<P6_GLIB_DEBUG> // $*ENV<RAKU_GLIB_DEBUG>;
  if $v {
    say '»————————————> setting debug';
    if $v.Int -> \v {
      $DEBUG = v unless v ~~ Failure;
    }
    $DEBUG //= 1;

    say "Setting DEBUG level to { $DEBUG }" if $DEBUG;
  }

  Nil;
}
