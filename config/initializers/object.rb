class Object

  def truthy?
    if [nil, "null", "false", false, "", 0, "0", []].include?(self)
      false
    else
      true
    end
  end
end
