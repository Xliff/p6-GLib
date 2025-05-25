use v6.c;

use experimental :macros;
use experimental :rakuast;

unit package GLib::Raw::Macros;

# cw: For future functionality...
#
# macro TYPE-RESOLVER (\T, $f) is export {
#   quasi {
#     BEGIN {
#       use JSON::Fast;
#
#       my %widgets;
#       my \O = {{{ T }}};
#       my \P = O.getTypePair;
#       given {{{ $f }}}.IO.open( :rw ) {
#         .lock;
#         my $existing = .slurp;
#         %widgets = try from-json($existing) if $existing.chars;
#         %widgets{ P.head.^shortname } = P.tail.^name;
#         .seek(0, SeekFromBeginning);
#         .spurt: to-json(%widgets);
#         .close;
#       }
#     }
#
#     INIT {
#       my \O = {{{ T }}};
#       %widget-types{O.get_type} = {
#         name        => O.^name,
#         object      => O,
#         pair        => O.getTypePair
#       }
#     }
#   }
# }

macro NEED-STATEMENTS (\sym) is export {
  my @e = sym.pairs.grep( *.key.ends-with("exports") );

  for @e {
    quasi { need {{{ $_ }}}; }
  }

  quasi {
    BEGIN {{
  }

  quasi { glib-re-export($_) for }

  for @e {
    for .key {
      |{{{ $_ }}}
    }
  }

  quasi {
    }}
  }

}

sub GENERATE-NEED-STATEMENTS (\sym) is export {
  my @e = sym.pairs.grep( *.key.ends-with("exports") );

  RakuAST::StatementList.new(
    |(
      (
        do for @e {
          do for .value {
            RakuAST::Statement::Need.new(
              module-names => [
                RakuAST::Name.from-identifier($_)
              ]
            )
          }
        }
      ).flat
    ),
    RakuAST::Statement::Expression.new(
      expression => RakuAST::StatementPrefix::Phaser::Begin.new(
        RakuAST::Block.new(
          body => RakuAST::Blockoid.new(
            RakuAST::StatementList.new(
              RakuAST::Statement::Expression.new(
                expression => RakuAST::Call::Name.new(
                  name => RakuAST::Name.from-identifier('glib-re-export'),
                  args => RakuAST::ArgList.new(
                    RakuAST::Var::Lexical.new('$_')
                  )
                ),
                loop-modifier => RakuAST::StatementModifier::For.new(
                  RakuAST::ApplyListInfix.new(
                    infix    => RakuAST::Infix.new(","),
                    operands => |(
                      (
                        do for @e {
                          do for .key {
                            RakuAST::ApplyPrefix.new(
                              prefix  => RakuAST::Prefix.new("|"),
                              operand => RakuAST::Var::Lexical.new($_)
                            )
                          }
                        }
                      ).flat
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  );
}
