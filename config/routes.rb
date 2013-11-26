Rails.application.routes.draw do
  namespace :admin do
    get 'orders/:id/pause' =>  "orders#pause", :as => :order_pause
    get 'orders/:id/resume' => "orders#resume", :as => :order_resume
    get 'orders/:id/pismo_pokupatelyu.:format' => 'orders#pismo_pokupatelyu', :as => :order_pismo_pokupatelyu,  :defaults => { :format => 'pdf' }
    get 'orders/:id/invoice' => 'orders#invoice', :as => :order_invoice

    get 'paused_orders' => "orders#paused", :as => :paused_orders
    get 'abroad_orders' => 'orders#abroad', :as => :abroad_orders
    get 'overdue_orders' => 'orders#overdue', :as => :overdue_orders
    get 'need_payment_orders' => 'orders#need_payment', :as => :need_payment_orders
    get 'waiting_e_money_orders' => 'orders#waiting_e_money', :as => :waiting_e_money_orders
    get 'courier_orders' => 'orders#courier', :as => :courier_orders
    get 'self_delivery_orders' => 'orders#self_delivery', :as => :self_delivery_orders
    get 'ready_to_form_orders' => 'orders#ready_to_form', :as => :ready_to_form_orders
    get 'orders/:id/send_shipped_but_not_paid_email' => 'orders#send_shipped_but_not_paid_email', :as => :order_send_shipped_but_not_paid_email
  end
end
