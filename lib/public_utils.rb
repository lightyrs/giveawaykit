module PublicUtils

  def to_bool(boolish)
    case boolish
    when "0"
      false
    when "1"
      true
    when 0
      false
    when 1
      true
    when (boolish.is_a?(FalseClass) || boolish.is_a?(TrueClass))
      boolish
    else
      false
    end
  end

  def bool_to_i(bool)
    case bool
    when false
      0
    when true
      1
    else
      bool
    end
  end
end
