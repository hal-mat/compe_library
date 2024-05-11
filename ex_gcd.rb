ex_gcd = lambda do |x, y|
  raise StandardError if y == 0

  tmp_div, tmp_mod = x.divmod y
  return [1, -tmp_div + 1, y] if tmp_mod == 0

  coefficient_y, coefficient_tmp_mod, final_mod = ex_gcd.call(y, tmp_mod)
  [coefficient_tmp_mod, coefficient_y - (coefficient_tmp_mod * tmp_div), final_mod]
end
