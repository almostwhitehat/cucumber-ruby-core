require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Case
        include Cucumber.initializer(:test_steps, :source)

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do |child_visitor=visitor|
            test_steps.each do |test_step|
              test_step.describe_to(child_visitor, *args)
            end
          end
          self
        end

        def describe_source_to(visitor, *args)
          source.each do |node|
            node.describe_to(visitor, *args)
          end
          self
        end

        def with_steps(test_steps)
          self.class.new(test_steps, source)
        end

        def name
          @name ||= NameBuilder.new(self).result
        end

        def tags
          @tags ||= TagCollector.new(self).result
        end

        require 'gherkin/tag_expression'
        def match_tags?(expression)
          ::Gherkin::TagExpression.new([expression]).evaluate(tags)
        end

        def language
          feature.language
        end

        def location
          source.last.location
        end

        def inspect
          "<#{self.class}: #{location}>"
        end

        private

        def feature
          source.first
        end

        class NameBuilder
          attr_reader :result

          def initialize(test_case)
            test_case.describe_source_to self
          end

          def feature(*)
            self
          end

          def scenario(scenario)
            @result = scenario.name
            self
          end

          def scenario_outline(outline)
            @result = outline.name.dup
            self
          end

          def examples_table(table)
            @result << ", #{table.name}"
            self
          end

          def examples_table_row(row)
            @result << " (row #{row.number})"
            self
          end
        end

        class TagCollector
          attr_reader :result

          def initialize(test_case)
            test_case.describe_source_to self
          end

          def feature(node)
            @result = node.tags.tags
          end

          def scenario(node)
            @result += node.tags.tags
          end

          def scenario_outline(node)
            @result += node.tags.tags
          end

          def examples_table(node)
            @result += node.tags.tags
          end

          def examples_table_row(*)
          end
        end

      end
    end
  end
end
