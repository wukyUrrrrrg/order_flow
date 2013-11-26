# -*- coding: utf-8 -*-
Shipment.class_eval do

  # Можно отправлять заказ если он еще не оплачен.
  def determine_state(order)
    return "pending" if self.inventory_units.any? {|unit| unit.backordered?}
    state || 'pending'
  end

  # state_machine is in /lib/order_flow.rb since I got troubles with
  # emails that was sent twice
                                      
  def update!(order)
    logger.info 'UPDATE! is called' + self.inspect
    old_state = self.state
    new_state = determine_state(order)
    logger.info "old_state = #{old_state}; new_state = #{new_state}" + self.inspect
    if old_state != new_state 
      update_attribute_without_callbacks "state", new_state
      after_ready if new_state == 'ready' and old_state != 'ready'
      after_ship if new_state == 'shipped' and old_state != 'shipped'
    end
  end
  def by_post?
    self.shipping_method.name =~ /Почт/
  end

  def by_courier?
    self.shipping_method.name =~ /Курьер/
  end
end
