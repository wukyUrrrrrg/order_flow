# -*- coding: utf-8 -*-
CheckoutController.class_eval do
  before_filter :flash_if

  def flash_if
    flash_if_order_is_very_small
    flash_if_order_is_small
    flash_if_order_is_almost_big
    flash_if_order_is_big
  end

  def flash_if_order_is_very_small
    puts '===================' + @order.total.to_s
    flash[:error] = "<em><strong>Предупреждение</strong></em>: К сожалению для нас экономически нецелесообразно обрабатывать заказы на сумму <strong>менее 150 рублей</strong>.
Пожалуйста, добавьте к заказу какую либо ещё книгу или диск. <a href='/'>Продолжить покупки</a>".html_safe if @order.total <= 150
  end

  def flash_if_order_is_small
    flash[:notice] = "<em><strong>На заметку</strong></em>: по нашему опыту экономически целесообразно заказывать на сумму <strong>более 500 рублей</strong>, иначе стоимость доставки
(почтой или курьером) по сравнению со стоимостью товаров будет <strong>нецелесообразно высока</strong>. <a href='/'>Продолжить покупки</a>".html_safe if (@order.total > 150 and @order.total < 500)
  end

  def flash_if_order_is_almost_big
    flash[:notice] = "<strong><em>На заметку</em></strong>: если общая сумма заказов <strong>более 12000 рублей</strong> и более половины позиций по <a href='http://konzeptual.ru/t/temy/kontseptsiya-obschestvennoy-bezopasn'>КОБ</a> и <a href='http://konzeptual.ru/t/temy/sobriologiya'>собриологии</a>, то цены на весь заказ будут <strong>ниже на 20%</strong>.
 <a target='_blank' href='http://konzeptual.ru/txt/%D0%BC%D0%B0%D0%B3%D0%B0%D0%B7%D0%B8%D0%BD/%D0%B0%D0%BA%D1%86%D0%B8%D0%B8/%D1%81%D0%BD%D0%B8%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-%D1%86%D0%B5%D0%BD/'>Подробности</a>.".html_safe if (@order.total > 5000 and @order.total < 12000)
  end

  def flash_if_order_is_big
    flash[:notice] = "<strong><em>На заметку</em></strong>: если <strong>более половины</strong> позиций в вашем заказе по <a href='http://konzeptual.ru/t/temy/kontseptsiya-obschestvennoy-bezopasn'>КОБ</a> и <a href='http://konzeptual.ru/t/temy/sobriologiya'>собриологии</a>, то цены на весь заказ будут <strong>ниже на 20%</strong>.
 <a target='_blank' href='http://konzeptual.ru/txt/%D0%BC%D0%B0%D0%B3%D0%B0%D0%B7%D0%B8%D0%BD/%D0%B0%D0%BA%D1%86%D0%B8%D0%B8/%D1%81%D0%BD%D0%B8%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-%D1%86%D0%B5%D0%BD/'>Подробности</a>.".html_safe if @order.total >= 12000
  end

end
