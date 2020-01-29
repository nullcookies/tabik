module TSX
  module Exceptions
    class NoPendingTrade < Exception
    end

    class NextTry < Exception
    end

    class WrongFormat < Exception
    end

    class UsedCode < Exception
    end

    class PaymentNotFound < Exception
    end

    class OldCode < Exception
    end

    class NoBitObmenEmail < Exception
    end

    class NotEnoughAmount < Exception
    end

    class ProxyError < Exception
    end

    class Timeout < Exception
    end

    class WrongEasyPass < Exception
    end

    class JustWait < Exception
    end

    class AntiCaptcha < Exception
    end

    class StillChecking < Exception
    end

    class OpenTimeout < Exception
    end

    class ReadTimeout < Exception
    end

    class Ex < Exception
    end

  end
end