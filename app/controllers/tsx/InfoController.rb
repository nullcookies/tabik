require 'geocoder'
module TSX
  module Controllers
    module Roulette

      def start_roulette
        reply_inline "roulette/welcome"
      end

    end
  end
end