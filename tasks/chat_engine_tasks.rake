namespace :chat do
  desc "Sync asset files from Chat Engine plugin"
  task :sync do
    system "rsync -ruv vendor/plugins/chat-engine/public ."  
  end
end