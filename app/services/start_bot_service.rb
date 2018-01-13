class BotService
  def config
    YAML.load_file(Rails.root.join("config/slack.yml"))[Rails.env]
  end
end
