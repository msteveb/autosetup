# This is a convenience Makefile to do a few admin tasks
all:
	@echo "Try 'make reference' or './autosetup --help'"

VERSION := $(shell ./autosetup --version)

dist: clean
	@./autosetup --install=tmp/autosetup-$(VERSION) >/dev/null
	@tar -C tmp -czf autosetup-$(VERSION).tar.gz autosetup-$(VERSION)
	@rm -rf tmp
	@echo Created autosetup-$(VERSION).tar.gz

PAGER ?= less

help:
	./autosetup --help

ref reference:
	./autosetup --reference

html:
	./autosetup --reference=asciidoc | asciidoc -o autosetup-reference.html -

# Both tclsh8.5 and tclsh8.6 are required to run the top level test suite
test:
	@make -C testsuite test subdirtest
	@make -C testsuite autosetup_tclsh=tclsh8.6 test subdirtest
	@make -C testsuite autosetup_tclsh=tclsh8.5 test subdirtest
	@make -C testsuite/testoptions
