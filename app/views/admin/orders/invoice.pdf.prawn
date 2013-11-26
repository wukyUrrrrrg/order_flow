# -*- coding: utf-8 -*-
prawn_document() do |pdf|
  font_directory = "#{Rails.root}/public/images/fonts"
  pdf.font_families.update(
                           "Arial" => { :bold => "#{font_directory}/arialbd.ttf",
                             :italic      => "#{font_directory}/ariali.ttf",
                             :bold_italic => "#{font_directory}/arialbi.ttf",
                             :normal      => "#{font_directory}/arial.ttf" })
  pdf.font "Arial"

  address = @order.ship_address
  invoice_config = {
    :logo => 'images/theme_konzeptual/triglav_na_belom.jpg',
    :company_name => 'Интернет-магазин Концептуал.ru'
  }

  ###################################
  # Шапка
  ###################################
  pdf.move_down 20
  pdf.image "#{Rails.root}/public/#{invoice_config[:logo]}", :at => [10,720], :scale => 0.125
  pdf.move_down 20
  pdf.text "#{I18n::t('invoice')} №#{@order.number}",
  :align => :center,
  :style => :bold,
  :size => 16

  pdf.text_box "#{Date.today}",
  :width    => 100,
  :height => pdf.font.height * 2,
  :overflow => :ellipses, 
  :at       => [pdf.bounds.right-100,pdf.bounds.top-10],
  :align => :right

  pdf.move_down 20
  pdf.text "От кого: #{invoice_config[:company_name]}"
  pdf.move_down 5
  pdf.text "Получатель: #{address.firstname} #{address.lastname}"
  pdf.text address.phone
  (", #{address.alternative_phone}" unless address.alternative_phone.blank?).to_s
  pdf.text address.address1 +
    (", #{address.address2}" unless address.address2.blank?).to_s +
    ", #{address.city}, #{address.state}, #{address.zipcode}, #{address.country.name}"
  pdf.text I18n::t(:shipping_instructions) + ': ' + @order.special_instructions unless @order.special_instructions.blank?
  pdf.move_down 15

  ###################################
  # Таблица товаров
  ###################################
  order_items = [[]]
  i = 0
  @order.line_items.each do |item|
    order_items[i] = [item.variant.product.name + (item.variant.option_values.empty? ? '' : ("(" + variant_options(item.variant) + ")")) + (item.respond_to?(:pseudo_variant) and !item.pseudo_variant.blank? ? ("(" + item.pseudo_variant + ")") : ''),
                      number_to_currency(item.price).gsub('&nbsp;', ' '),
                      item.quantity,
                      number_to_currency(item.price * item.quantity).gsub('&nbsp;', ' ') 
                     ]
    i += 1
  end

  @order.adjustments.each do |adjustment| 
    order_items[i] = [adjustment.label,
                      '',
                      '',
                      number_to_currency(adjustment.amount).gsub('&nbsp;', ' ')
                     ]
    i += 1
  end 
  order_items[i] = [I18n::t(:subtotal), '', '', number_to_currency(@order.item_total).gsub('&nbsp;', ' ')]
  pdf.table order_items,
  :headers  => [I18n::t('item_description'), I18n::t('price'), I18n::t('qty'), I18n::t('total')],
  :position           => :center,
  :border_width => 1,
  # :vertical_padding   => 2,
  # :horizontal_padding => 6,
  :font_size => 11,
  :column_widths => { 0 => 350, 1 => 50, 2 => 50, 3 => 50 }
  # :widths => { 0 => 200, 1 => 50, 2 => 50, 3 => 50 }

  # :border_style => :underline_header

  ###################################
  # Подвал
  ###################################
  pdf.move_down 10
  pdf.text "#{I18n::t('total')}: #{number_to_currency(@order.total).gsub('&nbsp;', ' ')}          ",
  :size => 13,
  :style => :bold,
  :align => :right

end
