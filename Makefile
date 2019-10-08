tag = latest
export tag

build:
	docker build -t debtcollective/fundraising:$(tag) .

push:
	docker push debtcollective/fundraising:$(tag)

pull:
	docker push debtcollective/fundraising:$(tag)
