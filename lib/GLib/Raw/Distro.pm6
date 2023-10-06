use v6.c;

use GLib::Raw::Debug;

unit package GLib::Raw::Distro;

# Change listing to alpha by-key!
my %glib-adjustments = do {
  (
    linux => (
      Ubuntu => (
        DEFAULTS => (
          lib-append => '-2.0'
        ),

        bionic => my $ulatest = (
          version => v0
        ).Hash,

        # cosmic
        # disco
        # eoan
        # focal
        # hirsute
        # mantic

        latest => $ulatest
      ).Hash,

      Debian => (
        DEFAULTS => (
          lib-append => '-2.0'
        ),
        #
        # buster => my $dlatest = (
        #   version    => v19
        # ).Hash,
        #
        # latest => $dlatest
      ).Hash
    ).Hash
  ).Hash;
}

my %library-adjustments = (
  # cw: Adjustments are the same for both!
  glib    => %glib-adjustments,
  gobject => %glib-adjustments
).Hash;

sub add-distro-adjustments (%adj) is export {
  %library-adjustments.append: %adj;
}

sub library-adjustments is export {
  %library-adjustments.Map;
}

multi sub version-by-distro ($lib) is export {
  state %cache;

  unless %cache{$lib} {
    %cache{$lib} = do given $*DISTRO {
      when .is-win { samewith($lib, :windows) }

      default {
        do given $*KERNEL.name {
          when 'linux'  { samewith($lib, :linux) }
          when 'macosx' { samewith($lib, :osx)   }

          default {
            die "Do not know how to handle the { $_ } OS. Please contact {
                 '' }the project maintainer!";
          }
        }
      }
    }
  }
  %cache{$lib};
}

multi sub version-by-distro ($lib, :$osx is required) is export {
  do given $*KERNEL.name {
    when 'darwin' { }

    default {
    }
  }
}

multi sub version-by-distro ($lib, :$windows is required) is export {
  say 'NYI: Windows .DLL support for GLib';
  #exit 1;
  # NYI! This is probably going to need a Cygwin and an MSVC check!
}

sub glib-adjustments is export {
  %glib-adjustments.Map;
}

multi sub version-by-distro ($prefix is copy, :$linux is required) is export {
  state %cache;

  my $lr = qqx{which lsb_release}.chomp;
  say "PREFIX: $prefix\nLSB_RELEASE: $lr" if $DEBUG;
  my ($distro, $codename) =
    ( qqx{$lr -d -s}.split(/\s/)[0], qqx{$lr -c -s} )».chomp;

  say "DISTRO: $distro\nCODENAME: $codename" if $DEBUG;

  say 'LIBRARY SETTING: ' ~
      %library-adjustments{$prefix}<linux>.gist if $DEBUG;

  say 'DISTRO SETTING: ' ~
      %library-adjustments{$prefix}<linux>{$distro}.gist if $DEBUG;

  my ($lib, $lib-append, $version);

  # cw: $prefix becomes $*prefix, $distro becomes $*distro and
  #     $codename becomes $*codename!
  sub getDistroValue ($part) {
    my $value;

    given %library-adjustments {
      $value = .{$prefix}<linux><DEFAULTS>{$part}
        if .{$prefix}<linux><DEFAULTS>{$part};
      $value = .{$prefix}<linux>{$distro}<DEFAULTS>{$part}
        if .{$prefix}<linux>{$distro}<DEFAULTS>{$part};
      $value = .{$prefix}<linux>{$distro}{$codename}{$part}
        if .{$prefix}<linux>{$distro}{$codename}{$part};

      # cw: Only assign if no assignment
      $value = .{$prefix}<linux>{$distro}<latest>{$part}
        unless $value;
    }

    $value
  }

  $lib        = getDistroValue('lib');
  $lib-append = getDistroValue('lib-append');
  $version    = getDistroValue('version');

  ($lib // $prefix) ~ ($lib-append // ''), ($version // v0);
}

sub resources-info is export {
  my $ext = 'dll';
  my $os = $*DISTRO.is-win ?? 'windows' !! 'unix';
  if $os eq 'unix' {
    # Which one?
    $os = $*KERNEL.name;
    $ext = 'so';
  }
  my $arch = '/.dockerenv'.IO.e ?? qqx{uname -m}.chomp !! $*KERNEL.arch;

  ($arch, $os, $ext);
}

sub glib-support is export {
  state $libname = do {
    my ($arch, $os, $ext) = resources-info;
    my $libkey = "lib/{ $arch }/{ $os }/glib-support.{ $ext }";
    say "Using '$libkey' as support library." if $DEBUG;
    $libname = %?RESOURCES{$libkey}.absolute;
  }

  $libname;
}

sub tree-helper is export {
  state $libname = do {
    my ($arch, $os, $ext) = resources-info;
    my $libkey = "lib/{ $arch }/{ $os }/tree-helper.{ $ext }";
    say "Using '$libkey' as tree support library." if $DEBUG;
    $libname = %?RESOURCES{$libkey};
  }

  $libname;
}
