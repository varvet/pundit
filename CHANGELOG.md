# Pundit

## Unreleased

## 2.5.0 (2025-03-03)

### Added

- Add `Pundit::Authorization#pundit_reset!` hook to reset the policy and policy scope cache. [#830](https://github.com/varvet/pundit/issues/830)
- Add links to gemspec. [#845](https://github.com/varvet/pundit/issues/845)
- Register policies directories for Rails 8 code statistics [#833](https://github.com/varvet/pundit/issues/833)
- Added an example for how to use pundit with Rails 8 authentication generator [#850](https://github.com/varvet/pundit/issues/850)

### Changed

- Deprecated `Pundit::SUFFIX`, moved it to `Pundit::PolicyFinder::SUFFIX` [#835](https://github.com/varvet/pundit/issues/835)
- Explicitly require less of `active_support` [#837](https://github.com/varvet/pundit/issues/837)
- Using `permit` matcher without a surrouding `permissions` block now raises a useful error. [#836](https://github.com/varvet/pundit/issues/836)

### Fixed

- Using a hash as custom cache in `Pundit.authorize` now works as documented. [#838](https://github.com/varvet/pundit/issues/838)

## 2.4.0 (2024-08-26)

### Changed

- Improve the `NotAuthorizedError` message to include the policy class.
  Furthermore, in the case where the record passed is a class instead of an instance, the class name is given. [#812](https://github.com/varvet/pundit/issues/812)

### Added

- Add customizable permit matcher description [#806](https://github.com/varvet/pundit/issues/806)
- Add support for filter_run_when_matching :focus with permissions helper. [#820](https://github.com/varvet/pundit/issues/820)

## 2.3.2 (2024-05-08)

- Refactor: First pass of Pundit::Context [#797](https://github.com/varvet/pundit/issues/797)

### Changed

- Update `ApplicationPolicy` generator to qualify the `Scope` class name [#792](https://github.com/varvet/pundit/issues/792)
- Policy generator uses `NoMethodError` to indicate `#resolve` is not implemented [#776](https://github.com/varvet/pundit/issues/776)

## Deprecated

- Dropped support for Ruby 3.0 [#796](https://github.com/varvet/pundit/issues/796)

## 2.3.1 (2023-07-17)

### Fixed

- Use `Kernel.warn` instead of `ActiveSupport::Deprecation.warn` for deprecations [#764](https://github.com/varvet/pundit/issues/764)
- Policy generator now works on Ruby 3.2 [#754](https://github.com/varvet/pundit/issues/754)

## 2.3.0 (2022-12-19)

### Added

- add support for rubocop-rspec syntax extensions [#745](https://github.com/varvet/pundit/issues/745)

## 2.2.0 (2022-02-11)

### Fixed

- Using `policy_class` and a namespaced record now passes only the record when instantiating the policy. (#697, #689, #694, #666)

### Changed

- Require users to explicitly define Scope#resolve in generated policies (#711, #722)

### Deprecated

- Deprecate `include Pundit` in favor of `include Pundit::Authorization` [#621](https://github.com/varvet/pundit/issues/621)

## 2.1.1 (2021-08-13)

Friday 13th-release!

Careful! The bugfix below [#626](https://github.com/varvet/pundit/issues/626) could break existing code. If you rely on the
return value for `authorize` and namespaced policies you might need to do some
changes.

### Fixed

- `.authorize` and `#authorize` return the instance, even for namespaced
  policies [#626](https://github.com/varvet/pundit/issues/626)

### Changed

- Generate application scope with `protected` attr_readers. [#616](https://github.com/varvet/pundit/issues/616)

### Removed

- Dropped support for Ruby end-of-life versions: 2.1 and 2.2. [#604](https://github.com/varvet/pundit/issues/604)
- Dropped support for Ruby end-of-life versions: 2.3 [#633](https://github.com/varvet/pundit/issues/633)
- Dropped support for Ruby end-of-life versions: 2.4, 2.5 and JRuby 9.1 [#676](https://github.com/varvet/pundit/issues/676)
- Dropped support for RSpec 2 [#615](https://github.com/varvet/pundit/issues/615)

## 2.1.0 (2019-08-14)

### Fixed

- Avoid name clashes with the Error class. [#590](https://github.com/varvet/pundit/issues/590)

### Changed

- Return a safer default NotAuthorizedError message. [#583](https://github.com/varvet/pundit/issues/583)

## 2.0.1 (2019-01-18)

### Breaking changes

None

### Other changes

- Improve exception handling for `#policy_scope` and `#policy_scope!`. [#550](https://github.com/varvet/pundit/issues/550)
- Add `:policy` metadata to RSpec template. [#566](https://github.com/varvet/pundit/issues/566)

## 2.0.0 (2018-07-21)

No changes since beta1

## 2.0.0.beta1 (2018-07-04)

### Breaking changes

- Only pass last element of "namespace array" to policy and scope. [#529](https://github.com/varvet/pundit/issues/529)
- Raise `InvalidConstructorError` if a policy or policy scope with an invalid constructor is called. [#462](https://github.com/varvet/pundit/issues/462)
- Return passed object from `#authorize` method to make chaining possible. [#385](https://github.com/varvet/pundit/issues/385)

### Other changes

- Add `policy_class` option to `authorize` to be able to override the policy. [#441](https://github.com/varvet/pundit/issues/441)
- Add `policy_scope_class` option to `authorize` to be able to override the policy scope. [#441](https://github.com/varvet/pundit/issues/441)
- Fix `param_key` issue when passed an array. [#529](https://github.com/varvet/pundit/issues/529)
- Allow specification of a `NilClassPolicy`. [#525](https://github.com/varvet/pundit/issues/525)
- Make sure `policy_class` override is called when passed an array. [#475](https://github.com/varvet/pundit/issues/475)

- Use `action_name` instead of `params[:action]`. [#419](https://github.com/varvet/pundit/issues/419)
- Add `pundit_params_for` method to make it easy to customize params fetching. [#502](https://github.com/varvet/pundit/issues/502)

## 1.1.0 (2016-01-14)

- Can retrieve policies via an array of symbols/objects.
- Add autodetection of param key to `permitted_attributes` helper.
- Hide some methods which should not be actions.
- Permitted attributes should be expanded.
- Generator uses `RSpec.describe` according to modern best practices.

## 1.0.1 (2015-05-27)

- Fixed a regression where NotAuthorizedError could not be ininitialized with a string.
- Use `camelize` instead of `classify` for symbol policies to prevent weird pluralizations.

## 1.0.0 (2015-04-19)

- Caches policy scopes and policies.
- Explicitly setting the policy for the controller via `controller.policy = foo` has been removed. Instead use `controller.policies[record] = foo`.
- Explicitly setting the policy scope for the controller via `controller.policy_policy = foo` has been removed. Instead use `controller.policy_scopes[scope] = foo`.
- Add `permitted_attributes` helper to fetch attributes from policy.
- Add `pundit_policy_authorized?` and `pundit_policy_scoped?` methods.
- Instance variables are prefixed to avoid collisions.
- Add `Pundit.authorize` method.
- Add `skip_authorization` and `skip_policy_scope` helpers.
- Better errors when checking multiple permissions in RSpec tests.
- Better errors in case `nil` is passed to `policy` or `policy_scope`.
- Use `inspect` when printing object for better errors.
- Dropped official support for Ruby 1.9.3

## 0.3.0 (2014-08-22)

- Extend the default `ApplicationPolicy` with an `ApplicationPolicy::Scope` [#120](https://github.com/varvet/pundit/issues/120)
- Fix RSpec 3 deprecation warnings for built-in matchers [#162](https://github.com/varvet/pundit/issues/162)
- Generate blank policy spec/test files for Rspec/MiniTest/Test::Unit in Rails [#138](https://github.com/varvet/pundit/issues/138)

## 0.2.3 (2014-04-06)

- Customizable error messages: `#query`, `#record` and `#policy` methods on `Pundit::NotAuthorizedError` [#114](https://github.com/varvet/pundit/issues/114)
- Raise a different `Pundit::AuthorizationNotPerformedError` when `authorize` call is expected in controller action but missing [#109](https://github.com/varvet/pundit/issues/109)
- Update Rspec matchers for Rspec 3 [#124](https://github.com/varvet/pundit/issues/124)

## 0.2.2 (2014-02-07)

- Customize the user to be passed into policies: `pundit_user` [#42](https://github.com/varvet/pundit/issues/42)
