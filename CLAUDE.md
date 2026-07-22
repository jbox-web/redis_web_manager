# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`redis_web_manager` is a mountable Rails engine (gem) that provides a web UI to
inspect and manage one or several Redis instances: dashboard (memory/CPU/clients
charts), key browser/editor, clients list, server configuration and info, plus
destructive actions (flushdb/flushall). It supports Rails >= 7.2 and Ruby >= 3.2.

## Commands

Always use the project binstubs (they pin the correct Bundler context).

```bash
bin/rspec                              # run the whole suite
bin/rspec spec/redis_web_manager/data_spec.rb          # single file
bin/rspec spec/redis_web_manager/data_spec.rb:42       # single example (by line)
bin/rubocop                            # lint (rubocop + performance/rake/rspec plugins)
bin/rake                               # default task == spec
```

The suite needs a **running Redis on localhost:6379** (specs hit a real server;
there is no mock). CI starts a `redis` service container for this.

### Testing against multiple Rails versions

`Appraisals` defines gemfiles for Rails 7.2 / 8.0 / 8.1 under `gemfiles/`. To run
the suite against a specific one, set `BUNDLE_GEMFILE` (as CI does):

```bash
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bin/rspec
bin/appraisal install                  # regenerate gemfiles after editing Appraisals
```

## Architecture

**Rails engine.** `lib/redis_web_manager/engine.rb` isolates the namespace and
declares Sprockets asset precompilation (guarded for Rails API mode and
Sprockets < 4). Host apps mount it via
`mount RedisWebManager::Engine => '/redis_web_manager'`.

**Global configuration is module-level state.** `RedisWebManager` uses
`mattr_accessor` for `redises` (Hash of `name => Redis`/`ConnectionPool`),
`lifespan` (dashboard data retention, an `ActiveSupport::Duration`) and
`authenticate` (a proc run in controller context). `RedisWebManager.configure`
validates these via `check_attrs` and raises `ArgumentError` on bad input.
Because config is a module singleton, tests and host apps share it.

**Multi-instance routing.** `config/routes.rb` is built **at load time** from
`RedisWebManager.redises.keys` — the `:instance` route segment is constrained to
the configured instance names. Adding/removing instances requires the routes to
be (re)drawn, so config must be set before the engine's routes load.

**The service-object layer (`lib/redis_web_manager/`) is the boundary to Redis.**
Controllers never call Redis directly; they go through these plain Ruby objects,
all subclasses of `Base`:
- `Base` — resolves the `Redis` handle for an instance and centralizes **every**
  Redis command behind a `redis_*` private method. Each of these methods
  branches on `connection_pool?`: a `ConnectionPool` is used via
  `redis.with { |con| ... }`, a plain `Redis` is called directly. **When adding
  a new Redis command, add it to `Base` following this same both-branches
  pattern** — do not call Redis from a subclass or controller directly.
- `Info` — read-only introspection (dbsize, config, clients, ping status, info,
  key search + per-key value/type/ttl/memory readers).
- `Connection` — connection metadata (host, port, db, id, location).
- `Action` — mutations (flushall, flushdb, del, rename).
- `Data` — dashboard time series: `perform` writes a `SETEX` snapshot keyed
  `RedisWebManager_<instance>_<timestamp>` with TTL = `lifespan`; `keys` reads
  them back; `flush` deletes them. **Dashboard data is not collected
  automatically** — the host app must call `Data#perform` from its own scheduler
  (Sidekiq/ActiveJob/etc.), as documented in the README.

**Controllers** (`app/controllers/redis_web_manager/`) inherit from
`ApplicationController`, which enforces the `authenticate` proc, validates the
`:instance` param (redirecting to the first configured instance when missing),
and memoizes one service object per request. `KeysController` additionally
formats and filters keys by type/expiry/memory and decodes list/set/zset/hash
values for display.

**Assets** are classic Sprockets (jQuery, Bootstrap, Chart.js, popper bundled
under `app/assets/javascripts/redis_web_manager/`), not the asset pipeline of a
modern host app. Views are ERB under `app/views/redis_web_manager/`.

## Conventions

- RuboCop config lives in `.rubocop.yml` (line length 125, `NewCops: enable`,
  shorthand hash syntax **disabled**). Several `Metrics/*` cops are silenced
  inline where the service/controller classes are intentionally long.
- Specs live under `spec/redis_web_manager/` and boot the dummy Rails app in
  `spec/dummy/`. `spec_helper.rb` starts SimpleCov (HTML + JSON, uploaded to Qlty
  in CI).
