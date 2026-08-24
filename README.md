# Billetto Event Voting Platform

Ruby on Rails application built as part of the Billetto Rails Engineer Test.

The application:

* Imports public events from the Billetto API.
* Uses Clerk for authentication.
* Allows authenticated users to like/dislike events.
* Uses Rails Event Store (RES) for voting events and Pub/Sub.
* Uses a projection for efficient vote-count reads.
* Runs entirely through Docker.

---

## Requirements

The application was implemented within a **3-day development period**.

### Day 1 — Requirements & Architecture

* Reviewed the requirements and Billetto API.
* Studied Rails Event Store and its Pub/Sub model.
* Designed the application boundaries and voting flow.
* Chose PostgreSQL for relational data and JSON/JSONB support.
* Set up the Rails application and Docker environment.

### Day 2 — Authentication & Core Features

* Integrated Clerk authentication.
* Implemented Billetto API integration and event ingestion.
* Implemented event listing.
* Implemented like/dislike voting.
* Added database constraints to prevent duplicate active votes.
* Integrated Rails Event Store for voting events.

### Day 3 — Projection, Testing & Documentation

* Added `event_vote_counts` projection/read model.
* Added RSpec tests and API mocking.
* Completed Docker setup.
* Added setup and implementation documentation.
* Tested the complete application flow.

---

# Architecture

The application follows a command/service/event-driven approach:

```text
HTTP / Rake Task
      ↓
Command
      ↓
Command Bus
      ↓
Domain Service
      ↓
Database State Change
      ↓
Publish Domain Event
      ↓
Rails Event Store
      ↓
Subscriber / Handler
      ↓
Projection / Read Model
```

### Voting flow

```text
User
 ↓
VotesController
 ↓
Votes::Cast Command
 ↓
Command Bus
 ↓
Votes::Service
 ↓
Create / Update Vote
 ↓
Publish Votes::Casted
 ↓
Rails Event Store
 ↓
Vote Handler
 ↓
event_vote_counts
```

---

# Architectural Decisions

## 1. Billetto events are stored locally

The application does not call the Billetto API on every page request.

Events are imported and stored locally so that:

* The UI is not dependent on Billetto availability.
* Page reads are faster.
* External API calls are isolated to the integration layer.

Events are imported through a Rake task:

```bash
docker compose exec web rails "billetto:import_events[10]"
```

---

## 2. Dedicated Billetto integration layer

Billetto API communication is separated from controllers and models.

```text
Billetto API
     ↓
Billetto Integration
     ↓
Events Service
     ↓
Event model
```

This keeps external API concerns isolated and makes the integration easier to test with WebMock.

---

## 3. Clerk is the authentication provider

Clerk handles:

* Sign up
* Sign in
* Sign out
* Authentication sessions
* User identity

Rails does not manage user passwords.

The Clerk user ID is stored as `votes.user_id` and included in voting events stored in Rails Event Store.

A local `users` table is not required for the current functionality.

---

## 4. Database constraint prevents duplicate voting

The `votes` table has a unique constraint on:

```text
(event_id, user_id)
```

This guarantees that a user can have only one active vote for an event.

A user can change:

```text
Like → Dislike
Dislike → Like
```

by updating the existing vote.

The database constraint also protects against concurrent duplicate requests.

---

## 5. Vote counts use a projection

Likes and dislikes could be calculated directly from the `votes` table:

```text
COUNT(likes)
COUNT(dislikes)
```

However, repeatedly joining and aggregating a potentially large `votes` table becomes increasingly expensive as vote volume grows.

Therefore the application maintains:

```text
event_vote_counts
-----------------
event_id
likes_count
dislikes_count
```

This is a read-optimized projection.

```text
Votes::Casted
      ↓
Vote Handler
      ↓
event_vote_counts
```

The event listing can therefore read precomputed counts instead of recalculating the complete vote history.

---

## 6. Rails Event Store for domain events

Rails Event Store is used to record voting events such as:

```text
Votes::Casted
```

The current vote state is stored in the `votes` table, while RES provides the event history and Pub/Sub mechanism.

This keeps:

* Current state
* Event history
* Read projections

as separate concerns.

---

# Database Design

## Events

```text
events
- id
- billetto_event_id  UNIQUE, NOT NULL
- title              NOT NULL
- description
- category
- image_url
- event_url          NOT NULL
- address
- start_date         NOT NULL
- created_at
- updated_at
```

`billetto_event_id` is unique to prevent duplicate imports.

## Votes

```text
votes
- id
- event_id
- user_id
- vote_type
- created_at
- updated_at
```

Unique constraint:

```text
UNIQUE(event_id, user_id)
```

## Event Vote Counts

```text
event_vote_counts
- id
- event_id
- likes_count
- dislikes_count
- created_at
- updated_at
```

`event_id` is unique so each event has exactly one aggregate row.

---

# Technology Stack

