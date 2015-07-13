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

        image = Tempfile.new(%w(witness .jpg))
        `raspistill -w 1024 -h 768 -q 50 -o #{image.path}`

        message.reply(image.path)

        image.close
     end
    end
  end
end
