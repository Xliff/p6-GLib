use v6.c;

use Method::Also;

use GLib::Raw::Signal;

class GLib::Object::Supplyish {
  has $!supply;
  has %!signals;
  has $.signal;
  has %!taps;
  has @!tap-names;
  has $.enabled    is rw;

  role Untappable[$supplyish] {

    # cw: If this is used with :$clear, you will be converting
    #     it's punned object back to a regular Str.
    method untap ( :$clear = False ) {
      $supplyish.untap( name => self, :$clear );
    }

    method clear {
      self.untap( :clear )
    }

    method enable {
      $supplyish.enabled = True;
    }

    method disable {
      $supplyish.enabled = False;
    }

    method block_signal_handler {
      self.disable;
    }
    method block-signal-handler {
      self.block_signal_handler;
    }

    method unblock_signal_handler {
      self.enable;
    }
    method unblock-signal-handler {
      self.unblock_signal_handler;
    }

  }

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
      $!supply."$name"( |c );
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

      #say "Arguments: { @a».gist.join(', ') }" if checkDEBUG(2);

      my $retVal = &handler( |@a );
      # my $r = @a.tail;
      # if $r ~~ ReturnValue && $r.r.defined.not && $retVal.defined {
      #   $r.r = $retVal;
      # }
    });
    $name but Untappable[self];
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
  multi method untap ($name is rw, :$clear = False) {
    samewith( name => $name );
    $name = Nil if $clear;
  }
  multi method untap ( :$name ) {
    my $n = $name // @!tap-names.tail;

    @!tap-names.pop;
    %!taps{$n}.close;
    %!taps{$n}:delete;
    %!signals{$!signal} = %!taps.elems.so;
    # cw: Remember to disconnect the actual GLib signal
    g_signal_handler_disconnect( |%!signals{$!signal}.skip(1) )
  }
}

sub create-signal-supply ($s, $t, $signal) is export {
  GLib::Object::Supplyish.new($s.Supply, $t, $signal);
}
