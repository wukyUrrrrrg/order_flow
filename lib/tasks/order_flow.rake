# -*- coding: utf-8 -*-
namespace :order_flow do
  desc "Посылаем письма клиентам, кто еще не оплатил заказ на почте"
  task :email_if_order_is_shipped_but_not_paid do
    I18n.locale = 'ru-RU'
    require File.expand_path(File.join(Rails.root,"config/environment"))
    orders = Order.shipping_method_like('почт').where('shipment_state LIKE ?', 'shipped').where('payment_state LIKE ?', 'balance_due').select {|o| o.last_event_days_ago == 20 }
    puts "Found #{orders.count} orders"
    orders.each { |o| OrderMailer.shipped_but_not_paid_email(o).deliver; sleep 2; puts "Order ##{o.number}" }
  end
end
