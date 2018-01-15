require "rails_helper"

describe BotService do
  let(:bot) do
    BotService.new()
  end

  let(:point) do
    FactoryBot.build(:point, user_id: "<@aldi>", point: 1,from_user: "<@queensha>").save
  end

  context "Bot Start" do
    describe "#start" do
      # This method for start slack bot.
    end

    describe "get_mentioned_user" do
      it " should return mentioned user_id, when user mentioned another users" do
        text = "hi <@8719asd9>"
        expect(bot.get_mentioned_user(text)).to eq("<@8719asd9>")
      end

      it "should return nil when user not mentioned user" do
        text = "hi ujang!"
        expect(bot.get_mentioned_user(text)).to eq(nil)
      end
    end

    describe "#add_point" do
      it "should create point" do
        expect(bot.add_point("<@sampoerna>", "<@bacang>", 1)).to change(Point, :count).by(1)
      end

    end

    describe "#get_point_by_id" do
      before do
        point
      end

      it "should return point more than zero by user_id when user present" do
        expect(bot.get_point_by_id("<@aldi>")).to eq(1)
      end

      it "should return zero when user not found" do
        Point.destroy_all
        expect(bot.get_point_by_id("<@aldi>")).to eq(0)
      end
    end

    describe "#get_today_point_by_id" do
      it "should return point more than zero by user_id when user present" do
        expect(bot.get_point_by_id("<@aldi>")).to eq(1)
      end

      it "should return zero when user not found" do
        Point.destroy_all
        expect(bot.get_point_by_id("<@aldi>")).to eq(0)
      end

    end

    describe "#post_to_channel" do
      #post message to channel who call trigger for this bot
    end

    describe "#check_remaining_point_today" do
      it "should return remaining point for today" do
      end
    end

    describe "#thanks_list" do
      it "check when user say any thanks in list" do
      end
    end

    describe "#leaderboard" do
      it "should return top ten who have higghest point" do
      end
    end
  end
end
