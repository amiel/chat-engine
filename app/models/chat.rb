require_dependency 'cached_array'

class Chat

  def self.user_list
    CachedArray('chat/users').to_a
  end
  
  def self.user_list_hash
    user_list.hash
  end
  
  def self.inactive_user_cleanup!
    CachedArray('chat/users').collect do |u|
      user = Chat.new u
      user.remove_user unless user.active?
    end
  end

  attr_reader :nick
  # be sure to sanitize nick before initialize
  def initialize(nick)
    @nick = nick
  end
  
  def inspect
    "#<Chat nick: '#{@nick}', active?: #{active?}, last_poll: #{last_poll}, muted: #{muted?}>"
  end
  
  def set_poll_activity
    Rails.cache.write activity_key, Time.current
  end

  def last_poll
    Rails.cache.read activity_key
  end

  def get_messages
    set_poll_activity
    CachedArray(messages_key).get_array_and_clear
  end

  # all messages should be sanitized for browser output before entering the cache
  def send_message(message)
    if muted?
      CachedArray(messages_key).push :nick => @nick, :content => message
    else
      CachedArray('chat/users').each do |u|
        CachedArray(messages_key(u)).push :nick => @nick, :content => message
      end
    end
  end
  
  def active?(since = 1.5.minutes.ago)
    a = last_poll
    !!(a and a > since)
  end
  
  def muted?
    !! Rails.cache.read(muted_key)
  end
  
  def mute!
    Rails.cache.write muted_key, true
  end
  
  def unmute!
    Rails.cache.delete muted_key
  end
  
  def in_room?
    CachedArray('chat/users').include? @nick
  end
  
  def add_user
    make_unique!
    validate!
    users = CachedArray('chat/users')
    users.push(@nick)
    return @nick
  end
  
  def remove_user
    Rails.cache.delete activity_key
    CachedArray('chat/users').delete @nick
    CachedArray(messages_key).clear
    return @nick
  end
  
  
  
  def messages_key(nick = @nick)
    "chat/messages/#{cache_key nick}"
  end
  
  def activity_key(nick = @nick)
    "chat/poll_activity/#{cache_key nick}"
  end
  
  def muted_key(nick = @nick)
    "chat/mute/#{cache_key nick}"
  end

  private
  def cache_key(nick = @nick)
    nick.gsub(/[^a-zA-Z0-9]/, '_')
  end
  
  
  def make_unique!
    while Chat.user_list.find { |u| cache_key(u).casecmp(cache_key(@nick)) == 0 }
      @nick << '_'
    end
  end
  
  def validate!
    @nick.gsub!('.', '_')
  end

end