# rubocop:disable Style/RegexpLiteral
# rubocop:disable Rails/Output

module SolidusMercadoPago
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      class_option :auto_skip_migrations, type: :boolean, default: false

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/solidus_mercado_pago\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_mercado_pago\n"
      end

      def add_stylesheets
        frontend_css_file = 'vendor/assets/stylesheets/spree/frontend/all.css'
        backend_css_file = 'vendor/assets/stylesheets/spree/backend/all.css'

        return unless File.exist?(backend_css_file) && File.exist?(frontend_css_file)

        inject_into_file frontend_css_file, " *= require spree/frontend/solidus_mercado_pago\n", before: /\*\//, verbose: true
        inject_into_file backend_css_file, " *= require spree/backend/solidus_mercado_pago\n", before: /\*\//, verbose: true
      end

      def add_migrations
        if !options[:auto_skip_migrations]
          run 'bundle exec rake solidus_mercado_pago:install:migrations'
        else
          puts 'Skipping rake solidus_mercado_pago:install:migrations, don\'t forget to run it!'
        end
      end

      def run_migrations
        run_migrations =  options[:auto_skip_migrations] ||
                          options[:auto_run_migrations] ||
                          ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))

        if run_migrations && !options[:auto_skip_migrations]
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
