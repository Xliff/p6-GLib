use v6.c;

use Method::Also;

class GLib::Object::Supplyish {
  has $!supply;
  has %!signals;
  has $.signal;
  has %!taps;
  has @!tap-names;
  has $.enabled    is rw;

  submethod BUILD (:$!supply, :$signals, :$!signal) {
    # %!tapped-signals, not %!signals -- !
    %!signals := $signals;
    $!enabled  = True;
  }

  # cw: Act like a supply if an unknown method name is given.
  #     This is SLOW, though. Maybe find a better way?
  #     Maybe use delegation on $!supply?
  #
  #     Delegation should do everything but .tap
  method FALLBACK ($name, |c) {
    do if $!supply.^can($name) {
      $!supply."$name"(|c);
      self;
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
    %!taps{$name} = $!supply.tap( sub (*@a) {
      return unless $!enabled;

      # cw: TODO - filter out wrapper from exception frames.
      CONTROL {
        when CX::Warn {
          .message.say;
          .backtrace.concise.say;
          .resume
        }

        default {
          .rethrow
        }
      }

      CATCH {
        default {
          .message.say;
          .backtrace.concise.say;
        }
      }

      my $retVal = &handler( |@a );
      # my $r = @a.tail;
      # if $r ~~ ReturnValue && $r.r.defined.not && $retVal.defined {
      #   $r.r = $retVal;
      # }
    });
    $name;
  }

  method list {
    @!tap-names.List;
  }

  proto method untap (|)
    is also<disconnect>
  { * }

  multi method untap ( :$all is required ) {
    $.untap( name => $_ ) for $.list;
  }
  multi method untap (:$name is copy) {
    $name //= @!tap-names.tail;
    @!tap-names.pop;
    %!taps{$name}.close;
    %!taps{$name}:delete;
    %!signals{$!signal} = %!taps.elems.so;
  }
}

sub create-signal-supply ($s, $t, $signal) is export {
  GLib::Object::Supplyish.new($s.Supply, $t, $signal);
}
