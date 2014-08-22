# Pundit

## 0.3.0 (unreleased)

- Extend the default `ApplicationPolicy` with an `ApplicationPolicy::Scope` (#120)
- Fix RSpec 3 deprecation warnings for built-in matchers (#162)
- Generate blank policy spec/test files for Rspec/MiniTest/Test::Unit in Rails (#138)

## 0.2.3 (2014-04-06)

- Customizable error messages: `#query`, `#record` and `#policy` methods on `Pundit::NotAuthorizedError` (#114)
- Raise a different `Pundit::AuthorizationNotPerformedError` when `authorize` call is expected in controller action but missing (#109)
- Update Rspec matchers for Rspec 3 (#124)

## 0.2.2 (2014-02-07)

- Customize the user to be passed into policies: `pundit_user` (#42)
