#!/usr/bin/perl

# En aquest programa es llegeix el fitxer amb 4 columnes separades per tabuladors amb paraules amb categories tancaes
# 0. ocurrències
# 1. paraula catalana
# 2. categoria gramatical catalana
# 3. paraula francesa
# 4. categoria gramatical francesa
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari

use strict;
use utf8;

my $MOT = 'crever les yeux';	# paraula a debugar
#my $MOT = '';

my ($ffra, $fbi, $fdixfra, $fdixcat, $fdixbi);

open($fdixfra, "../apertium-fra/apertium-fra.fra.metadix") || die "can't open apertium-fra.fra.metadix: $!";
open($fdixcat, "../apertium-cat/apertium-cat.cat.dix") || die "can't open apertium-cat.cat.dix: $!";
open($fdixbi, "apertium-fra-cat.fra-cat.dix") || die "can't open apertium-fra-cat.fra-cat.dix: $!";

open($ffra, ">f_fra.dix.txt") || die "can't open f_fra.dix: $!";
open($fbi, ">f_bi.dix.txt") || die "can't open f_bi.dix: $!";

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixfra, ":encoding(UTF-8)");
binmode($fdixcat, ":encoding(UTF-8)");
binmode($fdixbi, ":encoding(UTF-8)");
binmode($ffra, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

my %dix_fra = ();
my %dix_fra_prm = ();
my %dix_cat = ();
my %dix_bi = ();		# CAL ELIMINAR-HO (NO HO FAIG DE SEGUIDA PER EVITAR ERRORS SINTACTICS)
my %dix_fra_cat = ();
my %dix_cat_fra = ();


# llegeixo el fitxer fra: n, adj, adv, np, abbr
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct, $r_struct_prm) = @_;
	my ($lemma, $par, $prm, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;
		next if $linia =~ /r="LR"/o;
		next if $linia =~ /<!-- .*<e/o;

next if $linia !~ /vblex/o;

		#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
#     <e lm="emprunt" a="joan"><i>emprunt</i><par n="livre__n"/></e>

print "1. fitxer $nfitx, $linia\n" if $nfitx eq 'cat' && $MOT && $linia =~ /$MOT/o;
		$prm = '';
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)" prm="(.)"/></e>|o) {
			$lemma = $1;
			$par = $2;
			$prm = $3;

		} elsif ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)">[^<]*<par n="(.*)"/></e>|o) {
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
print "2. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $MOT && $linia =~ /$MOT/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'np' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $MOT && $linia =~ /$MOT/o;

		if ($r_struct->{$morf}{$lemma} && $morf ne 'vblex') {
			print STDERR "Error dix $nfitx: lemma $lemma (morf = $morf, par = $par) ja definit com a morf = $morf, par = $r_struct->{$morf}{$lemma}\n";
		} else {
			$r_struct->{$morf}{$lemma} = $par;
			$r_struct_prm->{$morf}{$lemma} = $prm if $prm;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
print "r_struct_prm->{$morf}{$lemma} = $r_struct_prm->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
		}
	}
}

