require 'aws-sdk'

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

        file_name = "#{SecureRandom.hex}.jpg"

        s3 = Aws::S3::Resource.new(region: 'ap-northeast-1')
        obj = s3.bucket('raspberrypi-witness').object(file_name)
        obj.upload_file(image.path)

        message.reply(obj.public_url)

        image.close
     end
    end
  end
end
