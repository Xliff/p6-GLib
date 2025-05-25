use v6.c;

role GLib::Roles::HashObject {

  method FALLBACK ($n is copy) is rw {
    return self{$n} if self{$n}:exists;

    $n .= subst: / <after <:Ll>> (<:Lu>|<:digit>+) /, {'-' ~ $0.lc}, :g;
    return self{$n} if self{$n}:exists;

    $n .= subst( / '-' /, '_', :g );
    return self{$n} if self{$n}:exists;

    Nil
  }

}
