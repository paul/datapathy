class Service
  include Datapathy::Model

  persists :name, :href

  def self.[](name)
    detect { |service| service.name == name }
  end
end