# llegeixo el fitxer bilingüe: n, adj, adv, np, abbr
sub llegir_bidix {
	my ($fitx, $r_struct_lr, $r_struct_rl) = @_;
	my ($lemma_cat, $lemma_fra, $morf, $morf2, $dir);

#       <e><p><l>derrota<s n="n"/><s n="f"/></l><r>derrota<s n="n"/><s n="f"/></r></p></e>
#      <e><p><l>proper<s n="adj"/></l><r>imbeniente<s n="adj"/></r></p><par n="GD_mf"/></e>
#      <e r="LR"><p><l>aqueix<s n="prn"/><s n="tn"/></l><r>custu<s n="prn"/><s n="tn"/></r></p></e>
#      <e><p><l>pacient<s n="n"/></l><r>malàidu<s n="n"/></r></p><par n="mf_GD"/></e>
#      <e><p><l>arribar<g><b/>a</g><s n="vblex"/></l><r>arribare<g><b/>a</g><s n="vblex"/></r></p></e>
	while (my $linia = <$fitx>) {
next if $linia !~ /vblex/o;
		chop $linia;
		$linia =~ s|<b/>| |og;
		$linia =~ s|<g>|#|og;
		$linia =~ s|</g>||og;
print "1. fitxer bidix, $linia\n" if $MOT && $linia =~ /$MOT/o;
		if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_fra = $1;
			$morf = $2;
			$lemma_cat = $3;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_fra = $1;
			$morf = $2;
			$lemma_cat = $3;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
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
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'np' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}

		# en el cas de n i np busco el segon membre de la definició morfològica
		if ($morf eq 'n' || $morf eq 'np') {
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

		$dix_bi{$morf}{$lemma_cat} = $lemma_fra;		# PROVISIONAL (CAL TREURE-HO)
		$r_struct_lr->{$morf}{$lemma_cat} = $lemma_fra if $dir eq 'bi' || $dir eq 'lr';
		$r_struct_rl->{$morf}{$lemma_cat} = $lemma_fra if $dir eq 'bi' || $dir eq 'rl';
print "r_struct_lr->{$morf}{$lemma_cat} = $r_struct_lr->{$morf}{$lemma_cat}\n" if $MOT && $lemma_cat =~ /$MOT/o;
print "r_struct_rl->{$morf}{$lemma_cat} = $r_struct_rl->{$morf}{$lemma_cat}\n" if $MOT && $lemma_cat =~ /$MOT/o;
	}
}

sub crear_g {
	my ($lemma_fra, $gram_fra) = @_;
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
		print STDERR "Falta fra $cap <$gram_fra>\n";
		return 1;
	}
	$lemma_fra =~ s/#//o;
	$cua = " $cua";
	$cua =~ s/ +/ /og;
	$cua =~ s/ $//o;
	$cua =~ s/ /<b\/>/og;
	my $cua_par = $dix_fra{$gram_fra}{$cap};
	$cua_par =~ s/__vblex$//o;
	$cua_par =~ s/^.*\///o;
	$cua_par =~ s/\[.*\]//o;
	my $lcua_par = length($cua_par) + length($dix_fra_prm{$gram_fra}{$cap});
	my $arrel = substr($cap, 0, length($cap)-$lcua_par);
#printf $ffra "$arrel, $cua_par, $lcua_par\n";
	if ($dix_fra_prm{$gram_fra}{$cap}) {
		printf $ffra "    <e lm=\"%s\"><p><l>%s</l><r>%s</r></p><par n=\"%s\" prm=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
			$lemma_fra, $arrel, $arrel, $dix_fra{$gram_fra}{$cap}, $dix_fra_prm{$gram_fra}{$cap}, $cua, $cua;
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

}


llegir_dix('fra', $fdixfra, \%dix_fra, \%dix_fra_prm);
llegir_dix('cat', $fdixcat, \%dix_cat);
llegir_bidix($fdixbi, \%dix_fra_cat, \%dix_cat_fra);

