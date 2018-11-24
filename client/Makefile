SHELL 		= /bin/sh
CC      	= elm make

NATIVE  	= ./src/Native/Session.js
SNIPPET		= "const getFormattedDate = () => { const date = new Date(); let day = date.getDate(); let month = date.getMonth() + 1; let year = date.getFullYear().toString().slice(2)*1; if (day.toString().length === 1) { day = '0' + day; } if (month.toString().length === 1) { month = '0' + month; } return month + '/' + day + '/' + year; }; const app = Elm.Main.fullscreen({ env: '{{BUILD}}', today: getFormattedDate() })"
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
	echo "Deploying to cpss..."
	@rsync -avze ssh --progress --exclude-from="exclude-from.rsync" . cpss:/var/www/html

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

