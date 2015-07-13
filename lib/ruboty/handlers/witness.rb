module Ruboty
  module Handlers
    class Witness < Base
      on(
        /say (?<talk_text>.+)\z/i,
        name: 'say',
        description: "ゆっくりがしゃべるよ"
      )

      def say(message)
        aquestalk_path = ENV['AQUES_TALK_PATH']
        `#{aquestalk_path}/AquesTalkPi -b '#{message[:talk_text]}' | aplay`
        message.reply(message[:talk_text])
     end
    end
  end
end
