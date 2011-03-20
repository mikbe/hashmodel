# Debug print
module Kernel
  def dp(value="")
    puts ""
    puts "*" * 40
    puts value
    puts "&" * 40
    puts ""
  end
  def dpi(value)
    dp value.inspect
  end
end
