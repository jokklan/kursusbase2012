source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'thin'
gem 'globalize3'
gem 'simple-navigation'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :test, :development do
  gem 'sqlite3'
  
  
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'growl'
  
end

group :test do
  gem "cucumber-rails"
  gem 'rspec-rails'
  #gem 'cucumber_factory'
  
  gem 'database_cleaner'
  gem 'simplecov'

	gem 'factory_girl_rails'

	gem 'capybara'
	gem 'cucumber-websteps'
	#gem "capybara-webkit"
	gem 'launchy'
  
	#gem 'spork', '~> 1.0rc'

	#if RUBY_PLATFORM.downcase.include?("darwin") # I'm on Mac
	#	
	#end
end


group :darwin do
	gem 'rb-fsevent'
end
group :development do
  gem 'heroku'
  gem 'sqlite3'
  # gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem 'taps'

end

group :production do
  gem 'mechanize'
  gem 'pg'
  gem 'thin'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
