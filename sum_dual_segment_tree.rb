# https://atcoder.jp/contests/abc340/submissions/50189319
# 名前通り現在はsumのみ。いつかmin,max,lcmに対応させる
class SumDualSegmentTree
  attr_reader :tree

  def initialize(raw_array)
    @size = raw_array.size
    @size.freeze
    @leaf_begin_index = 1 << (@size - 1).bit_length
    @leaf_begin_index.freeze
    @tree = Array.new(@leaf_begin_index, 0).concat raw_array
  end

  def add(raw_l_index, raw_r_index, add_value)
    tmp_seg_l_index = (raw_l_index | @leaf_begin_index) << 1
    tmp_seg_r_index = (raw_r_index + @leaf_begin_index) << 1 # raw_r_indexは@leaf_begin_indexと一致する事があるので、or演算不可
    while (tmp_seg_l_index >>= 1) < (tmp_seg_r_index >>= 1)
      @tree[tmp_seg_r_index ^ 1] += add_value if tmp_seg_r_index[0] == 1
      next if tmp_seg_l_index[0] == 0

      @tree[tmp_seg_l_index] += add_value
      tmp_seg_l_index += 1
    end
  end

  def [](raw_index)
    tmp_seg_index = (raw_index | @leaf_begin_index)
    merged_value = @tree[tmp_seg_index]
    # 更新すると却って遅い。配列を更新しない方が早い
    merged_value += @tree[tmp_seg_index] while (tmp_seg_index >>= 1) > 0
    merged_value
  end

  def raw_array
    # 更新すると却って遅い。配列を更新しない方が早い
    Array.new(@size) { |i| self[i] }
  end

  def []=(raw_index, new_value)
    tmp_value = self[raw_index]
    diff = new_value - tmp_value
    @tree[raw_index | @leaf_begin_index] += diff
  end
end
