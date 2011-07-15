VERSION=1.0.2
LANG1=fr
LANG2=ca
PREFIX1=$(LANG1)-$(LANG2)
PREFIX2=$(LANG2)-$(LANG1)

BASENAME=apertium-$(PREFIX1)

VAR1=std
VAR2=val-
PREFVAR1=#dejar en blanco
PREFVAR2=val-

TARGETS_COMMON = $(PREFIX1).automorf.bin $(PREFIX1).autobil.bin $(PREFIX1).autogen.bin \
     $(PREFIX1).autopgen.bin $(PREFIX2).automorf.bin $(PREFIX2).autobil.bin \
     $(PREFVAR1)$(PREFIX1).autogen.bin \
     $(PREFIX2).autopgen.bin $(MODES)

TARGETS = $(TARGETS_COMMON) $(PREFIX1).t1x.bin $(PREFIX2).t1x.bin 

$(PREFIX1).automorf.bin: $(BASENAME).$(LANG1).dix $(BASENAME).$(LANG1).acx
	apertium-validate-acx $(BASENAME).$(LANG1).acx
	apertium-validate-dictionary $(BASENAME).$(LANG1).dix
	lt-comp lr $(BASENAME).$(LANG1).dix $@ $(BASENAME).$(LANG1).acx

$(PREFIX1).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $(BASENAME).$(PREFIX1).dix
	lt-comp lr $(BASENAME).$(PREFIX1).dix $@

$(PREFVAR1)$(LANG2).dix: $(BASENAME).$(LANG2).dix
	xsltproc --stringparam lang cat --stringparam side left filter.xsl $< > $@

$(PREFVAR1)$(PREFIX1).autogen.bin: $(PREFVAR1)$(LANG2).dix
	apertium-validate-dictionary $(PREFVAR1)$(LANG2).dix
	lt-comp rl $(PREFVAR1)$(LANG2).dix $@

#$(PREFVAR2)$(LANG2).dix: $(BASENAME).$(LANG2).dix
#	xsltproc --stringparam lang val --stringparam side left filter.xsl $< > $@
#
#$(PREFVAR2)$(PREFIX1).autogen.bin: $(PREFVAR2)$(LANG2).dix
#	apertium-validate-dictionary $(PREFVAR2)$(LANG2).dix
#	lt-comp rl $(PREFVAR2)$(LANG2).dix $@

$(PREFIX1).autopgen.bin: $(BASENAME).post-$(LANG2).dix
	apertium-validate-dictionary $(BASENAME).post-$(LANG2).dix
	lt-comp lr $(BASENAME).post-$(LANG2).dix $@

$(PREFVAR1)$(PREFIX2).automorf.bin: $(PREFVAR1)$(LANG2).dix $(BASENAME).$(LANG2).acx
	apertium-validate-acx $(BASENAME).$(LANG2).acx
	apertium-validate-dictionary $(PREFVAR1)$(LANG2).dix
	lt-comp lr $(PREFVAR1)$(LANG2).dix $@ $(BASENAME).$(LANG2).acx

#$(PREFVAR2)$(PREFIX2).automorf.bin: $(PREFVAR2)$(LANG2).dix
#	apertium-validate-acx $(BASENAME).$(LANG2).acx
#	apertium-validate-dictionary $(PREFVAR2)$(LANG2).dix
#	lt-comp lr $(PREFVAR2)$(LANG2).dix $@ $(BASENAME).$(LANG2).acx
#
$(PREFIX2).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $(BASENAME).$(PREFIX1).dix
	lt-comp rl $(BASENAME).$(PREFIX1).dix $@

$(PREFIX2).autogen.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $(BASENAME).$(LANG1).dix
	lt-comp rl $(BASENAME).$(LANG1).dix $@

$(PREFIX2).autopgen.bin: $(BASENAME).post-$(LANG1).dix
	apertium-validate-dictionary $(BASENAME).post-$(LANG1).dix
	lt-comp lr $(BASENAME).post-$(LANG1).dix $@

$(PREFIX1).t1x.bin: $(BASENAME).$(PREFIX1).t1x
	apertium-validate-transfer $(BASENAME).$(PREFIX1).t1x
	apertium-preprocess-transfer $(BASENAME).$(PREFIX1).t1x \
	                             $(PREFIX1).t1x.bin
                             
