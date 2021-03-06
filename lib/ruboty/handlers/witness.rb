require 'aws-sdk'
require 'shellwords'

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
        rows = message[:talk_text].split("\n")

        rows.each.with_index(1) do |text, ix|
          if text.size.nonzero?
            talk(text)
            still(message) if rows.size == 1 || rows.size != ix
          else
            message.reply 'なにかしゃべらせてよ'
          end
        end
      end

      private

      def talk(text)
        aquestalk_path = ENV['AQUES_TALK_PATH']
        `#{Shellwords.shellescape(aquestalk_path)}/AquesTalkPi -b -s 80 '#{Shellwords.shellescape(text)}' | aplay`
      end

      def still(message)
        image = Tempfile.new(%w(witness .jpg))
        `raspistill -t 2 -w 1024 -h 768 -q 50 -o #{Shellwords.shellescape(image.path)}`

        Thread.new(image) do |img|
          url = upload_s3(img.path)
          message.reply(url)
          img.close
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
