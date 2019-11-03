require 'geocoder'
module TSX
  module Controllers
    module Info

      def start_optset
        @link_to_bot = Bot[718].nickname_link
        reply_inline "info/optset", link_to_bot: @link_to_bot
      end

    end
  end
end