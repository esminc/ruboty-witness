module Ruboty
  module Handlers
    class Witness < Base
      on(
        /say\z/i,
        name: 'say',
        description: "ゆっくりがしゃべるよ"
      )

      def say(message)
        aquestalk_path = ENV['AQUES_TALK_PATH']
        message.reply(aquestalk_path)
       `#{aquestalk_path}/AquesTalkPi -b 'ゆっくりしていってね?' | aplay`
     end
    end
  end
end
