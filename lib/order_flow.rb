require 'spree_core'
require 'order_flow_hooks'

module OrderFlow
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      shipment_state_machine = Shipment.state_machines[:state]  
      shipment_state_machine.after_transition :to => 'ready' do |shipment, transition|
        ShipmentMailer.ready_email(shipment).deliver
      end
      
    end

    config.to_prepare &method(:activate).to_proc
  end
end
