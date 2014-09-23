require 'tempfile'

module ActiveRecord
  module Acts
    module ShellscriptExecutable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_shellscript_executable(options = {})
          configuration = { method: :execute!, script: :script }
          configuration.update(options) if options.is_a?(Hash)
          method = configuration[:method]
          class_eval <<-EOV
            def #{method}(&block)
              script = @@__configurations__[:#{method}][:script]
              answer = ''
              __execute__(script, answer, block)
              block_given? ? nil : answer
            end
          EOV

          configurations = begin
                             class_variable_get(:@@__configurations__)
                           rescue NameError
                             {}
                           end
          configurations[method] = configuration
          class_variable_set(:@@__configurations__, configurations)
          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end

        def acts_as_rubyscript_executable(options = {})
          configuration = {
            method: :ruby_execute!, script: :script, ruby: ['ruby']
          }
          configuration.update(options) if options.is_a?(Hash)
          method = configuration[:method]
          class_eval <<-EOV
            def #{method}(&block)
              script = @@__ruby_configs__[:#{method}][:script]
              ruby   = @@__ruby_configs__[:#{method}][:ruby]
              answer = ''
              __ruby_execute__(script, answer, ruby, block)
              block_given? ? nil : answer
            end
          EOV

          configurations = begin
                             class_variable_get(:@@__ruby_configs__)
                           rescue NameError
                             {}
                           end
          configurations[method] = configuration
          class_variable_set(:@@__ruby_configs__, configurations)
          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end
      end

      module InstanceMethods
        private

        def __execute__(script, answer, block = nil)
          script = send script if script.is_a? Symbol
          retval = []
          script.split("\n").each do |line|
            if block
              block.call `#{line}`
            else
              retval << `#{line}`
            end
          end
          answer.replace retval.join
        end

        def __ruby_execute__(script, answer, ruby, block = nil)
          script = send script if script.is_a? Symbol
          retval = []

          path = Tempfile.open('') do |temp|
            temp.puts 'STDOUT.sync = true'
            temp.puts script
            temp.path
          end

          IO.popen([*ruby, path], err: [:child, :out]).each do |io|
            if block
              block.call io
            else
              retval << io
            end
          end

          answer.replace retval.join
        end
      end
    end
  end
end
