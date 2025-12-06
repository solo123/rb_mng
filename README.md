# Mng Project

Ruby-based backend application built with **Roda**, **Falcon**, and **Mongoid**. It serves as an API service with WebSocket support and asynchronous processing capabilities.

## 🛠 Tech Stack

- **Language**: Ruby
- **Web Framework**: [Roda](http://roda.jeremyevans.net/)
- **Web Server**: [Falcon](https://github.com/socketry/falcon)
- **Database ODM**: [Mongoid](https://mongoid.github.io/old/en/mongoid/index.html) (MongoDB)
- **Concurrency**: `async`, `async-redis`

## 📂 Project Structure

The project follows a modular structure:

```
.
├── app/                # Main application logic
│   ├── app.rb          # Entry point for routes (Mng::Route::App)
│   ├── helper/         # Route helpers
│   └── middleware/     # Rack middleware
├── config/             # Configuration files
│   ├── app_conf.yml    # Application settings (DB, Redis, etc.)
│   └── deploy.rb       # Deployment scripts
├── init/               # Initialization scripts
│   ├── env.rb          # Environment setup (loads config)
│   └── re_define.rb    # Monkey patches or extensions
├── lib/                # Shared libraries and utilities
│   ├── mongodb.rb      # MongoDB connection setup
│   └── my_db_tools.rb  # Database helper modules
├── model/              # Mongoid models (Data Layer)
│   ├── my_log.rb       # Example model
│   └── query_trade.rb  # Trade query model
├── service_lib/        # External services or submodules
├── config.ru           # Rack configuration file
├── Gemfile             # Ruby dependencies
└── Rakefile            # Rake tasks
```

## 🚀 Getting Started

### Prerequisites

- Ruby (check `.ruby-version` if available)
- MongoDB
- Redis

### Installation

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Configure the application:
   - Copy or create `config/app_conf.yml` based on your environment.
   - Ensure MongoDB and Redis are running.

### Running the Server

Start the server using Falcon (runs on port 3000 by default):

```bash
bundle exec falcon serve
```

Or using Rackup (if supported):

```bash
bundle exec rackup
```

## 🧪 Testing & Development

### Running Tests

The project uses `minitest`. Run tests via Rake:

```bash
bundle exec rake test
```

### Database Seeding

There are Rake tasks to manage seed data (useful for testing/development):

```bash
# Clean and re-seed data
bundle exec rake db:re_seed

# Clean data only
bundle exec rake db:clean

# Seed data only
bundle exec rake db:seed
```

## 📖 API Overview

The application defines routes in `app/app.rb`.

- **Root**: `/` -> Returns "Home here"
- **Ping**: `/ping` -> Returns "pong"
- **DB Access**: `/db/show/:db/:dbid` (Dynamic DB query)
- **V1 API**: `/v1`
  - `/v1/test/sleep/:seconds`
  - `/v1/test/ping`
  - `/v1/test/demo.dat`
  - `/v1/test/task_10` (Async task demo)

## 🧩 Key Components

### Application (`app/app.rb`)
The `Mng::Route::App` class inherits from `Roda`. It handles routing, plugins (JSON, Streaming, WebSockets), and error handling.

### Models (`model/`)
Models use `Mongoid` for MongoDB interaction. Example: `Ns::MyLog`.

### Initialization (`init/`)
`init/env.rb` loads the configuration from `config/app_conf.yml` based on `APP_ENV` (defaults to `development`).

### Async Tasks
The app uses `Async::Container` for background tasks (seen in `/v1/test/task_10`).

### Server Config (`falcon.rb`)
Configured to use `Async::Container::Threaded` and binds to `http://localhost:3000`.
