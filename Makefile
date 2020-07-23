tag = latest
export tag

build:
	docker build -t debtcollective/membership:$(tag) .

push:
	docker push debtcollective/membership:$(tag)

pull:
	docker pull debtcollective/membership:$(tag)

# run rspec supressing rails ruby 2.7 warnings
test:
	env RUBYOPT='-W:no-deprecated -W:no-experimental' bundle exec rspec spec
