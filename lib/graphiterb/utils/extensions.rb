class Array

  def sum
    inject(0.0) { |partial_sum, element| partial_sum += element }
  end
  
end
