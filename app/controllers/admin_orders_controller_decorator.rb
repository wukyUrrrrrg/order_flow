# -*- coding: utf-8 -*-
Admin::OrdersController.class_eval do
  helper RussianPostHelper

  def send_shipped_but_not_paid_email
    @order = Order.find_by_number(params[:id])
    OrderMailer.shipped_but_not_paid_email(@order).deliver
    flash[:notice] = "Письмо было отослано"
    redirect_to :action => 'show'
  end

  def pay_full_amount
    load_object
    if @order.payment_state == "balance_due"
      payment = @order.payment.can_complete? ? @order.payment : Payment.new(:order => @order, :payment_method_id => @order.payment.payment_method_id, :state => 'checkout')
      payment.amount = @order.outstanding_balance
      payment.pay
      # @order.update!
      flash.notice = t('order_updated')
    else
      flash.notice = 'Уже оплачен'
    end
    redirect_to object_path
  end

  def pause
    @order = Order.find_by_number(params[:id])
    @order.is_paused = true
    @order.save!
    redirect_to edit_admin_order_url(@order)
  end

  def resume
    @order = Order.find_by_number(params[:id])
    @order.is_paused = false
    @order.save!
    redirect_to edit_admin_order_url(@order)
  end

  def pismo_pokupatelyu
    @order = Order.find_by_number(params[:id])
  end

  def invoice
    @order = Order.find_by_number(params[:id])
  end


  def ready_to_form
    search_or_paginate Order.need_action.where('shipment_state LIKE ?','%pending%') #+ Order.with_e_money.paid.where('shipment_state LIKE ?','%pending%')
    render :action => :index
  end

  def paused
    search_or_paginate Order.paused.not_waiting_e_money.order('completed_at DESC')
    render :action => :index
  end

  def courier
    search_or_paginate Order.need_action.shipping_method_like('курьер')
    render :action => :index
  end

  def waiting_e_money
    search_or_paginate Order.waiting_e_money
    render :action => :index
  end

  def need_payment
    search_or_paginate Order.where('orders.state LIKE ?','%complete%').not_paused.where('shipment_state LIKE ?', 'shipped').where('orders.updated_at < ?', 20.days.ago).not_finished.order('completed_at DESC')
    render :action => :index
  end

  def overdue
    search_or_paginate Order.need_action.where('shipment_state NOT LIKE ?', 'shipped').where('orders.updated_at < ?', 4.days.ago).order('completed_at ASC')
    render :action => :index
  end

  def abroad
    search_or_paginate Order.where('orders.state NOT LIKE ?', 'canceled').shipping_method_like('миру').order('completed_at DESC')
    render :action => :index
  end

  def self_delivery
    search_or_paginate Order.need_action.shipping_method_like("самовывоз").order('completed_at DESC')
    render :action => :index
  end

  
  protected

  def search_or_paginate orders
    @show_only_completed = true
    params[:search] ||= {}
    @search = Order.metasearch(params[:search])

    @orders = unless params[:search].blank? 
                collection
              else
                orders.paginate(:include  => [:user, :shipments, :payments],
                                :per_page => Spree::Config[:orders_per_page],
                                :page     => params[:page])
              end
  end

  private
  def collection
    params[:search] ||= {}
    # @show_only_completed = params[:search][:completed_at_is_not_null].blank?
    @show_only_completed = (params[:search].blank? or params[:search][:completed_at_is_not_null].present?) ? true : false

    params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'
    
    @search = Order.metasearch(params[:search])
    
    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end
    
    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    if @show_only_completed
      params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than)
      params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than)
    end
    
    @collection = Order.metasearch(params[:search]).paginate(
                                                             :include  => [:user, :shipments, :payments],
                                                             :per_page => Spree::Config[:orders_per_page],
                                                             :page     => params[:page])
  end

end
