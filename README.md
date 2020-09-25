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
```
{"data":
	{	"type":"tasks",
		"attributes":{
			"title":"Do Homework"
		}
	}
}
```

3. Get a single task for authenticated user
GET http://localhost:3000/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82
4. Update a task for authenticated user
PATCH http://localhost:3000/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82
```
{"data":
 	{	"type":"tasks",
 		"id":"12c8490d-762d-4e0f-a858-ec2d10104a82",
 		
 		"attributes":{
 			"title":"Updated Task Title",
 			"tags": ["Home", "Tomorrow"]
 		}
 	}
 }
```
5. Delete a task for authenticated user
DELETE http://localhost:3000/api/v1/tasks/12c8490d-762d-4e0f-a858-ec2d10104a82
6. Get all tags for authenticated user
GET http://localhost:3000/api/v1/tags
7. Create a tag for authenticated user
POST http://localhost:3000/api/v1/tags
```
{"data":
	{	"type":"tags",
		"attributes":{
			"name":"Someday"
		}
	}
}
```
8. Update a tag for authenticated user
PATCH http://localhost:3000/api/v1/tags/12c8490d-762d-4e0f-a858-ec2d10104a82
```
{"data":
	{	"type":"tags",
 		"id":"12c8490d-762d-4e0f-a858-ec2d10104a82",
		"attributes":{
			"name":"Updated Tag Name"
		}
	}
}
```
9. Delete a tag for authenticated user
DELETE http://localhost:3000/api/v1/tags/12c8490d-762d-4e0f-a858-ec2d10104a82

## How to run

You need ruby version 2.5.5 and Rails 6.0.

* Using rbenv install the needed ruby version: `rbenv install 2.5.5`
* Install gems: `bundle install`
* Add a JWT_KEY ENV var in the `.env` file
* Run `rails db:create`
* Run `rails db:migrate`
* Run `rails db:seed`
* Start the Rails server `rails s -p 3000`
* Create a user: `localhost:3000/api/v1/users?username=testuser&password=p@ssword` to get a bearer token
* Using the bearer token start firing off requests to the API!

## Assumptions / Decisions

1. I used [JSON:API Resources](https://jsonapi-resources.com/) library for compliance with the JSON:API format and ease of development for CRUD operations. 
The framework handles transactions for CRUD operations:
https://github.com/cerebris/jsonapi-resources/blob/c62f0d679a7e8acf9d55dc1308b6390004039c56/lib/jsonapi/acts_as_resource_controller.rb#L123-L137
https://github.com/cerebris/jsonapi-resources/blob/35d34ce1f9529d4e0e4cdf2b7b6f9176b61578b6/lib/jsonapi/request_parser.rb#L38-L45
2. I used PostgreSQL as a datastore due to better out of the box handling of UUIDs for Rails 6.0.
3. I assumed tags belong to a single user to allow updating their names.  

## Next steps

* Add some framework for error capturing for monitoring and visibility (ie. Sentry)
* Add rate limiting per IP and per user
* Consider gem alternatives for versioning for more elegant handling of routes and controllers for different versions. Potentially consider different ways of versioning (ie. Header instead of URL)
* Allow filtering all tasks that have a specific tag