SHELL		= /bin/sh
PROJECT		= cpss
SQL			= $(PROJECT).sql

.PHONY: deploy dump-db

# All remote commands are failing b/c of $TERM undefined (ssh error).
# setterm: $TERM is not defined.

# ssh chomsky 'cd /var/www/public/$(PROJECT) && pkill $(PROJECT) && ./$(PROJECT)' # Restart server!
deploy:
	cd server && make deploy
	cd client && make deploy

# ssh chomsky 'cd /var/www && mysql -u ******** -p $(PROJECT) < $(SQL) && rm -f $(SQL)'
dump-db:
	cd server/sql/tables && sh reset_db.sh
	mysqldump -u ******** -p $(PROJECT) >| $(SQL)
	rsync -avze ssh --progress $(SQL) chomsky:/var/www/
	rm -f $(SQL)

