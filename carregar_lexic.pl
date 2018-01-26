#!/usr/bin/perl


# En aquest programa es llegeix el fitxer amb 4 columnes separades per tabuladors amb paraules amb categories tancades
# 0. ocurrències
# 1. paraula catalana
# 2. categoria gramatical catalana
# 3. paraula francesa
# 4. categoria gramatical francesa
# 6. autor
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari

use strict;
use utf8;

my $MOT = 'crever les yeux';	# paraula a debugar
my $MOT = 'desenterrar';	# paraula a debugar
my $MOT = 'convertir';	# paraula a debugar
my $MOT = 'rus';	# paraula a debugar
my $MOT = 'fusil';	# paraula a debugar
my $MOT = 'UICN';	# paraula a debugar
my $MOT = 'musique';	# paraula a debugar
my $MOT = 'musique de chambre';	# paraula a debugar
#my $MOT = 'nombre primer';	# paraula a debugar
my $MOT = 'comarca';	# paraula a debugar
my $MOT = '';

my $MORF_TRACT = 'adj';
my $MORF_TRACT = 'n';
#my $MORF_TRACT = '';

my ($ffra, $fbi, $fdixfra, $fdixcat, $fdixbi, $fdixfran, $fdixfraadj);

open($fdixfra, "../apertium-fra/apertium-fra.fra.metadix") || die "can't open apertium-fra.fra.metadix: $!";
open($fdixfran, "../apertium-fra/joanortola/fra-noun.txt") || die "can't open fra-noun.txt: $!";
open($fdixfraadj, "../apertium-fra/joanortola/fra-adj.txt") || die "can't open fra-adj.txt: $!";
open($fdixcat, "../apertium-cat/apertium-cat.cat.dix") || die "can't open apertium-cat.cat.dix: $!";
open($fdixbi, "apertium-fra-cat.fra-cat.dix") || die "can't open apertium-fra-cat.fra-cat.dix: $!";

open($ffra, ">f_fra.dix.txt") || die "can't open f_fra.dix: $!";
open($fbi, ">f_bi.dix.txt") || die "can't open f_bi.dix: $!";

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixfra, ":encoding(UTF-8)");
binmode($fdixfran, ":encoding(UTF-8)");
binmode($fdixfraadj, ":encoding(UTF-8)");
binmode($fdixcat, ":encoding(UTF-8)");
binmode($fdixbi, ":encoding(UTF-8)");
binmode($ffra, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

my %dix_fra = ();
my %dix_fra_prm = ();
my %dix_cat = ();
my %dix_fran = ();
my %dix_fran_def = ();
my %dix_fraadj = ();
my %dix_fraadj_def = ();
my %dix_fra_cat = ();
my %dix_cat_fra = ();


# llegeixo el fitxer fra: n, adj, adv, abbr
sub llegir_dix_ortola {
	my ($nfitx, $fitx, $r_struct, $r_struct2) = @_;
	my ($lemma, $par, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;

print "1. fitxer ortola $nfitx, $linia\n" if $MOT && $linia =~ /$MOT/o;
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} else {
print STDERR "Error en llegir_dix_ortola fitxer $nfitx, $linia\n";
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer ortola $nfitx, $linia, par=$par";
		}
print "2. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'abbr') {
			print STDERR "llegir_dix_ortola fitxer $nfitx, línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;

		$r_struct->{$morf}{$lemma} = $par;
		$r_struct2->{$morf}{$lemma} = $linia;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
print "4. fitxer ortola $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n";
}

# llegeixo el fitxer fra: n, adj, adv, abbr
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct, $r_struct_prm) = @_;
	my ($lemma, $par, $prm, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;
		next if $linia =~ /r="LR"/o;
		next if $linia =~ /<!-- .*<e/o;

next if $linia !~ /$MORF_TRACT/o;

#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
#     <e lm="emprunt" a="joan"><i>emprunt</i><par n="livre__n"/></e>

print "1. fitxer $nfitx, $linia\n" if $MOT && $linia =~ /$MOT/o;
		$prm = '';
		if ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)" prm="(.)"/></e>|o) {
					$lemma = $1;
			$par = $2;
			$prm = $3;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)">[^<]*<par n="(.*)"/></e>|o) {
#<e lm="ampli">           <par n="/ampli__adj"/></e>
			$lemma = $1;
			$par = $2;
		} else {
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer $nfitx, $linia, par=$par";
		}
print "2. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
next if $morf ne $MORF_TRACT;

		if ($r_struct->{$morf}{$lemma} && $morf ne 'vblex') {
			print STDERR "Error llegir_dix $nfitx: lemma $lemma (morf = $morf, par = $par) ja definit com a morf = $morf, par = $r_struct->{$morf}{$lemma}\n"
				if $r_struct->{$morf}{$lemma} ne $par;
		} else {
			$r_struct->{$morf}{$lemma} = $par;
			$r_struct_prm->{$morf}{$lemma} = $prm if $prm;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
print "r_struct_prm->{$morf}{$lemma} = $r_struct_prm->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
		}
	}
