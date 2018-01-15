class BotService
  def initialize(token)
    Slack.configure do |config|
      config.token = token
    end
  end

  def start
    client = Slack::RealTime::Client.new

    client.on :message do |data|
      if data.text.present?
        mentioned_users(data.text).each do |user|
          mentioned_user = user
          if thanks_list(data.text)
            reply_thanks_message(mentioned_user, data, client)
          elsif data.text.include?("<@#{client.self.id}> leaderboard")
            leaderboard(client, data)
          end
        end

        if data.text == "karma" && data.channel[0..2].include?("D8")
          check_remaining_point_today(data, client)
        end
      end
    end

    client.start!
  end

  def mentioned_users(text)
    if text.include?("<@")
      splitter = text.split("<@")
      result = []
      splitter.each do |s|
        result << "<@" + s if s.include?(">")
      end
      # "<@#{text.split("<@").last.split(">").first}>"
      result
    else
      []
    end
  end

  def get_mentioned_user(text)
    if text.include?("<@")
      "<@#{text.split("<@").last.split(">").first}>"
    end
  end

  def users
    Slack::RealTime::Client.new.users
  end

  def add_point(user, from_user, point = 1)
    Point.create(user_id: user, point: point, from_user: "<@"+from_user+">")
  end

  def get_point_by_id(user)
    Point.where(user_id: user).count
  end

  def get_today_point_by_id(user)
    Point.where(user_id: user, created_at: [Time.now.beginning_of_day..Time.now.end_of_day]).count
  end

  def post_to_channel(client, data, text)
    client.web_client.chat_postMessage channel: data.channel, text: text
  end

  def check_remaining_point_today(data, client)
    today_point = get_today_point_by_id(data.user)
    remain_point = 5 - today_point
    total_point = get_point_by_id("<@#{data.user}>")
    if remain_point >= 1
      text = "Today you already received #{today_point} karma points and you can get up to #{remain_point} karma points again"
    else
      text = "Horayy you already received max karma points today. Total points you have #{total_point}"
    end
    post_to_channel(client, data, text)
  end

  def thanks_list(text)
    mentioned_user = get_mentioned_user(text)
    list = ["thanks", "thank you", "terimakasih", "thank"]
    result = false
    list.map{|t| result = true if text.include?(t) && mentioned_user.present?}
    result
  end

  def leaderboard(client, data)
    top_ten = Point.group(:user_id).order("count_user_id desc").count("user_id")
    text = "No Name     Point"
    top_ten.each_with_index do |v,i|
      text += "\n #{i+1}   #{v[0]}    #{v[1]}"
    end
    post_to_channel(client, data, text)
  end

  def reply_thanks_message(mentioned_user, data, client)
    user = "<@#{data.user}>"
    if mentioned_user.present? && mentioned_user != user
      if get_today_point_by_id(mentioned_user) >= 5
        text = "Sughoiiii. Today #{mentioned_user} already get 5 points. Total points #{mentioned_user} have is #{get_point_by_id(mentioned_user)}. Everyday everyone just can get 5 points per day."
      else
        add_point(mentioned_user,data.user)
        text = "#{mentioned_user} receives 1 point from #{user}. He/she now has #{get_point_by_id(mentioned_user)} points."
      end
    elsif mentioned_user == user
      text = "Sorry you cannot thanks to yourself :D"
    else
      text = "Sorry no user with that name or you not mention anyone. Please try again."
    end
    post_to_channel(client, data, text)
  end
end
