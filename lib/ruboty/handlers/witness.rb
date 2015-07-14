require 'aws-sdk'

module Ruboty
  module Handlers
    class Witness < Base
      on(
        /say (?<talk_text>.+)\z/i,
        name: 'say',
        description: "ゆっくりがしゃべるよ"
      )

      on(
        /(?<talk_text>.+)\z/im,
        missing: true,
        name: 'default',
        description: "ゆっくりがしゃべるよ"
      )

      def say(message)
        talk(message[:talk_text])
      end

      def default(message)
        message[:talk_text].split("\n").each do |text|
          talk(text)
          message.reply(still)
        end
      end

      private

      def talk(text)
        aquestalk_path = ENV['AQUES_TALK_PATH']
        `#{aquestalk_path}/AquesTalkPi -b -s 80 '#{text}' | aplay`
      end

      def still
        Tempfile.open(%w(witness .jpg)) do |image|
          `raspistill -w 1024 -h 768 -q 50 -o #{image.path}`
          upload_s3(image.path)
        end
      end

      def upload_s3(local_path)
        file_name = "#{SecureRandom.hex}.jpg"
        s3 = Aws::S3::Resource.new(region: 'ap-northeast-1')
        obj = s3.bucket('raspberrypi-witness').object(file_name)
        obj.upload_file(local_path)
        obj.public_url
      end
    end
  end
end
