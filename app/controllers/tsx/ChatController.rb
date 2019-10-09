module TSX
  module Controllers
    module Chat

      def start_chat
        reply_inline "chat/welcome"
      end

    end
  end
end