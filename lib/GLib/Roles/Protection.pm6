use v6.c;

# Thanks, gfldex. This was an inspiration:
# https://gfldex.wordpress.com/2023/08/06/parenthood/

use GLib::Raw::Exceptions;

my %children;

role GLib::Roles::Protection {

  method add_descendant (Mu $obj, Mu $child) {
     %children{ self.^name }.push: $child.^name;
   }

   method descendants (Mu $obj) {
       %children{ self.^name }.List
   }

}

class MetamodelX::ProtectedHOW is Metamodel::ClassHOW {
    also does GLib::Roles::Protection;

    method add_parent (Mu $obj, Mu $parent, :$hides) {
        $parent.^add_child($obj) if $parent.HOW ~~ ::?CLASS;

        callsame
    }
}

sub trait_mod:<is> (Method \r, :$protected is required) {

  if r.package.HOW ~~ MetamodelX::ProtectedHOW {
    r.^wrap({
      my \E   = X::GLib::MethodIsProtected.new;
      my \slf = callframe(0).code;
      my \n   = slf.package.^name;

      E.throw if slf.package === GLOBAL;

      # cw: Still ain't right. Almost there.
      E.throw unless r.package.^name eq (
        |slf.package.^mro.map(   *.name ),
        |slf.package.^roles.map( *.name )
      ).any;

      nextsame;
    });
  }

}

sub EXPORT ($declarator-name = 'protected-class') {
    use MONKEY-SEE-NO-EVAL;
    OUR::EXPORTHOW::DECLARE := EVAL q:s:to /EOH/;
      package DECLARE {
          constant $declarator-name = MetamodelX::ProtectedHOW;
      }
      EOH

    Map.new
}