| Technology              | Purpose                   |
| ----------------------- | ------------------------- |
| Ruby on Rails 8.1       | Application framework     |
| PostgreSQL              | Primary database          |
| Rails Event Store       | Domain events and Pub/Sub |
| Clerk                   | Authentication            |
| Docker / Docker Compose | Development environment   |
| RSpec                   | Automated testing         |
| Factory Bot             | Test data                 |
| WebMock                 | External API mocking      |

---

# Local Setup

The application is intended to run through Docker, so Ruby, Rails, PostgreSQL and gem dependencies do not need to be installed directly on the host machine.

## 1. Prerequisites

Install Docker Desktop:

https://www.docker.com/products/docker-desktop/

Verify:

```bash
docker --version
docker compose version
```

---

## 2. Clone the Repository

```bash
git clone <repository-url>
cd billetto_event_voting_platofrm
```

---

## 3. Configure Credentials

The assignment credentials are currently provided through Docker Compose configuration.

For production, credentials should instead be stored using environment variables, Rails encrypted credentials, or a secret-management service.

Required credentials:

```text
Billetto API credentials
Clerk Publishable Key
Clerk Secret Key
```

Do not commit real production secrets to the repository.

---

## 4. Build the Application

```bash
docker compose build
```

---

## 5. Start the Containers

```bash
docker compose up -d
```

Check the running containers:

```bash
docker compose ps
```

---

## 6. Create the Database

```bash
docker compose exec web rails db:create
```

---

## 7. Run Migrations

```bash
docker compose exec web rails db:migrate
```

Check migration status:

```bash
docker compose exec web rails db:migrate:status
```

---

## 8. Open the Application

```text
http://localhost:3000
```

---

# Import Billetto Events

Import 10 events:

```bash
docker compose exec web rails "billetto:import_events[10]"
```

Import 100 events:

```bash
docker compose exec web rails "billetto:import_events[100]"
```

The import process:

```text
Rake Task
   ↓
Command Bus
   ↓
Events::Import
   ↓
Billetto API
   ↓
Persist / Update Events
   ↓
Publish Events::Imported
```

---

# Voting

Only authenticated Clerk users can vote.

Supported actions:

```text
Like
Dislike
```

When a user votes:

```text
User
 ↓
VotesController
 ↓
Authenticate with Clerk
 ↓
Votes::Cast
 ↓
Create / Update votes record
 ↓
Publish Votes::Casted
 ↓
Rails Event Store
 ↓
Vote Handler
 ↓
Update event_vote_counts
```

The Clerk user ID is included in the voting event for traceability.

Example:

```json
{
  "event_id": 101,
  "user_id": "user_xxxxx",
  "vote_type": "like"
}
```

---

# Testing

Run the complete test suite:

```bash
docker compose exec web bundle exec rspec
```

Run event model specs:

```bash
docker compose exec web bundle exec rspec spec/models/event_spec.rb
```

Run controller specs:

```bash
docker compose exec web bundle exec rspec spec/controllers/events_controller_spec.rb
```

Run Billetto integration tests:

```bash
docker compose exec web bundle exec rspec spec/integrations/billetto
```

WebMock is used to mock external Billetto API requests.

---

# Rails Console

Open the console:

```bash
docker compose exec web rails console
```

Useful checks:

```ruby
Event.count
Vote.count
EventVoteCount.count
```

Inspect Rails Event Store:

```ruby
ActiveRecord::Base.connection.execute(
  "SELECT * FROM event_store_events"
).to_a
```

---

# Project Structure

```text
app/
├── controllers/
├── models/
├── domain/
│   ├── events/
│   └── votes/
├── handlers/
│   ├── events/
│   └── votes/
├── integrations/
│   └── billetto/
└── services/

lib/
├── command_bus.rb
└── application_subscriptions.rb

spec/
├── models/
├── controllers/
└── integrations/
```

---

# Rails Event Store Subscriptions

Subscriptions are registered through:

```text
ApplicationSubscriptions
```

Example:

```text
Votes::Casted
      ↓
Votes::VoteCompletedHandler
      ↓
event_vote_counts
```

The handler updates the projection whenever a voting event is published.

---

# Assumptions

* Billetto events are periodically imported into the local database.
* A user can have one active vote per event.
* A user can change an existing vote.
* Clerk is the source of truth for authentication and user identity.
* Rails Event Store records domain events and provides Pub/Sub.
* `event_vote_counts` is a read model optimized for event-listing queries.

---

# Key Takeaway

The main design goal was to keep the external integration, business logic, event history, and read models separated:

```text
Billetto API → Events
                    ↓
                 Rails App
                    ↓
             Voting Commands
                    ↓
              Current Vote
                    ↓
            Rails Event Store
                    ↓
                Projection
                    ↓
           Event Vote Counts
```

This provides a simple implementation for the assignment while leaving room to scale individual parts independently.
