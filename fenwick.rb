# 変更した際は以下の問題で転倒数がバグってないか確認！
# https://atcoder.jp/contests/abc264/tasks/abc264_d
class FenwickTree
  # ref:https://github.com/universato/ac-library-rb/blob/main/lib/fenwick_tree.rb
  # fenwick木は1-indexedなので先頭は使わない
  # https://algo-logic.info/binary-indexed-tree/
  # https://qiita.com/DaikiSuyama/items/7295f5160a51684554a7

  attr_reader :tree

  def initialize(raw_array, element = 0)
    @tree = [nil].concat raw_array
    @element = element.freeze
    @tree.each_with_index do |v, i|
      next if i == 0

      # 最下位の1を繰り上げる
      tmp_index = i + (i & -i)
      @tree[tmp_index] = merge_value(v, @tree[tmp_index]) if tmp_index < @tree.size
    end
  end

  def add(index, value = 1)
    raise StandardError if index < 0

    tmp_index = index + 1
    while tmp_index < @tree.size
      @tree[tmp_index] = merge_value(value, @tree[tmp_index])
      # 最下位の1を繰り上げる
      tmp_index += (tmp_index & -tmp_index)
    end
  end

  # lower_boundと似たような計算。いつか一本化する
  def find_mex
    buffer_answer = 0
    tmp_right = min_expo_over(@tree.size - 1)

    while (tmp_right >>= 1) > 0
      if buffer_answer + tmp_right < (@tree.size - 1) && self[buffer_answer + tmp_right] == tmp_right
        buffer_answer += tmp_right
      end
    end

    buffer_answer
  end

  def all_sum
    left_sum(size - 1)
  end

  def left_sum(raw_index)
    return @element if raw_index < 0

    tree_index = raw_index + 1
    res = @tree[tree_index]
    while (tree_index &= tree_index - 1) > 0
      # res += self[tree_index].to_i
      res = merge_value(res, @tree[tree_index])
      # 最下位の1を払う
    end
    res
  end

  # left_sum(a) >= under_borderとなるような最小のa
  # https://algo-logic.info/binary-indexed-tree/#toc_id_1_2
  def lower_bound(under_border)
    return -1 if under_border <= 0

    buffer_under_border = under_border
    buffer_answer = 0
    tmp_right = min_expo_over(@tree.size - 1)
    while (tmp_right >>= 1) > 0
      # まだ足せる場合
      if buffer_answer + tmp_right <= (@tree.size - 1) && (self[buffer_answer + tmp_right] ||= 0) < buffer_under_border
        buffer_under_border -= self[(buffer_answer += tmp_right)]
      end
    end
    buffer_answer + 1
  end

  # arg以上の2のべき乗
  def min_expo_over(arg)
    answer = 1
    # bit_lengthよりこっちの方が早い
    answer <<= 1 while answer <= arg
    answer
  end

  def sum_between(left_raw_index, right_raw_index)
    purge_value(left_sum(right_raw_index), left_sum(left_raw_index - 1))
  end

  def [](raw_index)
    purge_value(left_sum(raw_index), left_sum(raw_index - 1))
  end

  # 書き換えその1
  def merge_value(value_a, value_b)
    value_a + value_b
  end

  # 書き換えその2
  def purge_value(merged_value, part_value)
    merged_value - part_value
  end

  private :min_expo_over, :merge_value, :purge_value
end
