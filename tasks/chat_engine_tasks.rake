namespace :chat do
  desc "Sync asset files from Chat Engine plugin"
  task :sync do
    system "rsync -ruv vendor/plugins/chat-engine/public ."  
  end
  
  desc "cleanup inactive chat users. This was designed to be run every 1 minute"
  task :cleanup_users => :environment do
    puts "cleaning up inactive users"
    puts "the following users are in the system: #{Chat.user_list.join ', '}"
    booted_users = Chat.inactive_user_cleanup!
    puts "the following users were booted: #{booted_users.compact!.join ', '}"
  end
end
