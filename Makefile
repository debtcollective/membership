tag = latest
export tag

build:
	docker build -t debtcollective/fundraising:$(tag) .

push:
	docker push debtcollective/fundraising:$(tag)

pull:
	docker pull debtcollective/fundraising:$(tag)

# run rspec supressing rails ruby 2.7 warnings
test:
	env RUBYOPT='-W:no-deprecated -W:no-experimental' bundle exec rspec spec
