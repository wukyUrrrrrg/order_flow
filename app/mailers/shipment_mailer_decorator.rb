# -*- coding: utf-8 -*-
ShipmentMailer.class_eval do

  helper RussianPostHelper

  def ready_email(shipment, resend = false)
    @shipment = shipment
    subject    = (resend ? "[Дубль два] " : "") 
    subject    += Spree::Config[:site_name] + ' :: Уведомление о резервировании заказа #' + shipment.order.number
    # @body       = {"order" => order}
    @from       = Spree::Config[:order_from]
    # @bcc        = order_bcc
    @sent_on    = Time.now
    @content_type = "text/html"
    mail(:to => shipment.order.email,
         :subject => subject)
  end

  def shipped_email(shipment, resend = false)
    @shipment = shipment
    subject    = (resend ? "[Дубль два] " : "") 
    subject    += Spree::Config[:site_name] + ' :: Уведомление об отправке заказа #' + shipment.order.number
    # @body       = {"order" => order}
    @from       = Spree::Config[:order_from]
    # @bcc        = order_bcc
    @sent_on    = Time.now
    @content_type = "text/html"
    mail(:to => shipment.order.email,
         :subject => subject)
  end

  # def shipped_email(order, resend = false)
  #   @shipment = shipment
  #   @subject    = (resend ? "[Дубль два] " : "") 
  #   @subject    += Spree::Config[:site_name] + ' :: Уведомление об отправке заказа #' + order.number
  #   @body       = {"order" => order}
  #   @recipients = order.email
  #   @from       = Spree::Config[:order_from]
  #   @sent_on    = Time.now
  #   @content_type = "text/html"
  # end

  def formed_email(order, resend = false)
    @subject    = (resend ? "[Дубль два] " : "") 
    @subject    += Spree::Config[:site_name] + ' :: Уведомление о резервировании заказа #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    # @bcc        = order_bcc
    @sent_on    = Time.now
    @content_type = "text/html"
  end

end
