CWD := $(shell pwd)
DESTDIR := $(HOME)/.minetest
MODDIR := $(DESTDIR)/mods

$(MODDIR):
	mkdir -p $(MODDIR)

.PHONY: linkmods
linkmods: $(MODDIR)
	for mod in $$(ls ./mods); do ln -sf $(CWD)/mods/$$mod $(MODDIR)/; done

.PHONY: link
link: linkmods

.PHONY: test
test:
	@for test_file in $$(ls ./tests/*.lua); do lua $$test_file; done
