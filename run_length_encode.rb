# stringにincludeして使う
module RunLengthEncode
  def run_length_encode
    bytes_array = self.bytes
    buffer_answer = []
    now_byte = nil
    while (tmp_byte = bytes_array.shift)
      if now_byte
        if now_byte == tmp_byte
          now_count += 1
        else
          buffer_answer << [now_byte, now_count]
          now_byte = tmp_byte
          now_count = 1
        end
      else
        now_byte = tmp_byte
        now_count = 1
      end
    end
    buffer_answer << [now_byte, now_count]
  end
end
