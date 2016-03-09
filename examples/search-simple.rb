class CustomerHistorySearch < Valuable
  has_value :customer_id, klass: :integer
  has_value :client_id, klass: :integer

  def results
    if client_id && customer_id
      (
        ServiceOrder.where(
           customer_id: customer_id,
           client_id: client_id
        ) + 
        SalesOrder.where(
          customer_id: customer_id,
          client_id: client_id
        )
      ).sort_by(&:created_at)
    elsif customer_id
      (
        ServiceOrder.where(
          customer_id: customer_id
        ) +
        PreQ.where(
          customer_id: customer_id
        )
      ).sort_by(&:created_at)
    end
  end
end

