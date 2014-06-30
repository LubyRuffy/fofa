# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Webdbweb::Application.initialize!

ActiveRecord::Base.pluralize_table_names = false