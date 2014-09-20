module ActiveRecord
  module Acts
    module ShellscriptExecutable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_shellscript_executable(options = {})
          configuration = { script: :script, stdout: nil }
          configuration.update(options) if options.is_a?(Hash)

          class_eval <<-EOV
            include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods

            ### some dynamics...
            def a_method
              '#{}'
            end
          EOV
        end
      end

      module InstanceMethods
      end
    end
  end
end
