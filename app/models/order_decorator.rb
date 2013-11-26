# -*- coding: utf-8 -*-
Order.class_eval do

  scope :paused, lambda { where('is_paused = ?', true).where('orders.state NOT LIKE ?', 'canceled') }
  scope :not_paused, lambda { where('is_paused = ?', false).where('orders.state NOT LIKE ?', 'canceled') }

  scope :with_e_money, lambda { joins('LEFT OUTER JOIN payments ON payments.order_id = orders.id INNER JOIN payment_methods ON payment_methods.id = payments.payment_method_id').where('payment_methods.name NOT LIKE ?','%аличными%').where('orders.state NOT LIKE ?', 'canceled') }
  # joins(:payments => :payment_method)
  scope :paid, lambda { where('payment_state IN (?)',['paid', 'credit_owed']) }
  scope :waiting_e_money, lambda { with_e_money.not_paused.where('orders.state LIKE ?', 'complete').where('payment_state NOT LIKE ?', 'paid').where('payment_state NOT LIKE ?', 'credit_owed').order('completed_at DESC') }
  scope :not_waiting_e_money, lambda { where('orders.id NOT IN (?)', Order.waiting_e_money) }
  scope :finished, lambda { where('shipment_state LIKE ?', 'shipped').paid }
  scope :not_finished, lambda { where('orders.id NOT IN (?)', Order.finished) }
  scope :need_action, lambda { not_paused.where('orders.state LIKE ?','%complete%').not_finished.order('completed_at DESC').not_waiting_e_money }

  scope :shipping_method_like, lambda {|shipping_method_name|
    # joins(:shipments => :shipping_method)
    joins('LEFT OUTER JOIN `shipments` ON `shipments`.`order_id` = `orders`.`id` INNER JOIN `shipping_methods` ON `shipping_methods`.`id` = `shipments`.`shipping_method_id`').where('shipping_methods.name LIKE ?', "%#{shipping_method_name}%")
  }

  def rate_hash
    @rate_hash ||= available_shipping_methods(:front_end).collect do |ship_method|
      { :id => ship_method.id,
        :shipping_method => ship_method,
        :name => ship_method.name,
        :cost => ship_method.calculator.compute(self),
        :description => ship_method.description
      }
    end.sort_by{|r| r[:cost]}
  end

  def after_cancel
    # TODO: make_shipments_pending
    # TODO: restock_inventory
    # OrderMailer.cancel_email(self).deliver
  end

  # Позволяем отменить даже если заказ оpтправлен
  def allow_cancel?
    return false unless completed? and state != 'canceled'
    %w{shipped ready backorder pending}.include? shipment_state
  end

  def last_event_days_ago
    # last_state_event.nil? ? nil : (Date.today - self.last_state_event.updated_at.to_date).to_i
    shipment.nil? ? nil : (Date.today - self.shipment.updated_at.to_date).to_i
  end


  def last_state_event
    state_events = StateEvent.stateful_type_equals("Order").stateful_id_equals(self.id)
    state_events.blank? ? nil : state_events.last 
  end

  def other_orders_from_this_client_today
    self.completed_at.nil? ? [] : Order.where(['orders.state NOT LIKE ?','canceled']).where(['orders.email LIKE ?', self.email]).where(['completed_at >= ? and completed_at <= ?', self.completed_at - 5.days, self.completed_at + 5.days]).where('orders.id != ?', self.id)
  end

  before_validation :clone_shipping_address
  private

  # Мы делаем всё наборот - из shipping_address делаем billing_address
  def clone_billing_address
    true
  end

  # Мы делаем всё наборот - из shipping_address делаем billing_address
  def clone_shipping_address
    if self.bill_address.nil?
      self.bill_address = ship_address.clone
    else
      self.bill_address.attributes = ship_address.attributes.except("id", "updated_at", "created_at")
    end if ship_address
    true
  end

end
