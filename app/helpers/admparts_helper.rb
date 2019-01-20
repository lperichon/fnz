module AdmpartsHelper

  def pm(number)
    number_with_precision number, precision: 2
  end
end
