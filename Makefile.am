###############################################################################
## Makefile for French--Catalan
###############################################################################

LANG1=fra
LANG2=cat
PREFIX1=$(LANG1)-$(LANG2)
PREFIX2=$(LANG2)-$(LANG1)

BASENAME=apertium-$(PREFIX1)

TARGETS_COMMON =		\
	$(PREFIX1).automorf.bin	\
	$(PREFIX1).prob		\
	$(PREFIX1).rlx.bin	\
	$(PREFIX1).autobil.bin	\
	$(PREFIX1).autolex.bin	\
	$(PREFIX1).autogen.bin	\
	$(PREFIX1).autosep.bin	\
	$(PREFIX1).autopgen.bin	\
	$(PREFIX1).prefs.rlx.bin	\
	$(PREFIX1).pre2017_prefs.rlx.bin \
	$(PREFIX1).t1x.bin	\
	$(PREFIX1).t4x.bin	\
	$(PREFIX2).automorf.bin	\
	$(PREFIX2).prob		\
	$(PREFIX2).rlx.bin	\
	$(PREFIX2).autobil.bin	\
	$(PREFIX2).autolex.bin	\
	$(PREFIX2).autogen.bin	\
	$(PREFIX2).autosep.bin	\
	$(PREFIX2).autopgen.bin	\
	$(PREFIX2).t1x.bin	\
	$(PREFIX2).t4x.bin	\
	prefs/$(PREFIX1).xml

#	$(PREFIX1).t2x.bin	\
#	$(PREFIX1).t3x.bin	\
#	$(PREFIX2).t2x.bin	\
#	$(PREFIX2).t3x.bin

# This include defines goals for install-modes, .deps/.d and .mode files:
@ap_include@

###############################################################################
## Monolingual transducers
###############################################################################

# -------------------
# French analysis:
# -------------------

$(PREFIX1).automorf.bin: $(AP_SRC1)/$(LANG1).automorf.bin $(PREFIX1).autobil.bin
	lt-trim $^ $@

# -------------------
# French generation:
# ---------------------


$(PREFIX2).autogen.bin: $(AP_SRC1)/$(LANG1).autogen.bin
	cp $< $@

# -------------------
# Catalan analysis:
# -------------------

$(PREFIX2).automorf.bin: $(AP_SRC2)/$(LANG2).automorf.bin $(PREFIX2).autobil.bin
	lt-trim $^ $@

# -------------------
# Catalan generation:
# ---------------------


$(PREFIX1).autogen.bin: $(AP_SRC2)/$(LANG2).autogen.bin
	cp $< $@

###############################################################################
## Multiwords
###############################################################################

$(PREFIX1).autosep.bin: $(BASENAME).$(PREFIX1).l1x
	lsx-comp lr $< $@
$(PREFIX2).autosep.bin: $(BASENAME).$(PREFIX2).l2x
	lsx-comp lr $< $@

###############################################################################
## Tagger models
###############################################################################

$(PREFIX1).prob: $(AP_SRC1)/$(LANG1).prob
	cp $< $@

$(PREFIX2).prob: $(AP_SRC2)/$(LANG2).prob
	cp $< $@

###############################################################################
## Disambiguation rules
###############################################################################

$(PREFIX1).rlx.bin: $(AP_SRC1)/apertium-$(LANG1).$(LANG1).rlx
	cg-comp $< $@

$(PREFIX2).rlx.bin: $(AP_SRC2)/apertium-$(LANG2).$(LANG2).rlx
	cg-comp $< $@

###############################################################################
## Bilingual dictionaries
###############################################################################

$(PREFIX1).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX2).autobil.bin: $(BASENAME).$(PREFIX1).dix
#	apertium-validate-dictionary $<
	lt-comp rl $< $@

###############################################################################
## Lexical selection rules
###############################################################################

$(PREFIX1).autolex.bin: $(BASENAME).$(PREFIX1).lrx
	apertium-validate-lrx $<
	lrx-comp $< $@

$(PREFIX2).autolex.bin: $(BASENAME).$(PREFIX2).lrx
	apertium-validate-lrx $<
	lrx-comp $< $@

###############################################################################
## Structural transfer rules
###############################################################################

$(PREFIX1).t1x.bin: $(BASENAME).$(PREFIX1).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

