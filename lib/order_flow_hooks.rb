# -*- coding: utf-8 -*-
class OrderFlowHooks < Spree::ThemeSupport::HookListener
  # Кнопка "Отложить" и "Возобновить" в заказе
  insert_after :admin_order_edit_form do
    %(
      <% if @order.is_paused? %>
         <%= button_link_to(I18n::t(:resume), admin_order_resume_path(@order))%>
      <% else %>
         <%= button_link_to(I18n::t(:pause), admin_order_pause_path(@order))%>
      <% end %>
)
  end

  insert_before :admin_order_show_addresses, 'admin/shared/order_sub_menu'
  insert_before :admin_order_edit_form, 'admin/shared/order_sub_menu'

  insert_after :admin_order_show_buttons do
    %( <%= button_link_to(I18n::t("invoice"), admin_order_invoice_url(@order, :format => :pdf)) %>
     <%= button_link_to("Письмо", admin_order_pismo_pokupatelyu_path(@order, :format => :pdf)) %>)
  end

  insert_after :admin_order_show_details do 
    %(  
<table >
  <tr>
    <td><%= I18n::t('weight').to_s + ' - ' + Calculator::RussianPost.get_total_weight(@order.line_items).to_s + ' гр.' %></td>
  </tr>
</table>

      <% if @order.shipment and @order.shipment.can_ready? %>
         <%= button_link_to(I18n::t(:mark_as_formed), fire_admin_order_shipment_path(@order, @order.shipment, :e => :ready), :method => :put) %>
      <% end %>
      <% if @order.shipment and @order.shipment.can_ship? %>
        <%= button_link_to(I18n::t(:mark_as_shipped), fire_admin_order_shipment_path(@order, @order.shipment, :e => :ship), :method => :put) %>
        <% end %>
      <%  if @order.payment %>
        <% if @order.outstanding_balance > 0 %>
           <%= button_link_to(I18n::t(:mark_as_payed), admin_pay_full_amount_path(@order), :method => :put) %>
        <% else %>
           <span style="color:red; float: right; font-weight:bold;">ОПЛАЧЕНО</span>
        <% end %>
      <% end %>

  <% unless @order.special_instructions.blank? %>
    <table class="index">
      <tr>
        <th><%= t("shipping_instructions") %></th>
      </tr>
      <tr>
        <td><pre><%= @order.special_instructions %></pre></td>
      </tr>
    </table>
  <% end %>

 <%# TODO : убрать это со временем %>
    <% unless @order.comment.blank? %>
    <table class="index">
      <tr>
        <th><%= t("order_comment") %></th>
      </tr>
      <tr>
        <td><pre><%= @order.comment.html_safe %></pre></td>
      </tr>
    </table>
  <% end %>
  <%# Кнопка "Отослать письмо с сообщением, что заказ ждёт на почте"%>
  <%= button_link_to(I18n::t(:send_shipped_but_not_paid_email), admin_order_send_shipped_but_not_paid_email_path(@order),:confirm => 'Вы уверены, что хотите отослать письмо?') if @order.shipment and @order.shipment.by_post? and @order.shipment_state == 'shipped' and @order.payment_state == 'balance_due' %>

  <%# Показывать ссылки на заказы, сделанные с одного email в
    # ближайшие дни"%>
<% unless (other_orders = @order.other_orders_from_this_client_today).blank? %> 
<table >
  <tr>
    <td><strong style="color: red;">Активные заказы, сделанные этим покупателем в ближайшие дни: <%= other_orders.collect {|order| link_to(order.number, admin_order_path(order))}.join(' | ').html_safe%> </td>
  </tr>
</table>
<% end %>
)
  end

  insert_after :admin_order_show_details, 'admin/orders/shipment_tracking'
  insert_after :admin_order_show_details do
    %(<%= render "admin/shared/comment_list", :commentable => @order %>)
  end

  # <th><%#= order @search, :by => :shipping_method_name, :as => t("shipping_methods") %></th>
  # Вставил метод доставки в таблицу заказов
  insert_after :admin_orders_index_headers do
    %(
        <th> <%= t("shipping_methods") %></th>
        <th><%= t("payment_methods") %></th>)
  end
  insert_after :admin_orders_index_rows do
    %(
        <td><%= order.shipment.shipping_method.name unless (order.shipment.nil? or order.shipment.shipping_method.nil?) %></td>
        <td><%= order.payment.payment_method.name unless (order.payment.nil? or order.payment.payment_method.nil?) %></td>)
  end

  insert_after :admin_product_form_left do
    %(
    <%= link_to "Ссылка на товар", @product%>)
  end

  # Поиск заказов по индексу
  replace :admin_orders_index_search do 
    %(<p>
    <label><%= t 'zip' %></label><br />
    <%= f.text_field :ship_address_zipcode_like, :size=>25 %>
    </p>
    <p>
    <label><%= t 'tracking' %></label><br />
    <%= f.text_field :shipments_tracking_like, :size=>25 %>
    </p>
      <label><%= t("date_range") %></label><br />
      <div class="yui-g date-range-filter">
        <div class="yui-u sub-field first">
          <%= f.spree_date_picker :created_at_greater_than %><br />
          <label class="sub"><%= t("start") %></label>
        </div>
        <div class="yui-u sub-field">
          <%= f.spree_date_picker :created_at_less_than %><br />
          <label><%= t("stop") %></label>
        </div>
      </div>

      <p><label><%= t 'order_number' %></label><br />
      <%= f.text_field :number_like, :size=>25 %></p>

      <p>
        <label><%= t 'email' %></label><br />
        <%= f.text_field :email_like, :size=>25 %>
      </p>
      <p>
      <label><%= t 'first_name_begins_with' %></label><br />
          <%= f.text_field :bill_address_firstname_starts_with, :size=>25 %>
      </p>
      <p>
        <label><%= t 'last_name_begins_with' %></label><br />
        <%= f.text_field :bill_address_lastname_starts_with, :size=>25 %>
      </p>
      <p>
        <%= f.check_box :completed_at_is_not_null, {:checked => @show_only_completed}, "1", "" %>
        <label>
          <%= t("show_only_complete_orders") %>
        </label>
      </p>)
  end

end
