# Changelog

## 0.14.0

- [PLAT-1135] Remove `enum_int` as we have now fully migrated to rails native `enum`

## 0.13.2

- [PLAT-390] Fix broken `action_view` extensions

## 0.13.1

- [PLAT-384] Fix the liquid extension

## 0.13.0

- [PLAT-378] Improve bundler startup time; Drop Concurrency

## 0.12.0

- [PLAT-183] Ruby 3.1, Rails 7.0 and publish coverage with github action

## 0.11.3

- [TT-8647] Fix issue with position_helpers_for active record change

## 0.11.2

- [TT-8640] Add dependabot config

## 0.11.1

- [TT-8608] Fix broken rake command in the gem publish stage

## 0.11.0

- [TT-8608] Switch from travis to gihthub actions
- [TT-8608] Add support for Rails 6.1 / Ruby 3

## 0.10.0

- [TT-8507] Sortable will now fire callbacks to ensure we audit these changes

## 0.9.0

- [TT-6727] Fix usage of symbolize_keys in sortable

## 0.8.0

- [TT-6539] Remove cache_all_attributes and other unused methods
- [TT-5384] Remove validates_presence_of_parent method (Use rails optional flag instead)
- [TT-6293] Drop breadcrumbs / cache without host and some unused view helpers

## 0.7.1

- [TT-5745] Fix passing of symbol to liquid template parse

## 0.7.0

- [TT-5745] Update Liquid validate to be v4 compatible

## 0.6.1

- [TT-5671] More fixes to sortable

## 0.6.0

- [TT-5542] Remove Rails 4 support
- [TT-5642] Fixed sortable so it can sort on empty scopes

## 0.5.0

- Support include_blank properly (was broken)

## 0.4.0 (Removes Rails3 Support)

- [TT-3778] Store the cacheable attributes in memory for the duration of the request

## 0.3.0

- Use coverage kit to enforce maximum coverage
- [ROT-73] Always cache cacheable attributes
- [RU-133] Replace alias_method_chain with alias_method

## 0.2.0

- Extract and test translations

## 0.1.1

- Fixes issue with sortable controllers
  implicitly depending on prototype based template rendering

## 0.1.0

- Add rails 5 support
- Refactor clone_excluding to enable rails 5 support
- Extract transfer_records to class
- Rename enum to enum_int to be rails 4/5 compatible
