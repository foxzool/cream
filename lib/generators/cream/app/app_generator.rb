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

      def configure_application
        app_orm
        app_routes
        app_layout
      end

      protected

      def app_orm
        return if orm == 'active_record'
        File.replace_content_from config_file(:application),  :where => "require 'rails/all'" do 
        %q{
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
}
      end
       
      def app_routes
        routes = read_from config_file(:routes)
        # if no :welcome controller
        if !(routes =~ /root\s+:/)
          # create one with an 'index' view.
          insert_into config_file(:routes) :after => 'do', :content => 'root :to => "welcome#index"'          
          execute "rails g controller Welcome index"
        end
      end
      
      # in 'app/views/layouts/application.html.erb'
      # insert special flash msg displayers after opening <body> element
      def app_layout
        layout_content = read_view :application, :folder => 'layouts' #, :type => :erb

        [:alert, :notice].each{|name| insert_flash_displayer name}
      end
      
      def insert_flash_displayer name
        return if layout_content =~ /<%=\s+#{name}\s+%>/          
        insert_into_view :application, :folder => 'layouts', :after => '<body>' do
          '<p class="alert"><%= alert %></p>'
        end
      end      
    end
  end
end