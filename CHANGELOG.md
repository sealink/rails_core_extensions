# Changelog

## Unreleaed

* [TT-5542] Remove Rails 4 support

## 0.5.0

* Support include_blank properly (was broken)

## 0.4.0 (Removes Rails3 Support)

* [TT-3778] Store the cacheable attributes in memory for the duration of the request

## 0.3.0

* Use coverage kit to enforce maximum coverage
* [ROT-73] Always cache cacheable attributes
* [RU-133] Replace alias_method_chain with alias_method

## 0.2.0

* Extract and test translations

## 0.1.1

* Fixes issue with sortable controllers
  implicitly depending on prototype based template rendering

## 0.1.0

* Add rails 5 support
* Refactor clone_excluding to enable rails 5 support
* Extract transfer_records to class
* Rename enum to enum_int to be rails 4/5 compatible
