# -*- coding: utf-8 -*-
Admin::ShipmentsController.class_eval do
  # Редирект на основную страницу администрирования заказа после редактирования отправок
  update.wants.html do
    if @order.completed?
      redirect_to admin_order_url(@order)
    else
      redirect_to admin_order_adjustments_url(@order)
      # redirect_to edit_object_url
    end
  end
end
