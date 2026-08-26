namespace :billetto do
  desc "Import events from Billetto"
  task :import_events, [ :limit ] => :environment do |_task, args|
    limit = args[:limit] || 10
    command = Events::Import.new(limit: limit.to_i)

    Rails.configuration.command_bus.call(command)

    puts "Billetto events import completed"
  end
end
