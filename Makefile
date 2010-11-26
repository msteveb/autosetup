# This is a convenience Makefile to do a few admin tasks
all:
	@echo "Try 'make manual' or './autosetup --help'"

VERSION := $(shell ./autosetup --version)

dist: clean
	@./autosetup --install=tmp/autosetup-$(VERSION) >/dev/null
	@tar -C tmp -czf autosetup-$(VERSION).tar.gz autosetup-$(VERSION)
	@rm -rf tmp
	@echo Created autosetup-$(VERSION).tar.gz

PAGER ?= less

manual:
	./autosetup --manual | $(PAGER)

html:
	./autosetup --manual=asciidoc | asciidoc -o autosetup.html -
