# eeID Manager

[![Code Climate](https://codeclimate.com/github/internetee/eeID-manager/badges/gpa.svg)](https://codeclimate.com/github/internetee/eeID-manager)
[![Test Coverage](https://codeclimate.com/github/internetee/eeID-manager/badges/coverage.svg)](https://codeclimate.com/github/internetee/eeID-manager/coverage)

Billing solution for EIS TARA2 service

## Setup

1. Run `bundle` to install the gems
2. Configure databases (eid_manager and tara) in `config/database.yml` according to your needs
3. Adjust configuration variables in `config/customization.yml`.
4. Run `rails db:setup`

## Default user account

By default, the application creates an administrator user account that should be used only to create new user accounts, and then deleted.

```
email: admin@eid.test
password: adminadmin
```

## API

System provides API endpoint to which TARA syslog can send output to.

### Syslog API
eID Bridge is going to forward TARA logs to this application over REST API.

## Settings

All the application settings are configurable from config/customization.yml file

## Jobs

To send out emails and perform other asynchronous tasks, we use a Sidekiq with Redis as queue backend.

Jobs are scheduled outside of the application, as the exact times are no concern of the application.
