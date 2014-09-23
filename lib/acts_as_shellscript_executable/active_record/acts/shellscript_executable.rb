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

          class_eval <<-EOV
            def #{configuration[:method]}(&block)
              script = @@__configuration__[:script]
              answer = ''
              __execute__(script, answer, block)
              block_given? ? nil : answer
            end
          EOV

          class_variable_set(:@@__configuration__, configuration)
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
      end
    end
  end
end
