tag = latest

build:
	docker build -t debtcollective/fundraising:$(tag) .

push:
	docker push debtcollective/fundraising:$(tag)
