module TSX
  module Payload

    def call_handler
      dd = parse_method
      @cmd = dd.first
      @var = dd.last
      !@var.nil? ? send(@cmd.to_sym, @var) : send(@cmd.to_sym)
    end

    def method_missing(meth,  *args)
      puts "METHOD MISSING #{meth}".colorize(:yellow)
      reply_button "<b>#{@btn.title}</b>\n\r\n\r#{@btn.body}"
    end

    def parse_update(body)
      bdy = json_load(body)
      @update = Telegram::Bot::Types::Update.new(bdy)
      @payload = extract_message(@update)
      @update_id = @update.update_id
    end

    def log_update
      l = "[#{@tsx_bot.id}]#{@tsx_bot.tele}".black.on_yellow
      p = "#{hb_client.id}/#{hb_client.username}, #{@cmd}, variable: #{@var.nil? ? 'n/a' : @var}".colorize(:blue)
      puts l << " " << p
      # blue "chat ##{chat}, update ##{@update_id}, message ##{message_id}"
      # blue "#{YAML.load(@hb_sessa.data).to_hash}"
      # deb @tsx_bot.inspect
      # lg "user: [#{hb_client.id}] #{hb_client.username}"
      # lg "from: @#{from}"
      # lg "chat: #{chat}"
      # lg "message/callback id: #{message_id}"
      # lg "message to edit: #{has_editable?}"
      # lg "action: #{type}"
      # lg "handler: #{@cmd}"
      # lg "variable: #{@var.nil? ? 'n/a' : $var}"
      # lg "session for #{chat}: #{session.inspect}"
      # lg "--"
    end

    def message_id
      if callback_query?
        @payload.message.message_id
      else
        @payload.message_id
      end
    end

    def chat
      callback_query? ? @payload.message.chat.id : @payload.chat.id
    end

    def group_title
      @payload.chat.title
    end

    def callback_query?
      type == 'callbackquery'
    end

    def message?
      type == 'message'
    end

    def location?
      @payload.location.nil? ? false : @payload.location
    end

    def file?
      if !@payload.photo.nil?
        if @payload.photo.last
          @payload.photo.last.file_id
        else
          false
        end
      else
        false
      end
    end

    def from
      @payload.from.username.nil? ? @payload.from.id : @payload.from.username
    end

    def type
      @payload.class.name.split('::').last.downcase
    end

    def clear_text
      if @payload.text
        @payload.text.gsub('/', '').split(' ').last
      end
    end

    def clear_data
      if @payload.data
        @payload.data
      end
    end

    def hardcoded_handler?
      res = false
      begin
        # tem "asuming variable is not empty"
        res = HAMDLERS.fetch(clear_text.to_sym)
      rescue
        return false if callback_query?
        return false if file?
        @btn = Button.where(bot: @tsx_bot.id).where(Sequel.like(:title, "%#{clear_text}%")).limit(1).first
        if !@btn.nil?
          res = @btn.title
        else
          res = false
        end
      end
      res
    end

    def is_user?
      return false if (callback_query? || file? || location?)
      begin
        Integer(clear_text)
        us_id = Client[clear_text]
        # puts "PAYLOAD #{@payload.text}"
        if !us_id.nil? and @payload.text.include?('/')
          us_id
        else
          false
        end
      rescue
        false
      end
    end

    def is_voucher?
      return false if (callback_query? || file? || location?)
      vouch = Voucher.find(voucher: clear_text, bot: @tsx_bot.id)
      if vouch.nil?
        false
      else
        vouch
      end
    end

    def has_referal?
      return false if (callback_query? || file? || location?)
      ref = clear_text
      if @payload.text
        cmd = @payload.text.split(' ').first
        if cmd == '/start' && "/#{ref}" != '/start'
          decoded = Base64.decode64(@payload.text.split(' ').last)
          # puts "DECODED: #{decoded}"
          master = Client.find(tele: decoded, bot: @tsx_bot.id)
          if !master.nil?
            return master
          else
            return false
          end
        else
          return false
        end
      else
        return false
      end
    end

    def parse_method

      is_voucher = is_voucher?
      if is_voucher
        puts "This is a voucher: ##{is_voucher.voucher}".colorize(:blue)
        return ['redeem_voucher', is_voucher]
      end

      is_user = is_user?
      if is_user
        puts "This is a user page request: ##{is_user}".colorize(:blue)
        return ['show_user', is_user.id]
      end

      master = has_referal?
      # tem "GOT REF #{master.inspect}"
      if master != false
        if master.id != hb_client.id
          blue "Adding hb_client: @#{hb_client.username} as referal to :@#{master.username}"
          ref_bot = Bot[master.bot]
          @tsx_bot.say(master.tele, "👬 Пользователь `@#{hb_client.username}` зарегистрировался как ваш реферал.")
          Ref.create(client: master.id, referal: hb_client.id)
          return ['start', nil]
        end
      end

      # hardcoded handler
      # ust call it without params
      mess = hardcoded_handler?
      # tem "#{mess} command in hardcoded list."
      # tem "skipping other conditions."
      return [mess, nil] if mess != false

      # not in hardcoded handlers list
      # and handler is NOT set
      if !handler?
        # tem "no message, no handler"
        # tem "replying with error"
        return ['no_command', nil]
      else
        # not in hardcoded handlers list
        # and handler is set
        # tem "handler is set."
        if message?
          # tem "processing message with variable"
          # tem "cmd: #{handler?}, var: #{clear_text}"
          return [handler?, clear_text]
        end
        if callback_query?
          # puts "processing callback_query with variable"
          # puts "cmd: #{handler?}, var: #{clear_data}"
          if respond_to?(clear_data.to_sym)
            return [clear_data, nil]
          end
          return [handler?, clear_data]
        end
        if file?
          # puts "FILE!!!!!!!!!!!!"
          return [handler?, file?]
        end
      end

    end

    private

    def json_load(request_body)
      request_body.rewind
      body = request_body.read
      MultiJson.load body
    end

    def extract_message(update)
      types = %w(inline_query
       chosen_inline_result
       callback_query
       edited_message
       message
       channel_post
       edited_channel_post)
      types.inject(nil) { |acc, elem| acc || update.public_send(elem) }
    end

  end
end