<STDIN>;	# saltem la primera línia
my ($stem_cat, $stem_fra, $gen_cat, $gen_fra, $num_cat, $num_fra, $lemma_cat, $lemma_fra, $lemma_cat_ini, $lemma_fra_ini);
while (my $linia = <STDIN>) {
next if $linia !~ /vblex/o;
	next if $linia =~ /xxx/o;
	chop $linia;
	$linia =~ s/[^a-z\t]+$//o;
	$linia =~ s|\r| |og;
	$linia =~ s| +| |og;
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
	$lemma_cat_ini = $lemma_cat = $stem_cat;
	if ($stem_cat =~ m/\#/o) {
		$stem_cat = $` . '<g>' . $' . '</g>';
	}
	$stem_cat =~ s| |<b/>|og;

	my $gram_cat = $dades[2];
	$gram_cat =~ s/^ *<//og;
	$gram_cat =~ s/> *$//og;
	$gram_cat =~ s/><//og;
	# verifico que la paraula no estigui ja en en diccionari bilingüe
VERIFICAR
	if ($dix_bi{$gram_cat}{$lemma_cat}) {
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
		next;
	}
VERIFICAR
	if ($gram_cat eq 'nm' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nm paraules que són n (i.e. m+f)
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
		next;
	}
VERIFICAR
	if ($gram_cat eq 'nmf' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nmf paraules que estan posades com a n
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
		next;
	}
#print "Sí es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
	$lemma_cat =~ s/#//o;


	$dades[3] =~ s|,|;|og;
	$dades[3] =~ s|:|;|og;

print "11. $linia - stem_cat=$stem_cat, lemma_cat=$lemma_cat, gram_cat = $gram_cat, dades[3]=$dades[3]\n" if $MOT && $lemma_cat =~ /$MOT/o;
	my @stem_fra = split /;/o, $dades[3];
	my $primer = 1;
	my $n = 0; 	# index en @stem_fra
	foreach my $stem_fra (@stem_fra) {
		$stem_fra =~ s| +| |og;
		$stem_fra =~ s|^ ||o;
		$stem_fra =~ s| $||o;
		next unless $stem_fra;
		$lemma_fra_ini = $lemma_fra = $stem_fra;
		if ($stem_fra =~ m/\#/o) {
			$stem_fra = $` . '<g>' . $' . '</g>';
			$lemma_fra =~ s/#//o;
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

		# sortida: diccionari bilingüe
		if (!$dix_fra{$gram_fra}{$lemma_fra} && $lemma_fra_ini =~ /#/o) {
			crear_g ($lemma_fra_ini, $gram_fra);
		}
		if ($gram_cat eq 'vblex') {
			# comprovo que és en el diccionari monolingüe
			print STDERR "Falta fra $lemma_fra_ini <$gram_fra>\n" unless $dix_fra{$gram_fra}{$lemma_fra};
#			print "dix_fra{$gram_fra}{$lemma_fra} = $dix_fra{$gram_fra}{$lemma_fra}\n";
			next unless $dix_fra{$gram_fra}{$lemma_fra};

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_fra\"/></r></p></e>\n", $stem_cat, $stem_fra;

		} elsif ($gram_cat eq 'adv') {
			# comprovo que és en el diccionari monolingüe
			unless ($dix_fra{$gram_fra}{$lemma_fra}) {
				if ($gram_fra eq 'adv') {
				# generem el paradigma al diccionari sard
					my $par_fra = 'bene__adv';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} else {
					print STDERR "Falta fra $lemma_fra <$gram_fra>\n" unless $dix_fra{$gram_fra}{$lemma_fra};
#					print "dix_fra{$gram_fra}{$lemma_fra} = $dix_fra{$gram_fra}{$lemma_fra}\n";
					next;
				}
			}

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_fra\"/></r></p></e>\n", $stem_cat, $stem_fra;

		} elsif ($gram_cat eq 'adj') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_fra = $dix_fra{$gram_fra}{$lemma_fra};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;

			unless ($par_fra) {
				# generem el paradigma al diccionari sard (tot i que només en alguns casos)
				if ($lemma_fra =~ /^de /) {
					$par_fra = 'matessi__adj';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($lemma_fra =~ /^a /) {
					$par_fra = 'matessi__adj';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($lemma_fra =~ /^chi /) {
					$par_fra = 'chi_proveni/t__adj';
					my $stem_fra2 = $stem_fra;
					$stem_fra2 =~ s/t$//o;
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra2, $par_fra;
				} else {
					print STDERR "Falta fra $lemma_fra <$gram_fra>\n";
					next;
				}
			}

			if ($par_cat eq 'multimèdia__adj' && $par_fra eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_fra eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_fra eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bre/u__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD+sup_0\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adept/e__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'chi_proveni/t__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abdominal__adj' && $par_fra eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abstract/e__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'preco/ç__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"capaç_capatzu\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'preco/ç__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"capaç_capatze\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'access/ori__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'andal/ús__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'access/ori__adj' && $par_fra eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'a/eri__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'arqueòl/eg__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afric/à__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'sangu/ini__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'far/ingi__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afric/à__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alacant/í__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'contempor/ani__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ami/c__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'complex__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'interm/edi__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'complex__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_fra eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'to/u__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p>/e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'to/u__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adjudicat/ari__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'aliment/ós__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ali/è__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'imprec/ís__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'banduler/i__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adjudicat/ari__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afgan/ès__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'af/í__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alacant/í__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bo__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'dol/ç__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_fra eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'belg/a__adj' && $par_fra eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'j/ove__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'absolut__adj' && $par_fra eq 'de_dos__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"ord\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ali/è__adj' && $par_fra eq 'de_dos__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"ord\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ate/u__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'annex__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'annex__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alt__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'amfitri/ó__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'amfitri/ó__adj' && $par_fra eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'cont/inu__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'fict/ici__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'fict/ici__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'gal__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'heterog/eni__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'perp/etu__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'r/àpid__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bas/c__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bas/c__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'blan/c__adj' && $par_fra eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alt__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bo__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bo__adj' && $par_fra eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'important__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'important__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alegr/e__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bre/u__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'esc/às__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'genu/í__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ce/c__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'genu/í__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'altr/e__adj' && $par_fra eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'po/c__adj' && $par_fra eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"ind\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'multimèdia__adj' && $par_fra eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} else {
				print STDERR "adj 1. par_cat = $par_cat, par_fra = $par_fra, $stem_cat > $stem_fra\n";
			}

		} elsif ($gram_cat eq 'n') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_fra = $dix_fra{$gram_fra}{$lemma_fra};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
#			print STDERR "dades[1] = #$dades[1]#, length = ", length($dades[1]), "\n" unless $par_cat;
			next unless $par_cat;

			unless ($par_fra) {
				# generem el paradigma al diccionari sard (tot i que només en alguns casos)
				if ($par_cat eq 'BBC__n') {
					$par_fra = 'TV__n';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($par_cat eq 'BBVA__n') {
					$par_fra = 'PNB__n';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} else {
					print STDERR "Falta fra $lemma_fra <$gram_fra>\n";
					next;
				}
			}

			if ($par_cat eq 'abell/a__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abell/a__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abell/a__n' && $par_fra eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adre/ça__n' && $par_fra eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abell/a__n' && $par_fra eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alg/a__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alg/a__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abell/a__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abell/a__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acci/ó__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acci/ó__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acci/ó__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acci/ó__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adre/ça__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adre/ça__n' && $par_fra eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adre/ça__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'atletisme__n' && $par_fra eq 'nord__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'atletisme__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sg_ND\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'gay__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'nord__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sg\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acetil/è__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bacall/à__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bacall/à__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'aband/ó__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bacall/à__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'or/igen__n' && $par_fra eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'aband/ó__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'aband/ó__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abd/omen__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'antic/òs__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'passad/ís__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'as__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'as__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'as__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'barre/ja__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'barre/ja__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'caf/è__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'caf/è__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'carism/a__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'carism/a__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abast__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abast__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acc/és__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abast__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acc/és__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'assa/ig__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'rebu/ig__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'assa/ig__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'caf/è__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'cos__n' && $par_fra eq 'temp/us__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'cos__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'm/arge__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'pa__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'cos__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'pa__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'atletisme__n' && $par_fra eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'campus__n' && $par_fra eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'campus__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'campus__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'campus__n' && $par_fra eq 'temp/us__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'campus__n' && $par_fra eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'as__n' && $par_fra eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accionist/a__n' && $par_fra eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accionist/a__n' && $par_fra eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'col·leg/a__n' && $par_fra eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'col·leg/a__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'monar/ca__n' && $par_fra eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'ingegner/i__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'acompanyant__n' && $par_fra eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'av/ís__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'boc/í__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'capat/às__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'desi/g__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'nitr/ogen__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'pols__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;

			} elsif ($par_cat eq 'addict/e__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'xil/è__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'angl/ès__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accionist/a__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'accionist/a__n' && $par_fra eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'advoca/t__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'advoca/t__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alacant/í__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'americ/à__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'amfitri/ó__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ami/c__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'asiàti/c__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_fra eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ate/u__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'biòl/eg__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'indiv/idu__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'rus__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 've/í__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'ingegner/i__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_fra eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'administrati/u__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alcalde__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'pres__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alcalde__n' && $par_fra eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'alcalde__n' && $par_fra eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'emperad/or__n' && $par_fra eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'bar/ó__n' && $par_fra eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'cont/e__n' && $par_fra eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'camous_n' && $par_fra eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'guardaespatlles__n' && $par_fra eq 'gay__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_fra;

			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'senyor__n' && $par_fra eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'abric__n' && $par_fra eq 'traballador/e__n,') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_fra;

			} elsif ($par_cat eq 'q__n' && $par_fra eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/>/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'BBC__n' && $par_fra eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'BBVA__n' && $par_fra eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'BBVA__n' && $par_fra eq 'PNB__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'BBC__n' && $par_fra eq 'TV__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'IRPF__n' && $par_fra eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'PNB__n' && $par_fra eq 'IRPF__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'TV__n' && $par_fra eq 'MTS__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_fra;
			} else {
				print STDERR "n 1. par_cat = $par_cat, par_fra = $par_fra, $stem_cat > $stem_fra\n";
			}


		} elsif ($gram_cat eq 'np') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_fra = $dix_fra{$gram_fra}{$lemma_fra};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;

			unless ($par_fra) {
print "No es troba dix_fra{$gram_fra}{$lemma_fra}. Es prova de generar $lemma_fra\n" if $MOT && $lemma_cat =~ /$MOT/o;
				# generem el paradigma al diccionari sard
				if ($gram_fra eq 'np><ant><m><sg') {
					$par_fra = 'Antoni__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><ant><f><sg') {
					$par_fra = 'Maria__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra =~ /^np><cog/o) {
					$par_fra = 'Saussure__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><top><f><sg') {
					$par_fra = 'Etiòpia__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><top><m><sg') {
					$par_fra = 'Afganistàn__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><top><f><pl') {
					$par_fra = 'Is_Pratzas__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><top><m><pl') {
					$par_fra = 'Istados_Unidos__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><hyd><m><sg') {
					$par_fra = 'Po__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><hyd><f><sg') {
					$par_fra = 'Loira__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><al><m><sg') {
					$par_fra = 'Linux__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} elsif ($gram_fra eq 'np><al><f><sg') {
					$par_fra = 'Wikipedia__np';
					printf $ffra "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, $par_fra;
				} else {
					print STDERR "Falta fra $lemma_fra [$gram_fra], [$gram_cat] - no el podem generar (falten dades)\n" unless $par_fra;
					next;
				} 
			}

			if ($par_cat eq 'Abad__np' && $par_fra eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Abad__np' && $par_fra eq 'Maria__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Pau__np' && $par_fra eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Abad__np' && $par_fra eq 'Maria__np') {
			} elsif ($par_cat eq 'Marc__np' && $par_fra eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Maria__np' && $par_fra eq 'Maria__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Abad__np' && $par_fra eq 'Saussure__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"cog\"/><s n=\"mf\"/><s n=\"sp\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Saussure__np' && $par_fra eq 'Saussure__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"cog\"/></l><r>%s<s n=\"np\"/><s n=\"cog\"/>></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Afganistàn__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Etiòpia__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Istados_Unidos__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Is_Pratzas__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Po__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"hyd\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'Afganistan__np' && $par_fra eq 'Loira__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ABC__np' && $par_fra eq 'Fiat__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ABC__np' && $par_fra eq 'Linux__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} elsif ($par_cat eq 'ABC__np' && $par_fra eq 'Wikipedia__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_fra;
			} else {
				print STDERR "np 1. par_cat = $par_cat, par_fra = $par_fra, $stem_cat > $stem_fra\n";
			}

		} else {
			print STDERR "10. línia $.: $linia - morf $gram_cat, morf $gram_fra\n";
			next;
		}

		$primer = 0;
		$n++;
	}

}
