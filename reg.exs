defmodule Solution do
  def multipleOf3Regex do
        ~r/^(0|(1(01*0)*(10*)))+$/
  end
  def test( value) do
    Regex.match?(multipleOf3Regex(), value)
  end
end
