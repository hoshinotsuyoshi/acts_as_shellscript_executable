module ActiveRecord
  module Acts
    module ShellscriptExecutable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_shellscript_executable(options = {})
          @@configuration = { method: :execute!, script: :script, stdout: nil }
          @@configuration.update(options) if options.is_a?(Hash)

          class_eval <<-EOV
            def #{@@configuration[:method].to_s}
              script = @@__configuration__[:script]
              stdout = @@__configuration__[:stdout]
              if @@__configuration__[:fork]
                fork { execute(script, stdout) }
                # for test
                Process.wait if ENV['test'] && ENV['test_wait_child'] == 'true'
              else
                execute(script, stdout)
              end
            end
          EOV

          self.class_variable_set(:@@__configuration__, @@configuration)
          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end
      end

      module InstanceMethods
        private
        def execute(script, stdout)
          script = case script
                   when Symbol
                     send script
                   when String
                     script
                   end
          script.split("\n").each do |line|
            retval = %x(#{line})
            if stdout && respond_to?("#{stdout}=".to_sym)
              send("#{stdout}=".to_sym, send(stdout).to_s + retval)
            end
            save!
          end
        end
      end
    end
  end
end
