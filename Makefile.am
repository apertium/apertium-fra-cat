VERSION=1.0.0
LANG1=fr
LANG2=ca
PREFIX1=$(LANG1)-$(LANG2)
PREFIX2=$(LANG2)-$(LANG1)

BASENAME=apertium-$(PREFIX1)

TARGETS_COMMON = $(PREFIX1).automorf.bin $(PREFIX1).autobil.bin $(PREFIX1).autogen.bin \
     $(PREFIX1).autopgen.bin $(PREFIX2).automorf.bin $(PREFIX2).autobil.bin \
     $(PREFIX2).autogen.bin $(PREFIX2).autopgen.bin $(MODES)

TARGETS = $(TARGETS_COMMON) trules-$(PREFIX1).bin trules-$(PREFIX2).bin \
          trules-$(PREFIX1).xml trules-$(PREFIX2).xml

$(PREFIX1).automorf.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $(BASENAME).$(LANG1).dix
	lt-comp lr $(BASENAME).$(LANG1).dix $@

$(PREFIX1).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $(BASENAME).$(PREFIX1).dix
	lt-comp lr $(BASENAME).$(PREFIX1).dix $@

$(PREFIX1).autogen.bin: $(BASENAME).$(LANG2).dix
	apertium-validate-dictionary $(BASENAME).$(LANG2).dix
	lt-comp rl $(BASENAME).$(LANG2).dix $@

$(PREFIX1).autopgen.bin: $(BASENAME).post-$(LANG2).dix
	apertium-validate-dictionary $(BASENAME).post-$(LANG2).dix
	lt-comp lr $(BASENAME).post-$(LANG2).dix $@

$(PREFIX2).automorf.bin: $(BASENAME).$(LANG2).dix
	apertium-validate-dictionary $(BASENAME).$(LANG2).dix
	lt-comp lr $(BASENAME).$(LANG2).dix $@

$(PREFIX2).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $(BASENAME).$(PREFIX1).dix
	lt-comp rl $(BASENAME).$(PREFIX1).dix $@

$(PREFIX2).autogen.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $(BASENAME).$(LANG1).dix
	lt-comp rl $(BASENAME).$(LANG1).dix $@

$(PREFIX2).autopgen.bin: $(BASENAME).post-$(LANG1).dix
	apertium-validate-dictionary $(BASENAME).post-$(LANG1).dix
	lt-comp lr $(BASENAME).post-$(LANG1).dix $@

trules-$(PREFIX1).bin: $(BASENAME).trules-$(PREFIX1).xml
	apertium-validate-transfer $(BASENAME).trules-$(PREFIX1).xml
	apertium-preprocess-transfer $(BASENAME).trules-$(PREFIX1).xml \
	                             trules-$(PREFIX1).bin
	                             
trules-$(PREFIX2).bin: $(BASENAME).trules-$(PREFIX2).xml
	apertium-validate-transfer $(BASENAME).trules-$(PREFIX2).xml
	apertium-preprocess-transfer $(BASENAME).trules-$(PREFIX2).xml \
	                             trules-$(PREFIX2).bin

trules-$(PREFIX1).xml: $(BASENAME).trules-$(PREFIX1).xml
	ln -s $(BASENAME).trules-$(PREFIX1).xml trules-$(PREFIX1).xml

trules-$(PREFIX2).xml: $(BASENAME).trules-$(PREFIX2).xml
	ln -s $(BASENAME).trules-$(PREFIX2).xml trules-$(PREFIX2).xml


EXTRA_DIST=$(BASENAME).$(PREFIX1).dix \
           $(BASENAME).post-$(LANG1).dix $(BASENAME).post-$(LANG2).dix \
           $(BASENAME).$(LANG2).dix $(BASENAME).$(LANG1).tsx \
           $(BASENAME).$(LANG2).tsx $(BASENAME).trules-$(PREFIX1).xml \
           $(BASENAME).trules-$(PREFIX2).xml $(PREFIX1).prob $(PREFIX2).prob \
           buscaPar.xsl principal.xsl $(BASENAME).$(LANG1).metadix modes.xml \
           $(PREFIX1)-supervised.make $(PREFIX1)-unsupervised.make \
           $(PREFIX2)-supervised.make $(PREFIX2)-unsupervised.make \
           $(LANG1)-tagger-data/README $(LANG2)-tagger-data/README
           
apertium-fr-ca.fr.dix: apertium-fr-ca.fr.metadix
	@xsltproc buscaPar.xsl apertium-fr-ca.fr.metadix | uniq > $$gen.xsl
	@xsltproc $$gen.xsl apertium-fr-ca.fr.metadix >$@
	@rm $$gen.xsl
           
apertium_fr_cadir=$(prefix)/share/apertium/apertium-$(PREFIX1)/
apertium_fr_modesdir=$(prefix)/share/apertium/modes/

$(PREFIX1).mode: modes.xml 
	apertium-gen-modes modes.xml

$(PREFIX2).mode: modes.xml 
	apertium-gen-modes modes.xml

modes: modes.xml
	apertium-gen-modes modes.xml

apertium_fr_ca_DATA=$(PREFIX1).automorf.bin $(PREFIX2).automorf.bin \
	$(PREFIX1).autobil.bin $(PREFIX2).autobil.bin \
	$(PREFIX1).autogen.bin $(PREFIX2).autogen.bin \
	$(PREFIX1).autopgen.bin $(PREFIX2).autopgen.bin \
	$(PREFIX1).prob $(PREFIX2).prob trules-$(PREFIX1).xml \
	trules-$(PREFIX2).xml trules-$(PREFIX1).bin \
	trules-$(PREFIX2).bin $(PREFIX1).mode $(PREFIX2).mode

install-data-local:
	apertium-gen-modes modes.xml apertium-$(PREFIX1)
	$(INSTALL_DATA) $(PREFIX1).mode $(apertium_fr_modesdir)
	$(INSTALL_DATA) $(PREFIX2).mode $(apertium_fr_modesdir)
	$(INSTALL_DATA) $(BASENAME).trules-$(PREFIX2).xml $(BASENAME).trules-$(PREFIX1).xml $(apertium_fr_cadir)

CLEANFILES = -rf $(TARGETS) modes