$(PREFIX1).t1x-new.bin: $(BASENAME).$(PREFIX1).t1x-new
	apertium-validate-transfer $(BASENAME).$(PREFIX1).t1x-new
	apertium-preprocess-transfer $(BASENAME).$(PREFIX1).t1x-new \
	                             $(PREFIX1).t1x-new.bin

$(PREFIX1).t2x.bin: $(BASENAME).$(PREFIX1).t2x
	apertium-validate-transfer $(BASENAME).$(PREFIX1).t2x
	apertium-preprocess-transfer $(BASENAME).$(PREFIX1).t2x \
	                             $(PREFIX1).t2x.bin
                             
$(PREFIX1).t3x.bin: $(BASENAME).$(PREFIX1).t3x
	apertium-validate-transfer $(BASENAME).$(PREFIX1).t3x
	apertium-preprocess-transfer $(BASENAME).$(PREFIX1).t3x \
	                             $(PREFIX1).t3x.bin
                             
$(PREFIX2).t1x.bin: $(BASENAME).$(PREFIX2).t1x
	apertium-validate-transfer $(BASENAME).$(PREFIX2).t1x
	apertium-preprocess-transfer $(BASENAME).$(PREFIX2).t1x \
	                             $(PREFIX2).t1x.bin


EXTRA_DIST=$(BASENAME).$(PREFIX1).dix \
           $(BASENAME).post-$(LANG1).dix $(BASENAME).post-$(LANG2).dix \
           $(BASENAME).$(LANG2).dix $(BASENAME).$(LANG1).tsx \
           $(BASENAME).$(LANG2).tsx $(BASENAME).$(PREFIX1).t1x \
           $(BASENAME).$(PREFIX2).t1x $(PREFIX1).prob $(PREFIX2).prob \
           buscaPar.xsl principal.xsl $(BASENAME).$(LANG1).metadix modes.xml \
           $(PREFIX1)-supervised.make $(PREFIX1)-unsupervised.make \
           $(PREFIX2)-supervised.make $(PREFIX2)-unsupervised.make \
           $(LANG1)-tagger-data/README $(LANG2)-tagger-data/README \
           $(BASENAME).$(LANG1).acx $(BASENAME).$(LANG2).acx \
           filter.xsl
           
apertium-fr-ca.fr.dix: apertium-fr-ca.fr.metadix
	@xsltproc buscaPar.xsl apertium-fr-ca.fr.metadix | uniq > $$gen.xsl
	@xsltproc $$gen.xsl apertium-fr-ca.fr.metadix >$@
	@rm $$gen.xsl
           
apertium_fr_cadir=$(prefix)/share/apertium/apertium-$(PREFIX1)/
apertium_fr_modesdir=$(prefix)/share/apertium/modes/

$(PREFIX1).mode: modes.xml 
	apertium-gen-modes modes.xml
	cp *.mode ./modes/

$(PREFIX2).mode: modes.xml 
	apertium-gen-modes modes.xml
	cp *.mode ./modes/

apertium_fr_ca_DATA=$(PREFIX1).automorf.bin $(PREFIX2).automorf.bin \
	$(PREFIX1).autobil.bin $(PREFIX2).autobil.bin \
	$(PREFIX1).autogen.bin $(PREFIX2).autogen.bin \
	$(PREFIX1).autopgen.bin $(PREFIX2).autopgen.bin \
	$(PREFIX1).prob $(PREFIX2).prob  \
	$(PREFIX1).t1x.bin \
	$(PREFIX2).t1x.bin $(PREFIX1).mode $(PREFIX2).mode

install-data-local:
	apertium-gen-modes modes.xml apertium-$(PREFIX1)
	$(INSTALL_DATA) $(PREFIX1).mode $(apertium_fr_modesdir)
	$(INSTALL_DATA) $(PREFIX2).mode $(apertium_fr_modesdir)
	$(INSTALL_DATA) $(BASENAME).$(PREFIX2).t1x $(BASENAME).$(PREFIX1).t1x $(apertium_fr_cadir)

CLEANFILES = -rf $(TARGETS) modes $(BASENAME).$(LANG1).dix *.mode
