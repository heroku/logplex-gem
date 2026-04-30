# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

-

### Changed

-

## [1.0.0]

### Added

- `Logplex::HTTP::Error` exception hierarchy. See: lib/logplex/errors.rb
- RuboCop linting with StandardRB-based configuration
- GitHub Actions CI workflow (Ruby 3.2, 3.3, 3.4, 4.0)

### Changed

- Migrated test stubs from Excon mocks to WebMock
- Migrated CI from CircleCI to GitHub Actions

### Removed

- **Breaking Change:** Replace `Excon` with stdlib `Net::HTTP` - Gem-specific errors are raised rather than Excon-specific errors. See: lib/logplex/errors.rb
- Duplicate license file

## [0.0.7]

### Added

- Bearer authentication support via `bearer_token:` keyword argument on `Publisher`

### Changed

- N/A

### Removed

- CircleCI configuration
- Duplicate license file

## [0.0.6] - 2022-03-03

### Added

- Accept HTTP 202 responses from Logplex in addition to 200 and 204
- CODEOWNERS file with ECCN classification

### Changed

- Migrated CI from Travis CI to CircleCI

### Removed

- Travis CI configuration

## [0.0.5] - 2021-09-13

### Changed

- Updated gemspec metadata

## [0.0.4] - 2021-07-13

### Added

- `Logplex-Msg-Count` header sent with each publish request
- `app_name` option to override the default token-based app name on publish
- Tests for header correctness and app name override

### Fixed

- Message number mismatch when publishing multiple messages
- `app_name` from options now properly overrides the token default instead of the reverse

## [0.0.1] - 2016-07-26

### Changed

- Modernized publisher to use `Excon.post` directly instead of persistent connections
- Updated gemspec and dependencies

## [0.0.1-pre] - 2013-05-01

### Added

- Initial logplex publisher and message formatting
- Global configuration object with configurable `process`, `host`, and `publish_timeout`
- Syslog-framed message encoding
- Key/value pair formatting when messages are passed as a hash
- Publish timeout (default 1 second) with configurable override
- Return value from `publish` (true on success, false on failure)
- Travis CI configuration

### Fixed

- Bug caused by invoking `Array()` on a hash

[Unreleased]: https://github.com/heroku/logplex-gem/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/heroku/logplex-gem/compare/v0.0.7...v1.0.0
[0.0.7]: https://github.com/heroku/logplex-gem/compare/v0.0.6...0.0.7
[0.0.6]: https://github.com/heroku/logplex-gem/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/heroku/logplex-gem/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/heroku/logplex-gem/compare/v0.0.1...v0.0.4
[0.0.1]: https://github.com/heroku/logplex-gem/compare/v0.0.1-pre...v0.0.1
