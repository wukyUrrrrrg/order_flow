# -*- coding: utf-8 -*-
OrderMailer.class_eval do
  helper HookHelper
  helper RussianPostHelper

  def confirm_email(order, resend=false)
    @subject    = (resend ? "[Изменения в заказе] " : "") 
    @subject    += Spree::Config[:site_name] + ' :: Уведомление о заказе #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
    @content_type = "text/html"
  end

  def cancel_email(order, resend=false)
    @subject    = (resend ? "[Дубль два] " : "") 
    @subject    += Spree::Config[:site_name] + ' :: Отмена заказа #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
    @content_type = "text/html"
  end

  def shipped_but_not_paid_email(order, resend=false)
    @subject    = (resend ? "[Дубль два] " : "") 
    @subject    += Spree::Config[:site_name] + ' :: Ваш заказ уже должен быть на почте!'
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
    @content_type = "text/html"
  end
end
