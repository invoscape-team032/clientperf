class ClientperfMigrations
  MIGRATION_NAMES = %w(add_clientperf_tables)
  MIGRATION_CONTENTS = {
    :add_clientperf_tables => %(
class AddClientperfTables < ActiveRecord::Migration
  def self.up
    create_table :clientperf_uris do |t|
      t.string :uri
      t.timestamps 
    end

    create_table :clientperf_results do |t|
      t.integer :clientperf_uri_id
      t.integer :milliseconds
      t.timestamps 
    end
  end

  def self.down
    drop_table :clientperf_uris
    drop_table :clientperf_results
  end
end)
  }
  
  attr_accessor :rails_dir
      
  def initialize(rails_dir)
    @rails_dir = rails_dir
  end
  
  def install_new
    MIGRATION_NAMES.reject {|name| exists?(name) }.each do |migration|
      generate(migration)
      install(migration)
    end
  end
  
  private
  
  def generate(migration_name)
    `#{File.join(rails_dir, 'script', 'generate')} migration #{migration_name}`
  end
  
  def migration_path(migration_name)
    Dir[File.join(rails_dir, 'db', 'migrate', "*_#{migration_name}.rb")].first
  end
  alias_method :exists?, :migration_path
  
  def install(migration)
    File.open(migration_path(migration), 'w') do |file|
      file << MIGRATION_CONTENTS[migration.to_sym]
    end
  end
end