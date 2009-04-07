class ChatsController < ApplicationController
  before_filter :check_reserved_nick, :only => :create
  layout false
  
  def show
    @messages = Chat.new(h(params[:id])).get_messages
    @messages.collect! do |m|
      returning m do
        m[:content] = ActionController::Base.helpers.auto_link m[:content], :html => { :rel => 'external' }
      end
    end
    @hash = Chat.user_list_hash
  end
  
  def user_list
    @users = Chat.user_list
    @users.collect! do |u|
      OFFICE_RESERVED_NICKS.include?(u) ? highlight_user(u) : u
    end
    @hash = Chat.user_list_hash
  end
  
  def create
    @nick = Chat.new(h(params[:chat_nick])).add_user
    session[:chat_nick] = @nick
    user_list
    
    respond_to do |format|
      format.js
      # format.html { render_javascript_error }
    end
  end
  
  def update
    @nick = h params[:id]
    message = CGI.escapeHTML(params[:chat_message])
    Chat.new(@nick).send_message message unless message.blank?
  end
  
  def destroy
    Chat.new(h(params[:id])).remove_user
  end
  
  private
  def h(str)
    CGI.escapeHTML str
  end
  
  def highlight_user(user)
    "<span class='office_user'>#{user}</span>"
  end
  
  def render_javascript_error
    render :text => 'Please enable javascript. <a href="/streams">back</a>', :layout => true
  end
  
  def render_error(text)
    @create_error = text
    respond_to do |format|
      format.js { render :action => 'create_error' }
      format.html { render_javascript_error }
    end 
  end
  
  # these are regexified
  OFFICE_RESERVED_NICKS = [
    'tatango',
    'derek',
    'adrian',
    'andrew',
    'amiel',
    'alex',
    'nathan',
  ].freeze
  
  NICK_MIN_SIZE = 3
  NICK_MAX_SIZE = 20
  
  def check_reserved_nick
    return render_error('That nickname is either too long or too short, please choose another.') unless (NICK_MIN_SIZE..NICK_MAX_SIZE).include? params[:chat_nick].size
    return render_error('Please choose a nickname with some content.') unless params[:chat_nick].match /\w/
    
    case request.remote_ip
    when '127.0.0.1', '63.229.10.168'
      return true
    else
      if params[:chat_nick].match Regexp.new(OFFICE_RESERVED_NICKS.collect{|n| '\b' + n + '\b'}.join('|'), 'i')
        return render_error('That nickname is reserved, please choose another.')
      end
    end
  end
  
end
