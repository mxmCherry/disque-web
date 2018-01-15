.PHONY: default
default:
	docker-compose up

.PHONY: docker-publish
docker-publish:
	docker build -t disque-web:latest .
	docker tag disque-web:latest mxmcherry/disque-web:latest
	docker push mxmcherry/disque-web:latest

dist: public/dist/bootstrap.css public/dist/vue.js public/dist/vue-router.js

public/dist/bootstrap.css:
	@mkdir -p $(dir $@)
	wget https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.3/css/bootstrap.min.css -O $@

public/dist/vue.js:
	@mkdir -p $(dir $@)
	wget https://cdn.jsdelivr.net/npm/vue@2.5.13 -O $@

public/dist/vue-router.js:
	@mkdir -p $(dir $@)
	wget https://unpkg.com/vue-router@3.0.1/dist/vue-router.js -O $@
