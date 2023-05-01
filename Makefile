run: docker.dev.run docker.dev.logs

docker.dev.run:
	docker-compose up --build -d

docker.dev.logs:
	docker-compose logs -f

db.setup: db.create db.migrate db.seed

db.create:
	docker-compose run --rm web bundle exec rails db:create

db.migrate:
	docker-compose run --rm web bundle exec rails db:migrate

db.seed:
	docker-compose run --rm web bundle exec rails db:seed

db.rollback:
	docker-compose run --rm web bundle exec rails db:rollback STEP=1

irb:
	docker-compose run --rm web bundle exec rails c

down:
	docker-compose down