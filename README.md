# Jamie - JAM Session Management App

JAM is a Phoenix LiveView application for managing jam sessions with features like:
- User authentication (passwordless magic links + optional password)
- Jam series and session management
- Registration and waitlist system
- Email notifications via Swoosh
- Background jobs with Oban
- Future: Telegram bot integration

## Tech Stack

- **Elixir** ~> 1.15 / **Phoenix** 1.8.1
- **PostgreSQL** with Ecto 3.13
- **Phoenix LiveView** 1.1.0
- **Tailwind CSS** + **DaisyUI** + **Heroicons**
- **Oban** 2.19 (Background Jobs)
- **Swoosh** 1.16 (Email)
- **Req** 0.5 (HTTP Client)

## Setup

### Prerequisites

- Elixir 1.15+
- PostgreSQL 14+
- Node.js (for assets)

### Installation

1. Install dependencies:
   ```bash
   mix setup
   ```

2. Create and migrate database:
   ```bash
   mix ecto.create && mix ecto.migrate
   ```

3. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

4. Visit [`localhost:4000`](http://localhost:4000)

## Development

### Database

- Create: `mix ecto.create`
- Migrate: `mix ecto.migrate`
- Reset: `mix ecto.reset`
- Rollback: `mix ecto.rollback`

### Testing

```bash
mix test
```

### Code Quality

```bash
mix format
mix compile --warnings-as-errors
```

## Configuration

### Email (Development)

By default, emails are sent to the local mailbox at `/dev/mailbox`.

### Email (Production)

Set the following environment variables:
- `POSTMARK_API_KEY`: Your Postmark API key

### Background Jobs

Oban is configured with the following queues:
- `default`: 10 workers
- `emails`: 20 workers
- `notifications`: 10 workers

Scheduled jobs:
- Cleanup job: Daily at 8:00 AM
- Reminder job: Every hour

## Project Structure

```
lib/jamie/
├── accounts/          # User management & auth (Phase 2)
├── jams/             # Jam series, sessions, co-organizers (Phase 3)
├── bookings/         # Registrations & waitlist (Phase 4)
├── notifications/    # Email & Telegram (Phase 5)
├── authorization/    # Roles & permissions (Phase 2)
└── workers/          # Oban background jobs (Phase 6)

lib/jamie_web/
├── controllers/
├── live/             # LiveView pages
└── components/       # Reusable components
```

## Documentation

- [Implementation Plan](IMPLEMENTATION_PLAN.md)
- [Specification](specification.md)

## Production Deployment

Ready to run in production? Check the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

Required environment variables:
- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `PHX_HOST`
- `POSTMARK_API_KEY`

## Learn More

* Phoenix: https://www.phoenixframework.org/
* Phoenix Guides: https://hexdocs.pm/phoenix/overview.html
* Elixir Forum: https://elixirforum.com/c/phoenix-forum
