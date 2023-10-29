our $DEBUG            is export  = 0;

sub checkDEBUG ($d = 1) is export {
  $DEBUG >= $d;
}

INIT {

  if %*ENV<P6_GLIB_DEBUG> {
    print '»————————————> setting debug';
    if %*ENV<P6_GLIB_DEBUG>.Int -> \v {
      $DEBUG = v unless v ~~ Failure;
    }
    $DEBUG //= 1;

    say " ({ $DEBUG })";
  }

}
