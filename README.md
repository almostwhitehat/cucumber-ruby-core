# cucumber-core

[![Build Status](https://secure.travis-ci.org/cucumber/cucumber-ruby-core.png)](http://travis-ci.org/cucumber/cucumber-ruby-core)
[![Code Climate](https://codeclimate.com/github/cucumber/cucumber-ruby-core.png)](https://codeclimate.com/github/cucumber/cucumber-ruby-core)
[![Coverage Status](https://coveralls.io/repos/cucumber/cucumber-ruby-core/badge.png?branch=master)](https://coveralls.io/r/cucumber/cucumber-ruby-core?branch=master)
[![Dependency Status](https://gemnasium.com/cucumber/cucumber-ruby-core.png)](https://gemnasium.com/cucumber/cucumber-ruby-core)

Cucumber Core is the [inner hexagon](http://alistair.cockburn.us/Hexagonal+architecture) for the [Ruby flavour of Cucumber](https://github.com/cucumber/cucumber).

It contains the core domain logic to execute Cucumber features. It has no user interface, just a Ruby API. If you're interested in how Cucumber works, or in building other tools that work with Gherkin documents, you've come to the right place.

## An overview

The entry-point is a single method on the module `Cucumber::Core` called [`#execute`](http://rubydoc.info/gems/cucumber-core/Cucumber/Core#execute-instance_method). Here's what it does:

1. Parses the plain-text Gherkin documents into an **AST**
2. Compiles the AST down to **test cases**
3. Passes the test cases through your **mappings** to activate them
4. Passes the activated test cases through any **filters**
5. Executes the test cases, calling back to the **report**

We've introduced a number of concepts here, so let's go through them in detail.

### The AST

The Abstract Syntax Tree or [AST](http://rubydoc.info/gems/cucumber-core/Cucumber/Core/Ast) is an object graph that represents the Gherkin documents you've passed into the core. Things like [Feature](http://rubydoc.info/gems/cucumber-core/Cucumber/Core/Ast/Feature), [Scenario](http://rubydoc.info/gems/cucumber-core/Cucumber/Core/Ast/Scenario) and [ExamplesTable](ExamplesTable).

These are immutable value objects.

### Test cases

Your gherkin might contain scenarios, as well as examples from tables beneath a scenario outline.

Test cases represent the general case of both of these. We compile the AST down to instances of [`Cucumber::Core::Test::Case`](http://rubydoc.info/gems/cucumber-core/Cucumber/Core/Test/Case), each containing a number of instances of [`Cucumber::Core::Test::Step`](http://rubydoc.info/gems/cucumber-core/Cucumber/Core/Test/Step). It's these that are then mapped, filtered, and executed.

Test cases and their test steps are also immutable value objects.

### Mappings

When test cases are first compiled from the AST, they contain no information about how to execute them. Mappings are how we connect them to the code they need to run in order to execute your tests.

### Filters

Once we have the test cases, and they've been activated by the mappings, you may want to pass them through a filter or two. Filters can be used to do things like sort, replace or remove some of the test cases or their steps before they're executed.

In fact, the mappings are just a special case of a filter.

### Report

A report is how you find out what is happening during your test run. As the test cases and steps are executed, messages are sent to the report.

A report needs to respond to the following methods:

* `before_test_case(test_case)`
* `after_test_case(test_case, result)`
* `before_test_step(test_step)`
* `after_test_step(test_test, result)`
* `done`

That's probably best illustrated with an example.

## Example

Here's an example of how you might use [`Cucumber::Core#execute`](http://rubydoc.info/gems/cucumber-core/Cucumber/Core#execute-instance_method)

```ruby
require 'cucumber/core'

include Cucumber::Core

class Mappings
  def test_case(test_case, mapper)
  end

  def test_step(test_step, mapper)
    mapper.map { fail } if test_step.name =~ /fail/
    mapper.map { } if test_step.name =~ /pass/
  end
end

class Report
  def before_test_step(test_step)
  end

  def after_test_step(test_step, result)
    puts "#{test_step.name} #{result}"
  end

  def before_test_case(test_case)
  end

  def after_test_case(test_case, result)
  end

  def done
  end
end

feature = Cucumber::Core::Gherkin::Document.new(__FILE__, <<-GHERKIN)
Feature:
  Scenario:
    Given passing
    And failing
    And undefined
GHERKIN

execute [feature], Mappings.new, Report.new
```

If you run this little Ruby script, you should see the following output:

```
passing ✓
failing ✗
undefined ?
```

## Copyright

Copyright (c) 2013-2014 Cucumber Limited.
