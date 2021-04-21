tag = latest
export tag

build:
	docker build -t debtcollective/membership:$(tag) .

push:
	docker push debtcollective/membership:$(tag)

pull:
	docker pull debtcollective/membership:$(tag)
