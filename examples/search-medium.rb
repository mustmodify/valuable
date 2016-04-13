class CustomerSearch < Valuable
  # BE AWARE OF SQL INJECTION!!!

  has_value :last_name
  has_value :first_name
  has_value :zipcode
  has_value :partner_id, :klass => :integer

  def terms
    # With truly simple cases, you can just use `attributes` for this

    terms = {}
    terms[:zipcode] = self.zipcode
    terms[:last_name_like] = "%#{self.last_name}%" if self.last_name
    terms[:first_name_like] = "%#{self.first_name}%" if self.first_name
    terms[:partner_id] = self.partner_id if self.partner_id
    terms
  end

  def joins
    out = []
    out << [:location] if self.zipcode
    out << [:identifiers] if self.partner_id
    out
  end

  def conditions
    out = []

    unless self.last_name.blank?
      out << "customers.last_name like :last_name_like"
    end

    unless self.first_name.blank?
      out << "customers.first_name like :first_name_like";
    end

    unless self.zipcode.blank?
      out << "locations.zipcode = :zipcode"
    end

    unless self.partner_id.blank?
      out << "customer_identifiers.partner_id = :partner_id"
    end

    if( out.not.empty? )
      [out.join(' and '), terms]
    else
      nil
    end
  end

  def results
    Customer.joins(joins).where(conditions).includes([:location]).order('customers.id
 desc')
  end
end
