require 'thread'

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
            def #{configuration[:method].to_s}(&block)
              script = @@__configuration__[:script]
              answer = ''
              if @@__configuration__[:parallel]
                Thread.new do
                  __execute__(script, answer, block)
                end
                block_given? ? nil : answer
              else
                __execute__(script, answer)
              end
            end
          EOV

          self.class_variable_set(:@@__configuration__, configuration)
          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end
      end

      module InstanceMethods
        private
        def __execute__(script, answer, block=nil)
          script = case script
                   when Symbol
                     send script
                   when String
                     script
                   end
          retval = []
          script.split("\n").each do |line|
            if block
              block.call( %x(#{line}))
            else
              retval << %x(#{line})
            end
          end
          answer.replace retval.join
        end
      end
    end
  end
end
