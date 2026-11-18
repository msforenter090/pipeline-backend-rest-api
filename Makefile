# Requirements export with StrictDoc.
#   make setup    create env/ and install the packages from requirements.txt
#   make tests    build/generated/behavior-tests.sdoc   scenarios from features/
#   make html     build/strictdoc/html/   browsable site with trace pages
#   make json     build/strictdoc/json/   machine-readable export
#   make export   both
#   make clean    delete build/strictdoc/ and build/generated/
#
# The export targets regenerate the behavior tests first, so the report
# always matches the .feature files.

PYTHON    ?= python3
ENV       ?= env
STRICTDOC ?= $(ENV)/bin/strictdoc
OUT       ?= build/strictdoc
GEN       := build/generated/behavior-tests.sdoc

REQ_FILES     := $(shell find requirements -name '*.sdoc' -o -name '*.sgra')
FEATURE_FILES := $(shell find features -name '*.feature')

.PHONY: setup tests export html json clean
export: $(GEN)
	$(STRICTDOC) export . --formats html,json --output-dir $(OUT)

html json: $(GEN)
	$(STRICTDOC) export . --formats $@ --output-dir $(OUT)

tests: $(GEN)

$(GEN): tools/feature_to_sdoc.py $(FEATURE_FILES) $(REQ_FILES)
	$(ENV)/bin/python tools/feature_to_sdoc.py --requirements requirements --out $@ features

setup:
	test -x $(ENV)/bin/python || $(PYTHON) -m venv $(ENV)
	$(ENV)/bin/pip install --upgrade pip
	$(ENV)/bin/pip install -r requirements.txt

clean:
	rm -rf $(OUT) build/generated
