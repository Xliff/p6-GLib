our $DEBUG            is export  = 0;

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
