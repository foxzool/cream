require 'sugar-high/file'
require 'sugar-high/modules'
require 'cream'
require 'rails3_artifactor'
require 'logging_assist'

module Roles
  module Generators 
    class ConfigGenerator < Rails::Generators::Base
      extend Rails3::Assist::UseMacro
        
      desc "Configure Permits"

      # ORM to use
      class_option :orm,                :type => :string,   :default => 'active_record',  :desc => "ORM to use"

      class_option :logfile,            :type => :string,   :default => nil,              :desc => "Logfile location" 

      def configure_roles
        create_roles
        set_valid_roles_cream
        use_roles_strategy        
      end      

      protected

      def roles_gems
        gem "roles_#{orm}"
      end 

      def create_roles
        rgen "#{roles_generator} --strategy #{strategy} --roles #{roles} #{default_roles}"        
      end

      def set_valid_roles_cream
        if initializer_file? :cream
          replace_in_model_file :user, :where => /valid_roles_are\s+[(.*)]/, :with => 'valid_roles_are Cream.roles'
        end          
      end

      def use_roles_strategy
        unless read_model_file(:user) =~ /use_roles_strategy/
          insert_into_model :user do 
            "use_roles_strategy :admin_flag"
          end
        end        
      end

      protected

      def default_roles
        default_roles? ? '--default-roles' : '--no-default-roles'
      end      
    end
  end
end