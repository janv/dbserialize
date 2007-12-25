namespace :db do
  namespace :serialize do
    desc 'Create YAML test fixtures from data in an existing database.  
    Defaults to development database. Set RAILS_ENV to override.'
    task :save => :environment do
      sql = "SELECT * FROM %s"
      skip_tables = ["schema_info", "sessions"]
      ActiveRecord::Base.establish_connection
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      FileUtils.mkpath("#{RAILS_ROOT}/db/fixtures/")
      tables.each do |table_name|
        i = "000"
        File.open("#{RAILS_ROOT}/db/fixtures/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end

    desc "Load seed fixtures (from db/fixtures) into the current environment's database." 
    task :restore => :environment do
      require 'active_record/fixtures'
      Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end
    end
  end
end