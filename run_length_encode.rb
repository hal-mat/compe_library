# stringにincludeして使う
module RunLengthEncodeForString
  def run_length_encode
    buffer_answer = []
    bytes.each do |byte|
      if !buffer_answer.empty? && byte == buffer_answer[-1][0]
        buffer_answer[-1][1] += 1
      else
        buffer_answer << [byte, 1]
      end
    end
    buffer_answer
  end
end

# 数字のみのarrayにincludeして使う
module RunLengthEncodeForArray
  def run_length_encode
    buffer_answer = []
    each do |value|
      if !buffer_answer.empty? && buffer_answer[-1][0] == value
        buffer_answer[-1][1] += 1
      else
        buffer_answer << [value, 1]
      end
    end
    buffer_answer
  end
end
