# -*- coding: utf-8 -*-
module RussianPostHelper
  def url_russian_post_tracking bar_code
    "http://info.russianpost.ru/servlet/post_item?action=search&searchType=barCode&barCode=#{bar_code}" 
  end 

  def russian_post_delivery_status_link(bar_code, link_text = I18n::t(:order_delivery_status))
    # if bar_code
    #   link_to link_text, url_russian_post_tracking(bar_code), {:target => :blank, :title => t(:order_delivery_status_according_to_russian_post)}
    # else
    #   ''
    # end
    "Чтобы узнать местоположение вашего заказа, нужно в <a href='http://www.russianpost.ru/rp/servise/ru/home/postuslug/trackingpo'>сервисе отслеживания почтовых отправлений</a> ввести уникальный номер вашей посылки: " + bar_code.to_s
  end
end
