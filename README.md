# README

## Objective

A simple TODO application that supports:
- Add a new task
- Edit existing task
- List all tasks
- Tag a task
- Delete existing task

The endpoints are [JSON:API](http://jsonapi.org/format) compliant. 

## Endpoints Implemented

Authentication
1. Login for user-id and password (from seeds)
POST http://localhost:3000/api/v1/login?username=test-user&password=s3cUr8p@$$w0rD<>
2. Create a new user with username and password
POST http://localhost:3000/api/v1/users?username=test-user&password=s3cUr8p@$$w0rD<>

TODO list functionality
1. Get all tasks for authenticated user
GET http://localhost:3000/api/v1/tasks
2. Create a task for authenticated user
POST http://localhost:3000/api/v1/tasks
3. Update a task for authenticated user
PATCH http://localhost:3000/api/v1/tasks/1
4. Delete a task for authenticated user
DELETE http://localhost:3000/api/v1/tasks/2
4. Get all tags for authenticated user
GET http://localhost:3000/api/v1/tags
5. Create a tag for authenticated user
POST http://localhost:3000/api/v1/tags
6. Update a tag for authenticated user
PATCH http://localhost:3000/api/v1/tags/1

## How to run

1. Add an JWT_KEY ENV var in the `.env` file
2. Run `rails db:create`
3. Run `rails db:migrate`
4. Run `rails db:seed`
5. Start the Rails server `rails s -p 3000`
6. Start firing off requests to the API! 

## Assumptions / Decisions

1. I used JSON-API resources library for compliance with JSON:API format and ease of development for CRUD operations. The framework handles transactions for CRUD operations:
https://github.com/cerebris/jsonapi-resources/blob/c62f0d679a7e8acf9d55dc1308b6390004039c56/lib/jsonapi/acts_as_resource_controller.rb#L123-L137
https://github.com/cerebris/jsonapi-resources/blob/35d34ce1f9529d4e0e4cdf2b7b6f9176b61578b6/lib/jsonapi/request_parser.rb#L38-L45
2. I used PostgreSQL as datastore due to better out of the box handling of UUIDs for Rails 6.0.
3. I assumed tags belong to a single user to allow updating their names.  

## Next steps

1. Add rate limiting per IP and per user
2. Consider gem alternatives for versioning for more elegant handling of routes per version and different types of versioning (ie. Header instead of URL)