print "4. fitxer $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n";
}

# llegeixo el fitxer bilingüe: n, adj, adv, abbr
sub llegir_bidix {
	my ($fitx, $r_struct_rl, $r_struct_lr) = @_;
	my ($lemma_cat, $lemma_fra, $morf, $morf2, $dir);

#       <e><p><l>derrota<s n="n"/><s n="f"/></l><r>derrota<s n="n"/><s n="f"/></r></p></e>
#      <e><p><l>proper<s n="adj"/></l><r>imbeniente<s n="adj"/></r></p><par n="GD_mf"/></e>
#      <e r="LR"><p><l>aqueix<s n="prn"/><s n="tn"/></l><r>custu<s n="prn"/><s n="tn"/></r></p></e>
#      <e><p><l>pacient<s n="n"/></l><r>malàidu<s n="n"/></r></p><par n="mf_GD"/></e>
#      <e><p><l>arribar<g><b/>a</g><s n="vblex"/></l><r>arribare<g><b/>a</g><s n="vblex"/></r></p></e>
	while (my $linia = <$fitx>) {
next if $linia !~ /$MORF_TRACT/o;
		next if $linia =~ / i="yes"/o;
		chop $linia;
		$linia =~ s|<b/>| |og;
		$linia =~ s|<g>|#|og;
		$linia =~ s|</g>||og;
print "1. fitxer bidix, $linia\n" if $MOT && $linia =~ /$MOT/o;

		if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e vr="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_fra = $1;
			$morf = $2;
			$lemma_cat = $3;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_fra = $1;
			$morf = $2;
			$lemma_cat = $3;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_fra = $1;
			$morf = $2;
			$lemma_cat = $3;
			$dir = 'rl';
		} elsif ($linia =~ m|<e|o && $. > 140) {
			print STDERR "Error lectura bidix en l. $.: $linia\n";
		} else {
			next;
		}
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
next if $morf ne $MORF_TRACT;

		# en el cas de n i np busco el segon membre de la definició morfològica
#		if ($morf eq 'n' || $morf eq 'np') {
		if ($morf eq 'np') {
			if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".><s n="([^"]*)".>.*<r>([^<]*)<s|o) {
				$lemma_cat = $1;
				$morf = $2 . $3;
				$lemma_fra = $4;
			} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".><s n="([^"]*)".>.*<r>([^<]*)<s|o) {
				$lemma_cat = $1;
				$morf = $2 . $3;
				$lemma_fra = $3;
			} else {
				print STDERR "000x línia $.: $linia - morf $morf\n" unless $morf eq 'n';	# és normal que no hi hagi gènere en noms que en poden tenir dos
			}
		}

print "3. fitxer bidix, $linia, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;

		push @{$r_struct_rl->{$morf}{$lemma_fra}}, $lemma_cat if $dir eq 'bi' || $dir eq 'rl';
		push @{$r_struct_lr->{$morf}{$lemma_cat}}, $lemma_fra if $dir eq 'bi' || $dir eq 'lr';
print "r_struct_rl->{$morf}{$lemma_fra}[$#{$r_struct_rl->{$morf}{$lemma_fra}}] = $r_struct_rl->{$morf}{$lemma_fra}[$#{$r_struct_rl->{$morf}{$lemma_fra}}]\n" if $MOT && $lemma_fra =~ /$MOT/o;
print "r_struct_lr->{$morf}{$lemma_cat}[$#{$r_struct_lr->{$morf}{$lemma_cat}}] = $r_struct_lr->{$morf}{$lemma_cat}[$#{$r_struct_lr->{$morf}{$lemma_cat}}]\n" if $MOT && $lemma_cat =~ /$MOT/o;
	}
}

sub crear_g {
	my ($lemma_fra, $gram_fra) = @_;
#print "crear_g($lemma_fra, $gram_fra)\n";
	my ($cap, $cua);
#	couper# en morceux <vblex>
#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
	if ($lemma_fra =~ /#/o) {
		$cap = $`;
		$cua = $';
	} else {
		print STDERR "Error en crear_g($lemma_fra, $gram_fra)\n";
	}
	unless ($dix_fra{$gram_fra}{$cap}) {
		print STDERR "1. Falta fra $cap <$gram_fra> (0)\n";
		return 1;
	}
	$lemma_fra =~ s/#//o;
	$cua = " $cua";
	$cua =~ s/ +/ /og;
	$cua =~ s/ $//o;
	$cua =~ s/ /<b\/>/og;
	my $cua_par = $dix_fra{$gram_fra}{$cap};
	if ($cua_par =~ m|/|o) {
		$cua_par =~ s/__vblex$//o;
		$cua_par =~ s/__n$//o;
		$cua_par =~ s/^.*\///o;
		$cua_par =~ s/\[.*\]//o;
	} else {
		$cua_par = '';
	}
	my $lcua_par = length($cua_par) + length($dix_fra_prm{$gram_fra}{$cap});
	my $arrel = substr($cap, 0, length($cap)-$lcua_par);
#printf "$arrel, $cua_par, $lcua_par\n";
	if ($dix_fra_prm{$gram_fra}{$cap}) {
		printf $ffra "    <e lm=\"%s\"><p><l>%s</l><r>%s</r></p><par n=\"%s\" prm=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
			$lemma_fra, $arrel, $arrel, $dix_fra{$gram_fra}{$cap}, $dix_fra_prm{$gram_fra}{$cap}, $cua, $cua;
exit 0;
	} else {
		if ($lemma_fra =~ / à$/o) {
#    <e lm="consister à" r="LR"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/>à</l><r><g><b/>à</g></r></p></e>
#    <e lm="consister à" r="RL"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/><a/>à</l><r><g><b/>à</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/à$/<a\/>à/o;
			printf $ffra "    <e lm=\"%s\" r=\"LR\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
			printf $ffra "    <e lm=\"%s\" r=\"RL\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua2, $cua;
		} elsif ($lemma_fra =~ / de$/o) {
#    <e lm="convenir verbalement de" r="LR"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
#    <e lm="convenir verbalement de" r="RL"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/><a/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/de$/<a\/>de/o;
			printf $ffra "    <e lm=\"%s\" r=\"LR\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
			printf $ffra "    <e lm=\"%s\" r=\"RL\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua2, $cua;
		} else {
			printf $ffra "    <e lm=\"%s\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
		}
	}
	return 0;
}

# retorna 0 ssi la cadena no és a la llista
sub is_in {
	my ($r_list, $string) = @_;

	foreach my $r (@$r_list) {
		return 1 if $r eq $string;
	}
	return 0;
}

sub escriure_mono_vblex {
	my ($lemma_fra, $lemma_model_fra, $morf_fra, $autor) = @_;
	my $cua_par = $dix_fra{$morf_fra}{$lemma_model_fra};
	unless ($cua_par) {
		print STDERR "Error en escriure_mono_vblex ($lemma_fra, $morf_fra): dix_fra{$morf_fra}{$lemma_model_fra} = $dix_fra{$morf_fra}{$lemma_model_fra}\n";
		return;
	}
	$cua_par =~ s/__vblex$//o;
	$cua_par =~ s/^.*\///o;
	$cua_par =~ s/\[.*\]//o;
	my $lcua_par = length($cua_par) + length($dix_fra_prm{$morf_fra}{$lemma_model_fra});
	my $arrel = substr($lemma_fra,, 0, length($lemma_fra,)-$lcua_par);
	my $a = " a=\"$autor\"" if $autor;
	if ($dix_fra_prm{$morf_fra}{$lemma_model_fra}) {
		printf $ffra "    <e lm=\"%s\"$a>         <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n",
			$lemma_fra, $arrel, $dix_fra{$morf_fra}{$lemma_model_fra}, $dix_fra_prm{$morf_fra}{$lemma_model_fra};
	} else {
		printf $ffra "    <e lm=\"%s\"$a>         <i>%s</i><par n=\"%s\"/></e>\n",
			$lemma_fra, $arrel, $dix_fra{$morf_fra}{$lemma_model_fra}; 
	}
}

sub escriure_bidix_n {
	my ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor) = @_;

print "escriure_bidix_n ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_cat eq $MOT || $lemma_fra eq $MOT;
#print "escriure_bidix_n ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_cat eq $MOT || $lemma_fra =~ /musique/o;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	if ($lemma_fra =~ /#/o) {
		my $x = $lemma_fra;
		$x =~ s/#//;
		$par_fra = $dix_fra{$morf_fra}{$x};
	}
	my $par_cat = $dix_cat{$morf_cat}{$lemma_cat};
	if ($lemma_cat =~ /#/o) {
		my $x = $lemma_cat;
		$x =~ s/#//;
		$par_cat = $dix_cat{$morf_cat}{$x};
	}
	my $a = " a=\"$autor\"" if $autor;
	if ($par_fra eq 'abeille__n'
			&& ($par_cat eq 'abell/a__n'
			|| $par_cat eq 'accessibilitat__n'
			|| $par_cat eq 'acci/ó__n'
			|| $par_cat eq 'adre/ça__n'
			|| $par_cat eq 'alg/a__n'
			|| $par_cat eq 'barre/ja__n'
			|| $par_cat eq 'acústi/ca__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n'
			&& ($par_cat eq 'abric__n'
			|| $par_cat eq 'aband/ó__n'
			|| $par_cat eq 'abast__n'
			|| $par_cat eq 'ab/ús__n'
			|| $par_cat eq 'acc/és__n'
			|| $par_cat eq 'al/è__n'
			|| $par_cat eq 'as__n'
			|| $par_cat eq 'assa/ig__n'
			|| $par_cat eq 'bacall/à__n'
			|| $par_cat eq 'boc/í__n'
			|| $par_cat eq 'calab/ós__n'
			|| $par_cat eq 'capat/às__n'
			|| $par_cat eq 'carism/a__n'
			|| $par_cat eq 'rebu/ig__n'
			|| $par_cat eq 'r/és__n'
			|| $par_cat eq 'pa__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n' && $par_cat eq 'q__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_sg\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n' && $par_cat eq 'escombraries__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_pl\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n' && $par_cat eq 'càries__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n' && $par_cat eq 'atletisme__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sg\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abeille__n' && $par_cat eq 'campus__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_fra, $stem_cat;
#	} elsif ($par_fra eq 'admis_n' && $par_cat eq 'accionist/a__n') {
#		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'admis__n' && $par_cat eq 'angl/ès__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'admis__n' && $par_cat eq 'senyor__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'vende/ur__n') && $par_cat eq 'addict/e__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"abaissant_abstracte\"/></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'vende/ur__n')
		&& ($par_cat eq 'senyor__n'
			|| $par_cat eq 'americ/à__n'
			|| $par_cat eq 'angl/ès__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'vende/ur__n')
		&& ($par_cat eq 'accionist/a__n'
			|| $par_cat eq 'acompanyant__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'artiste__n' && $par_cat eq 'accionist/a__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'artiste__n' && $par_cat eq 'addict/e__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"neutre_neutre\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'artiste__n'
		&& ($par_cat eq 'asiàti/c__n'
			|| $par_cat eq 'senyor__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'livre__n'
		|| $par_fra eq 'administrat/eur__n' # molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& ($par_cat eq 'abric__n'
			|| $par_cat eq 'aband/ó__n'
			|| $par_cat eq 'abast__n'
			|| $par_cat eq 'ab/ús__n'
			|| $par_cat eq 'acc/és__n'
			|| $par_cat eq 'al/è__n'
			|| $par_cat eq 'as__n'
			|| $par_cat eq 'assa/ig__n'
			|| $par_cat eq 'bacall/à__n'
			|| $par_cat eq 'boc/í__n'
			|| $par_cat eq 'calab/ós__n'
			|| $par_cat eq 'capat/às__n'
			|| $par_cat eq 'carism/a__n'
			|| $par_cat eq 'rebu/ig__n'
			|| $par_cat eq 'r/és__n'
			|| $par_cat eq 'pa__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'livre__n'
#		|| $par_fra eq 'administrat/eur__n' # molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& ($par_cat eq 'abell/a__n'
			|| $par_cat eq 'accessibilitat__n'
			|| $par_cat eq 'acci/ó__n'
			|| $par_cat eq 'adre/ça__n'
			|| $par_cat eq 'alg/a__n'
			|| $par_cat eq 'barre/ja__n'
			|| $par_cat eq 'acústi/ca__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'livre__n'
#		|| $par_fra eq 'administrat/eur__n' # molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& $par_cat eq 'campus__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'mois__n' && $par_cat eq 'campus__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'argent__n'
		|| $par_fra eq 'personnel__n')
			&& $par_cat eq 'atletisme__n')
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"sg\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif (($par_fra eq 'argent__n'
		|| $par_fra eq 'personnel__n')
			&& $par_cat eq 'soif__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"sg\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'mois__n'
			&& ($par_cat eq 'abric__n'
			|| $par_cat eq 'aband/ó__n'
			|| $par_cat eq 'abast__n'
			|| $par_cat eq 'ab/ús__n'
			|| $par_cat eq 'acc/és__n'
			|| $par_cat eq 'al/è__n'
			|| $par_cat eq 'as__n'
			|| $par_cat eq 'assa/ig__n'
			|| $par_cat eq 'bacall/à__n'
			|| $par_cat eq 'boc/í__n'
			|| $par_cat eq 'calab/ós__n'
			|| $par_cat eq 'capat/às__n'
			|| $par_cat eq 'carism/a__n'
			|| $par_cat eq 'rebu/ig__n'
			|| $par_cat eq 'r/és__n'
			|| $par_cat eq 'pa__n')) {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'fois__n' && $par_cat eq 'càries__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'personnel_n' && $par_cat eq 'atletisme__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'vacances__n' && $par_cat eq 'afores__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'vacances__n' && $par_cat eq 'escombraries__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_fra, $stem_cat;

	} elsif ($par_fra eq 'BBVA__n' && $par_cat eq 'BBVA__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'IRPF__n' && $par_cat eq 'IRPF__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'BBC__n' && $par_cat eq 'BBC__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ATS__n' && $par_cat eq 'ATS__n') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"mf\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_n: par_fra = $par_fra ($lemma_fra) par_cat = $par_cat ($lemma_cat)\n";
print STDERR "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	}
}

sub escriure_bidix_adj {
	my ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor) = @_;

print "escriure_bidix_adj ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_cat eq $MOT || $lemma_fra eq $MOT;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	my $par_cat = $dix_cat{$morf_cat}{$lemma_cat};
	my $a = " a=\"$autor\"" if $autor;
	if ($par_fra eq 'abaissant__adj' && $par_cat eq 'afortuna/t__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'abstract/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"abaissant_abstracte\"/></e>\n", $stem_fra, $stem_cat;
		next if $lr_rl =~ /LR/o;
		$lr_rl = ' r="RL"';
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"sup\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'abusi/u__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'acadèmi/c__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'adept/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"abaissant_abstracte\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'alacant/í__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'afectu/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'afric/à__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'alt__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'annex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'complex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'dol/ç__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'f/erri__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'herb/aci__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'abaissant__adj' && $par_cat eq 'triparti/t__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'abstract/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"neutre_neutre\"/></e>\n", $stem_fra, $stem_cat;
		next if $lr_rl =~ /LR/o;
		$lr_rl = ' r="RL"';
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"sup\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'abusi/u__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'acadèmi/c__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'access/ori__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'adept/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"neutre_neutre\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'adjudicat/ari__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'afectu/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'afortuna/t__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'agrícol/a__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'alacant/í__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'alegr/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
		next if $lr_rl =~ /LR/o;
		$lr_rl = ' r="RL"';
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"sup\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'aliment/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'alt__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'arqueòl/eg__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'afectu/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'annex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'bas/c__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'bo/ig__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'complex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'ex/ogen__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'heterog/eni__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'injust__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'interm/edi__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'mixt__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'quals/evol__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'académique__adj' && $par_cat eq 'ros__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_esquimal\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq 'afectu/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq 'aliment/ós__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq 'complex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affectueu/x__adj' && $par_cat eq '/ossi__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'abusi/u__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'heterog/eni__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'to/u__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'affirmati/f__adj' && $par_cat eq 'triparti/t__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'amica/l__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'amica/l__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'amica/l__adj' && $par_cat eq 'adjudicat/ari__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'amica/l__adj' && $par_cat eq 'fict/ici__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'afgan/ès__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'acadèmi/c__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'afric/à__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'ass/iri__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'ate/u__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'far/ingi__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ancien__adj' && $par_cat eq 'fict/ici__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'adept/e__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_adepte\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'afgan/ès__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'afortuna/t__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'alacant/í__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'anglais__adj' && $par_cat eq 'annex__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'annuel__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ch/er__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ch/er__adj' && $par_cat eq 'acadèmi/c__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ch/er__adj' && $par_cat eq 'afric/à__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'ch/er__adj' && $par_cat eq 'ali/è__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'conduct/eur__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'conduct/eur__adj' && $par_cat eq 'adjudicat/ari__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'dou/x__adj' && $par_cat eq 'dol/ç__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglais_anglès\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'publi/c__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'secr/et__adj' && $par_cat eq 'abdominal__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_fra, $stem_cat;
	} elsif ($par_fra eq 'secr/et__adj' && $par_cat eq 'absolut__adj') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_fra, $stem_cat;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_adj: par_fra = $par_fra ($lemma_fra) par_cat = $par_cat ($lemma_cat)\n";
print STDERR "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	}
}

sub escriure_bidix {
	my ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor) = @_;
	$lr_rl = " $lr_rl" if $lr_rl;
	my $a = " a=\"$autor\"" if $autor;
	if ($morf_cat eq 'vblex' && $morf_fra eq 'vblex') {
		printf $fbi "<e$a$lr_rl><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_fra, $morf_fra, $stem_cat, $morf_cat;
	} elsif ($morf_cat eq 'n' && $morf_fra eq 'n') {
		escriure_bidix_n ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor);
	} elsif ($morf_cat eq 'adj' && $morf_fra eq 'adj') {
		escriure_bidix_adj ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor);
	} else {
		print STDERR "No hi ha regla per a escriure_bidix($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n";
	}
}

sub lema_fra_existeix_o_es_pot_crear {
	my ($lemma_fra, $morf_fra, $autor) = @_;
#print STDERR "lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	return 1 if $dix_fra{$morf_fra}{$lemma_fra};

	# no existeix
	# potser es pot crear si és un verb amb <g> i tenim la capçalera
	return 0 if $lemma_fra =~ /^se /o;
	return 0 if $lemma_fra =~ /^s'/o;
	if ($lemma_fra =~ /#/o) {
		return ! crear_g($lemma_fra, $morf_fra);
	} else {
		if ($morf_fra eq 'vblex') {
			my $a = " a=\"$autor\"" if $autor;
			if ($lemma_fra =~ /^ré/) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/^ré//o;
				if ($dix_fra{$morf_fra}{$stem_fra}) {
					escriure_mono_vblex($lemma_fra, $stem_fra, $morf_fra, $autor);
					return 1;
				}
			} elsif ($lemma_fra =~ /^re/) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/^re//o;
				if ($dix_fra{$morf_fra}{$stem_fra}) {
					escriure_mono_vblex($lemma_fra, $stem_fra, $morf_fra, $autor);
					return 1;
				}
			}
			if ($lemma_fra =~ /ger$/o) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/er$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'allong/er__vblex';
				return 1;
			} elsif ($lemma_fra =~ /yer$/o) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/yer$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'bala/yer__vblex';
				return 1;
			} elsif ($lemma_fra =~ /cer$/o) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/cer$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'annon/cer__vblex';
				return 1;
			} elsif ($lemma_fra =~ /e(.)er$/o) {
				my $cons = $1;
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/e.er$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
				return 1;
			} elsif ($lemma_fra =~ /é(.)er$/o) {
				my $cons = $1;
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/é.er$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'accél/é[R]er__vblex', $cons;
				return 1;
			} elsif ($lemma_fra =~ /iser$/o
				|| $lemma_fra =~ /yser$/o
				|| $lemma_fra =~ /ier$/o
				|| $lemma_fra =~ /quer$/o
				|| $lemma_fra =~ /guer$/o
				|| $lemma_fra =~ /enter$/o
				|| $lemma_fra =~ /brer$/o
				|| $lemma_fra =~ /[aiou][bdflmnprstv]er$/o
				|| $lemma_fra =~ /[aiou][bcdflmnprstv][bdfhlmnprstv]er$/o) {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s/er$//o;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'abaiss/er__vblex';
				return 1;
			} else {
				return 0;
			}
		} elsif ($morf_fra eq 'adj') {
			my $tmp = $dix_fraadj_def{$morf_fra}{$lemma_fra};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o;
				print $ffra $tmp, "\n";
				$dix_fra{$morf_fra}{$lemma_fra} = $dix_fraadj{$morf_fra}{$lemma_fra};
				return 1;
			} else {
				return 0;
			}
		} elsif ($morf_fra eq 'n') {
			my $tmp = $dix_fran_def{$morf_fra}{$lemma_fra};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o;
				print $ffra $tmp, "\n";
				$dix_fra{$morf_fra}{$lemma_fra} = $dix_fran{$morf_fra}{$lemma_fra};
				return 1;
			} else {
				return 0;
			}
		}
		return 0;
	}
}

# aquesta funció fa el tractament d'una parella neta (1 lema cat - 1 lema fra), introduint el que calgui en els diccionaris
# no verifica que el lema cat és en el diccionari, perquè sabem que totes les entrades ho estan
sub tractar_parella {
	my ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $autor, $n_linia) = @_;

#print "tractar_parella ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $autor)\n";
print "tractar_parella ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, $autor)\n" if $lemma_cat eq $MOT || $lemma_fra eq $MOT;
#print "5. fra dix_fra{$MORF_TRACT}{$MOT} = $dix_fra{$MORF_TRACT}{$MOT}\n";
	if (exists $dix_fra_cat{$morf_fra}{$lemma_fra}) {
		# ja existeix una traducció per al lema fra
		if (is_in($dix_fra_cat{$morf_fra}{$lemma_fra}, $lemma_cat)) {
			# ja existeix aquesta traducció per al lema fra
			# no fem res
			return;
		} else {
			# no existeix encara aquesta traducció per al lema fra
			if (exists $dix_cat_fra{$morf_cat}{$lemma_cat}) {
				# ja existeix una traducció per al lema cat
				if (is_in($dix_cat_fra{$morf_cat}{$lemma_cat}, $lemma_fra)) {
					# ja existeix aquesta traducció per al lema cat
					# no fem res
					return;
				} else {
					# introduïm la parella perquè en quedi constància (algun dia es pot activar), però fem que s'ignori
print "1. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'i=\"yes\"', $autor)\n" if $MOT && ($lemma_cat =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "1. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'i=\"yes\"', $autor)\n" if $lemma_fra eq 'rifle';
					escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'i="yes"', $autor);
					return;
				}
			} else {
				# no existeix encara una traducció per al lema cat
				# recordatori: ja existeix una traducció per al lema fra (ergo: està en el monodix fra)
				# traducció en la direcció cat > fra
print STDERR "2. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r=\"RL\"', $autor)\n" if $MOT && ($lemma_cat =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "2. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r=\"RL\"', $autor)\n" if $lemma_fra eq 'rifle';
				escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r="RL"', $autor);
				return;
			}
		}

	} else {
		# no existeix una traducció per al lema fra
		if (exists $dix_cat_fra{$morf_cat}{$lemma_cat}) {
			# ja existeix una traducció per al lema cat
			if (is_in($dix_cat_fra{$morf_cat}{$lemma_cat}, $lemma_fra)) {
				# ja existeix aquesta traducció per al lema cat
				# no fem res
				return;
			} elsif (lema_fra_existeix_o_es_pot_crear ($lemma_fra, $morf_fra, $autor)) {
print STDERR "3. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r=\"LR\"', $autor)\n" if $MOT && ($lemma_cat =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "3. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r=\"LR\"', $autor)\n" if $lemma_fra eq 'rifle';
				escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, 'r="LR"', $autor);
				return;
			} else {
				print STDERR "2. Falta fra $lemma_fra <$morf_fra> (1), l. $n_linia\n";
				return;
			}
		} else {
			if (lema_fra_existeix_o_es_pot_crear ($lemma_fra, $morf_fra)) {
#print STDERR "4. escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, '', $autor)\n" if $lemma_fra eq 'rifle';
				escriure_bidix ($lemma_cat, $stem_cat, $morf_cat, $lemma_fra, $stem_fra, $morf_fra, '', $autor);
				return;
			} else {
				print STDERR "3. Falta fra $lemma_fra <$morf_fra> (2), l. $n_linia\n";
print "dix_fra_cat{$morf_fra}{$lemma_fra} =  $dix_fra_cat{$morf_fra}{$lemma_fra}\n" if $lemma_fra eq $MOT;
				return;
			}
		}
	}
}

llegir_dix('fra', $fdixfra, \%dix_fra, \%dix_fra_prm);
print "1. nfitx = fra dix_fra{$MORF_TRACT}{$MOT} = $dix_fra{$MORF_TRACT}{$MOT}\n";
llegir_dix('cat', $fdixcat, \%dix_cat);
print "2. nfitx = cat dix_cat{$MORF_TRACT}{$MOT} = $dix_cat{$MORF_TRACT}{$MOT}\n";
llegir_dix_ortola('fra', $fdixfran, \%dix_fran, \%dix_fran_def) if $MORF_TRACT eq 'n';
print "3. nfitx = fra dix_fran{$MORF_TRACT}{$MOT} = $dix_fran{$MORF_TRACT}{$MOT}\n";
llegir_dix_ortola('fra', $fdixfraadj, \%dix_fraadj, \%dix_fraadj_def) if $MORF_TRACT eq 'adj';
print "4. nfitx = fra dix_fraadj{$MORF_TRACT}{$MOT} = $dix_fraadj{$MORF_TRACT}{$MOT}\n";
llegir_bidix($fdixbi, \%dix_fra_cat, \%dix_cat_fra);
#print "5. dix_cat_fra{$MORF_TRACT}{$MOT}[0] = $dix_cat_fra{$MORF_TRACT}{$MOT}[0]\n"; COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "5. dix_fra_cat{$MORF_TRACT}{$MOT}[0] = $dix_fra_cat{$MORF_TRACT}{$MOT}[0]\n"; # COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "6. dix_fra_cat{$MORF_TRACT}{$MOT} = $dix_fra_cat{$MORF_TRACT}{$MOT}\n";

<STDIN>;	# saltem la primera línia
my ($stem_cat, $stem_fra, $gen_cat, $gen_fra, $num_cat, $num_fra, $lemma_cat, $lemma_fra, $lemma_cat_ini, $lemma_fra_ini);
while (my $linia = <STDIN>) {
next if $linia !~ /$MORF_TRACT/o;
	next if $linia =~ /xxx/io;
	next if $linia =~ /---/o;
	chop $linia;

	if ($linia =~ /\(/o) {
		print STDERR "Error en l. $.: $linia\n";
		next;
	}

	$linia =~ s/[^a-zàèéíòóúçA-ZÀÈÉíÒÓÚÇ\t]+$//o;
	$linia =~ s|\r| |og;
	$linia =~ s|#|# |og;	# per evitar errors com "faire#pression sur"
	$linia =~ s|' |'|og;	# coup d' État
	$linia =~ s| +| |og;

	# arreglem majúscules
	# passo tot a minúscules, excepte si hi ha noms propis o acrònims
	if ($linia !~ /<np>/o && $linia !~ /<acr>/o) {
		$linia =~ tr/[A-ZÀÈÉíÒÓÚÇ]/[a-zàèéíòóúç/;
	}

	my @dades = split /\t/, $linia;
	for (my $i=0; $i<=$#dades; $i++) { 
		$dades[$i] =~ s/^ +//o;
		$dades[$i] =~ s/ +$//o;
	}

	next unless $dades[3];			# línia buida
	next if $dades[5] =~ /\?/o;		# dubtes
	next if length $dades[1] == 1;		# una sola lletra
#print "99. $. dades[1] = $dades[1]\n" if length $dades[1] == 1;	# una sola lletra

	$stem_cat = $dades[1];
	$stem_cat =~ s| +| |og;
	$stem_cat =~ s|^ ||o;
	$stem_cat =~ s| $||o;
	$stem_cat =~ s|#$||o;
	$lemma_cat_ini = $lemma_cat = $stem_cat;
	if ($stem_cat =~ m/\#/o) {
		$stem_cat = $` . '<g>' . $' . '</g>';
	}
	$stem_cat =~ s| |<b/>|og;

	my $gram_cat = $dades[2];
next if $gram_cat !~ /^<$MORF_TRACT>/o;
	$gram_cat =~ s/^ *<//og;
	$gram_cat =~ s/> *$//og;
	$gram_cat =~ s/><//og;

	# xxxxxxxxxxxx DE MOMENT DEIXO AIXO COMENTAT, PERQUE NO HO ENTENC BE 
#VERIFICAR
#	if ($gram_cat eq 'nm' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nm paraules que són n (i.e. m+f)
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
#		next;
#	}
#VERIFICAR
#	if ($gram_cat eq 'nmf' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nmf paraules que estan posades com a n
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
#		next;
#	}
#print "Sí es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";

#	$lemma_cat =~ s/#//o;


	$dades[3] =~ s|,|;|og;
	$dades[3] =~ s|:|;|og;

	my $autor = $dades[6];
	$autor =~ s| +| |og;
	$autor =~ s|^ ||o;
	$autor =~ s| $||o;
	$autor =~ s|^jl$|joan|o;
print "$linia\n" if $MOT && $lemma_cat eq $MOT;;
print "autor = $autor\n" if $MOT && $lemma_cat eq $MOT;;

print "11. $linia - stem_cat=$stem_cat, lemma_cat=$lemma_cat, gram_cat = $gram_cat, dades[3]=$dades[3]\n" if $MOT && $lemma_cat =~ /$MOT/o;
	my @stem_fra = split /;/o, $dades[3];
	my $primer = 1;
	my $n = 0; 	# index en @stem_fra
	foreach my $stem_fra (@stem_fra) {
#print STDERR "stem_fra = #$stem_fra#\n";
		$stem_fra =~ s| +| |og;
		$stem_fra =~ s|^ ||o;
		$stem_fra =~ s| $||o;
		$stem_fra =~ s| $||o;	# no és un espai en blanc (no sé què és però apareix en el fitxer: ho posa l'Open Office davant de ; en francès)
		next unless $stem_fra;
#print STDERR "stem_fra = #$stem_fra#\n";
		$lemma_fra_ini = $lemma_fra = $stem_fra;
		if ($stem_fra =~ m/\#/o) {
			$stem_fra = $` . '<g>' . $' . '</g>';
#			$lemma_fra =~ s/#//o;
		}
		$stem_fra =~ s| |<b/>|og;

		my $gram_cat = $dades[2];
		$gram_cat =~ s/ //og;
		$gram_cat =~ s/^ *<//og;
		$gram_cat =~ s/> *$//og;
		if ($gram_cat =~ /></o) {
			my @gram_cat = split /;/o, $gram_cat;
			$gram_cat = $gram_cat[$n];
			$gram_cat = $gram_cat[0] unless $gram_cat;	# potser hi ha només una definició per a totes les possibilitats
			$gram_cat = 'n' if $gram_cat =~ /^n>/o;
			$gram_cat = 'np' if $gram_cat =~ /^np>/o;
		}

		my $gram_fra = $dades[4];
		$gram_fra =~ s/ //og;
		if ($gram_fra) {
			$gram_fra =~ s/^ *<//og;
			$gram_fra =~ s/> *$//og;
			if ($gram_fra =~ /></o) {
				my @gram_fra = split /;/o, $gram_fra;
				$gram_fra = $gram_fra[$n];
				$gram_fra = $gram_fra[0] unless $gram_fra;	# potser hi ha només una definició per a totes les possibilitats
				$gram_fra = 'n' if $gram_fra =~ /^n>/o;
				$gram_fra = 'np' if $gram_cat =~ /^np>/o;
			}
		} else {
			$gram_fra = $gram_cat;
		}
print "12. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_cat = $gram_cat, gram_fra = $gram_fra\n" if $MOT && $lemma_cat =~ /$MOT/o;
#print "12. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_cat = $gram_cat, gram_fra = $gram_fra\n";

		tractar_parella ($lemma_cat, $stem_cat, $gram_cat, $lemma_fra, $stem_fra, $gram_fra, $autor, $.);
	}

}
