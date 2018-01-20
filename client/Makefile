SHELL 		= /bin/sh
CC      	= elm make

NATIVE  	= Native.js
SNIPPET		= "const app = Elm.Main.fullscreen({ env: '{{BUILD}}' })"
PORT		= 1975
TARGET  	= elm.js
WEBSERVER	= elm reactor

.PHONY: clean deploy dev hooks prod production serve

define compile
	$(CC) src/Main.elm --output=$(TARGET) \
		$(if $1,--debug)
endef

define concat
	@echo $(if $1,$(subst {{BUILD}},dev,$(SNIPPET)), $(subst {{BUILD}},production,$(SNIPPET))) | \
		cat - $(NATIVE) >> $(TARGET)
endef

$(TARGET):
	$(call compile, dev)

clean:
	rm -f $(TARGET)

deploy: production
	rsync -avze ssh --progress --exclude-from='exclude-from.txt' . chomsky:/var/www/public/cpss

dev: clean $(TARGET) $(NATIVE)
	$(call concat, dev)

hooks:
	cd .git/hooks && \
	echo make dev >> post-merge && \
		chmod 755 post-merge

prod: production

production: clean $(NATIVE)
	$(call compile)
	$(call concat)

serve: $(TARGET)
	$(WEBSERVER) -p $(PORT)

