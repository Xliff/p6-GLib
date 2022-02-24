use v6.c;

use Method::Also;

class GLib::Object::Supplyish {
  has $!supply;
  has %!signals;
  has $!signal;
  has %!taps;
  has @!tap-names;

  submethod BUILD (:$!supply, :$signals, :$!signal) {
    # %!tapped-signals, not %!signals -- !
    %!signals := $signals;
  }

  # cw: Act like a supply if an unknown method name is given.
  #     This is SLOW, though. Maybe find a better way?
  #     Maybe use delegation on $!supply?
  method FALLBACK ($name, |c) {
    if $!supply.^can($name) {
      $!supply."$name"(|c);
    }
  }

  method new ($supply, $signals, $signal) {
    self.bless( :$supply, :$signals, :$signal )
  }

  method !generateTapName {
    'tap:' ~ 'abcdefghijk'.comb.pick(6).join;
  }

  method is-tapped {
    %!signals{$!signal};
  }

  method tap (&handler, :$name is copy, :$replace = False) is also<connect> {
    # cw: If name is undefined, generate a random, unused one.
    unless $name {
      repeat {
        $name = self!generateTapName
      } until not %!taps{$name}:exists;
    }
    self.untap if %!signals{$!signal} && $replace;
    %!signals{$!signal} = True;
    @!tap-names.push: $name;

    # The CATCH block here means that user-supplied handlers no longer need
    # to specify it. Bonus: It is harmless to existing code that does.
    %!taps{$name} = $!supply.tap(-> *@a {
      CATCH { default { .message.say; .backtrace.concise.say } }

      &handler(|@a);
    });
  }

  method list {
    @!tap-names.List;
  }

  method untap (:$name is copy) is also<disconnect> {
    $name //= @!tap-names.tail;
    @!tap-names.pop;
    %!taps{$name}.close;
    %!taps{$name}:delete;
    %!signals{$!signal} = %!taps.elems.so;
  }
}