#$(PREFIX1).t2x.bin: $(BASENAME).$(PREFIX1).t2x
#	apertium-validate-interchunk $<
#	apertium-preprocess-transfer $< $@
#
#$(PREFIX1).t3x.bin: $(BASENAME).$(PREFIX1).t3x
#	apertium-validate-postchunk $<
#	apertium-preprocess-transfer $< $@

$(PREFIX1).t4x.bin: $(BASENAME).$(PREFIX1).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@



$(PREFIX2).t1x.bin: $(BASENAME).$(PREFIX2).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

#$(PREFIX2).t2x.bin: $(BASENAME).$(PREFIX2).t2x
#	apertium-validate-interchunk $<
#	apertium-preprocess-transfer $< $@
#
#$(PREFIX2).t3x.bin: $(BASENAME).$(PREFIX2).t3x
#	apertium-validate-postchunk $<
#	apertium-preprocess-transfer $< $@

$(PREFIX2).t4x.bin: $(BASENAME).$(PREFIX2).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@


###############################################################################
## Postgeneration dictionaries
###############################################################################

$(PREFIX1).autopgen.bin: $(AP_SRC2)/$(LANG2).autopgen.bin
	cp $< $@

$(PREFIX2).autopgen.bin: $(AP_SRC1)/$(LANG1).autopgen.bin
	cp $< $@

###############################################################################
## Variant preferences
###############################################################################

$(PREFIX1).pre2017_prefs.rlx.bin: $(AP_SRC2)/$(LANG2).pre2017_prefs.rlx.bin
	cp $< $@

$(PREFIX1).prefs.rlx.bin: $(AP_SRC2)/$(LANG2).prefs.rlx.bin
	cp $< $@

###############################################################################
## Preferences
###############################################################################

prefs/$(LANG2).preferences.xml: $(AP_SRC2)/$(LANG2).preferences.xml
	$(MKDIR_P) prefs
	cp $< $@

define mergePrefs =
$(MKDIR_P) prefs
echo '<preferences>' >$@.tmp
for f in $^; do xmllint --xpath '/preferences/preference' "$$f"; done >>$@.tmp
echo '</preferences>' >>$@.tmp
mv $@.tmp $@
endef

# uncomment when we have bilingual preferences
# prefs/$(PREFIX1).xml: $(LANG2).preferences.xml $(PREFIX1).preferences.xml
prefs/$(PREFIX1).xml: prefs/$(LANG2).preferences.xml 
		$(mergePrefs)

###############################################################################
## Distribution
###############################################################################

EXTRA_DIST=					\
		$(BASENAME).$(PREFIX1).lrx	\
		$(BASENAME).$(PREFIX2).lrx	\
		$(BASENAME).$(PREFIX1).dix	\
		$(BASENAME).$(PREFIX1).t1x	\
		$(BASENAME).$(PREFIX1).t4x	\
		$(BASENAME).$(PREFIX2).t1x	\
		$(BASENAME).$(PREFIX2).t4x	\
		$(BASENAME).$(PREFIX1).l1x	\
		$(BASENAME).$(PREFIX2).l2x	\
		modes.xml	\
		$(PREFIX1).preferences.xml

#		$(BASENAME).$(PREFIX1).t2x	\
#		$(BASENAME).$(PREFIX1).t3x	\
#		$(BASENAME).$(PREFIX2).t2x	\
#		$(BASENAME).$(PREFIX2).t3x

###############################################################################
## Installation
###############################################################################

apertium_fra_catdir=$(prefix)/share/apertium/$(BASENAME)/

# Files which should be installed to $(prefix)/share/apertium/$(BASENAME)/:
apertium_fra_cat_DATA=	\
	$(TARGETS_COMMON)				\
	$(BASENAME).$(PREFIX1).t1x			\
	$(BASENAME).$(PREFIX2).t1x			\
	$(BASENAME).$(PREFIX1).t4x			\
	$(BASENAME).$(PREFIX2).t4x

#	$(BASENAME).$(PREFIX2).t2x			\
#	$(BASENAME).$(PREFIX2).t3x
#	$(BASENAME).$(PREFIX1).t2x			\
#	$(BASENAME).$(PREFIX1).t3x

# All modes are created by the same goal, listing several will just give problems with make -j2
noinst_DATA=modes/$(PREFIX1).mode

install-data-local: install-modes

###############################################################################
## Cleanup
###############################################################################

CLEANFILES = $(TARGETS_COMMON)
clean-local:
	-rm -rf .deps modes

###############################################################################
## Test
###############################################################################

test: all
	apertium-regtest test
