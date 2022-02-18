# eID Manager

[![Build Status](https://travis-ci.org/internetee/eid_manager.svg?branch=master)](https://travis-ci.org/internetee/eid_manager)
[![Code Climate](https://codeclimate.com/github/internetee/eid_manager/badges/gpa.svg)](https://codeclimate.com/github/internetee/eid_manager)
[![Test Coverage](https://codeclimate.com/github/internetee/eid_manager/badges/coverage.svg)](https://codeclimate.com/github/internetee/eid_manager/coverage)

Billing solution for EIS TARA service

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
eID Bridge is going to forward TARA logs to this application over REST API. You can create fake fetchable TARA logs by manual API calls.
An example of SmartID mock log:

```
curl --location --request POST 'https://eid.test/api/v1/notify' \
--header 'Content-Type: application/json' \
--data-raw '{
    "date": "2021-03-23T13:59:43,550+0200",
    "level": "INFO",
    "requestId": "PVR8F19E53EIBS5M",
    "sessionId": "TE82WdBKmBp8J3te9J5J3W5COxL1Ga1IRDx1eMqjhAg=",
    "logger": "org.apereo.cas.authentication.PolicyBasedAuthenticationManager",
    "querystring": "service=https%3A%2F%2Ftara-test.infra.tld.ee%2Foauth2.0%2FcallbackAuthorize%3Fclient_id%3Doidc-62cea3aa-22ed-4e5d-ad1e-b4475b10ea8c-2%26redirect_uri%3Dhttps%253A%252F%252Ftest-tara-billing.infra.tld.ee%252Fauth%252Ftara%252Fcallback%26response_type%3Dcode%26client_name%3DCasOAuthClient",
    "requesturi": "/login",
    "thread": "ajp-nio-0:0:0:0:0:0:0:1-8009-exec-10",
    "message": "Authenticated principal [EE39708290276] with attributes [{ACR=high, AMR=[[smartid]], DATE_OF_BIRTH=1997-08-29, FAMILY_NAME=ÕUNAPUU, GIVEN_NAME=KARL ERIK, SUB=EE39708290276}] via credentials [[TaraCredential(type=SmartID, principalCode=EE39708290276, firstName=KARL ERIK, lastName=ÕUNAPUU)]]."
}'
```

## Settings

All the application settings are configurable from config/customization.yml file

## Jobs

To send out emails and perform other asynchronous tasks, we use a Sidekiq with Redis as queue backend. To start an executor, use `bundle exec sidekiq -q default -q mailers`.

Jobs are scheduled outside of the application, as the exact times are no concern of the application.
