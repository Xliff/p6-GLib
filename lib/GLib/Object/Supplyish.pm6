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
    # Wrap handler?
    # &handler.wrap(-> |c {
    #   CATCH { default { .message.say; .backtrace.concise.say } }
    #   nextsame;
    # });
    self.untap if %!signals{$!signal} && $replace;
    %!signals{$!signal} = True;
    @!tap-names.push: $name;
    %!taps{$name} = $!supply.tap(&handler);
  }

  method list {
    @!tap-names.List;
  }

  method untap (:$name is copy) is also<disconnect> {
    $name //= @!tap-names.tail;
    %!taps{$name}.close;
    %!taps{$name}:delete;
    %!signals{$!signal} = %!taps.elems.so;
  }
}
