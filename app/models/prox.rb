class Prox < Sequel::Model(:prox)

  ONLINE = 1
  OFFLINE = 0

  def self.get_active
    prox = Prox.where(status: Prox::ONLINE).order(Sequel.desc(:checked)).first
    prox.checked = Time.now
    prox.save
    prox
  end

  def deactivate
    self.status = Prox::OFFLINE
    self.save
  end

  def self.flush
    puts "Flushed proxy table".colorize(:yellow)
    Prox.select_all.update('status = random() * 1')
  end

end