class MassObject
  def self.set_attrs(*attributes)
    @attributes = []

    attributes.each do |attribute|
      attr_accessor attribute
      @attributes << attribute
    end
  end

  def self.attributes
    @attributes ||= []
  end

  def self.parse_all(results)
    objects = Array.new
    results.each do |result|
      objects << self.new(result)
    end

    objects
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      if self.class.attributes.include?(attr_sym)
        send("#{attr_sym}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end
