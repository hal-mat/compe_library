# 現在は合計しかできない。さらにTLEするためデバッグできているか不明
class LazySegmentTree # rubocop:disable Metrics/ClassLength
  attr_reader :segment_tree, :lazy_tree

  # 根は[1]からスタート
  def initialize(size, element = 0, first_array = nil)
    @size = size.freeze
    @size.freeze
    # 単位元。合計の初期値など
    @element = element
    @element.freeze
    @leaf_begin_index = 1 << @size.bit_length
    @leaf_begin_index.freeze
    @seg_size = @size | @leaf_begin_index
    @seg_size.freeze
    @lazy_tree = Array.new(@leaf_begin_index | @size, @element)
    generate_segment_tree(first_array)
  end

  def generate_segment_tree(first_array)
    return @segment_tree = Array.new(@seg_size, @element) unless first_array

    @segment_tree = Array.new(@leaf_begin_index, @element).concat first_array
    queue = []
    left_i = @leaf_begin_index - 2
    queue << (left_i << 1) while (left_i += 2) < @seg_size
    # queue << [left_i << 1, left_i, left_i | 1] while (left_i += 2) < @size
    while (tmp_top = queue.shift)
      @segment_tree[tmp_top] = merge_value(@segment[tmp_top << 1], @segment[(tmp_top << 1) | 1])
      next if tmp_top[0] == 1

      queue << tmp_top << 1
    end
  end

  private :generate_segment_tree

  # op(a[l], ..., a[r - 1]) を返します。引数は半開区間です
  def prod(arg_l, arg_r)
    # return all_prod if arg_l == 0 && arg_r == @size
    raise StandardError, 'not sorted' if arg_l >= arg_r

    # prod_bottom_up(arg_l | @leaf_begin_index, arg_r | @leaf_begin_index)
    prod_top_down(arg_l | @leaf_begin_index, arg_r | @leaf_begin_index, @leaf_begin_index,
                  (@leaf_begin_index << 1))
  end

  def raw_array!
    lazy_evaluation(1, @leaf_begin_index, (@leaf_begin_index << 1), true)
    @segment_tree[@leaf_begin_index..]
  end

  # add_r, tmp_rともに開区間である
  def add(add_l, add_r, add_value)
    add_seg_l = add_l + @leaf_begin_index
    add_seg_r = add_r + @leaf_begin_index
    # p [add_seg_l, add_seg_r, add_value, 1, @leaf_begin_index, (@leaf_begin_index << 1)]
    private_add(add_seg_l, add_seg_r, add_value, 1, @leaf_begin_index, (@leaf_begin_index << 1))
  end

  def [](leaf_index)
    raise StandardError, 'too large index' if leaf_index >= @size

    prod_top_down(leaf_index | @leaf_begin_index, (leaf_index + 1) | @leaf_begin_index, @leaf_begin_index,
                  (@leaf_begin_index << 1))
  end

  # private

  def private_add(add_seg_l, add_seg_r, add_value, tmp_seg_top, tmp_seg_l, tmp_seg_r) # rubocop:disable Metrics/ParameterLists
    return unless @lazy_tree[tmp_seg_top]

    if add_seg_l <= tmp_seg_l && tmp_seg_r <= add_seg_r
      # 更新する区間が現在のノードの区間に完全に含まれる場合
      # 遅延配列に加算する値を記録し、そのノードを評価
      @lazy_tree[tmp_seg_top] += (tmp_seg_r - tmp_seg_l) * add_value # min,maxに変更する時はここも変更できるように
      lazy_evaluation(tmp_seg_top, tmp_seg_l, tmp_seg_r)
    elsif (tmp_seg_l < add_seg_r) && (add_seg_l < tmp_seg_r)
      # p [add_seg_l, add_seg_r, tmp_seg_l, tmp_seg_r, @segment_tree]
      @segment_tree[tmp_seg_top] =
        add_partial_cover(add_seg_l, add_seg_r, add_value, tmp_seg_top, tmp_seg_l, tmp_seg_r)
    end
    # 更新する区間が現在のノードの区間と交差しない場合は何もしない
  end

  def add_partial_cover(add_seg_l, add_seg_r, add_value, tmp_seg_top, tmp_seg_l, tmp_seg_r) # rubocop:disable Metrics/ParameterLists
    lazy_evaluation(tmp_seg_top, tmp_seg_l, tmp_seg_r)
    # 一部だけ被っている場合は子ノードに対して再帰的に処理
    left_child_index = tmp_seg_top << 1
    private_add(add_seg_l, add_seg_r, add_value, left_child_index, tmp_seg_l, (tmp_seg_l + tmp_seg_r) >> 1)
    left_child_value = @segment_tree[left_child_index]
    return @element unless left_child_value

    right_child_index = left_child_index | 1
    private_add(add_seg_l, add_seg_r, add_value, right_child_index, (tmp_seg_l + tmp_seg_r) >> 1, tmp_seg_r)
    right_child_value = @segment_tree[right_child_index]
    # 子ノードの値を基に現在のノードの値を更新
    right_child_value ? parent_value(left_child_value, right_child_value) : left_child_value
  end

  def parent_value(a_child_value, b_child_value)
    # (a_child_value > b_child_value) ? a_child_value : b_child_value
    (a_child_value + b_child_value)
  end

  def child_lazy_tree_value(parent_value)
    parent_value >> 1
  end

  def lazy_evaluation(tmp_top, tmp_l, tmp_r, recursive = false)
    # return if tmp_l >= @size + @leaf_begin_index

    # 遅延配列に値が入っている場合、その値を使ってノードの値を更新
    lazy_top_value = @lazy_tree[tmp_top]
    return @segment_tree[tmp_top] if lazy_top_value == @element && !recursive

    down_lazy_tree(tmp_top, lazy_top_value) if tmp_r - tmp_l > 1
    #  伝播が終わったので、自ノードの遅延配列を空にする
    @lazy_tree[tmp_top] = @element

    # 最後にセグ木側の値を更新し、値を返す
    @segment_tree[tmp_top] = merge_value(@segment_tree[tmp_top], lazy_top_value) if tmp_top < @seg_size
    return @segment_tree[tmp_top] unless recursive

    tmp_m = (tmp_l + tmp_r) >> 1
    lazy_evaluation(tmp_top << 1, tmp_l, tmp_m, tmp_m - tmp_l > 1)
    lazy_evaluation((tmp_top << 1) | 1, tmp_m, tmp_r, tmp_r - tmp_l > 1) if tmp_m < @seg_size
  end

  def merge_value(a_value, b_value)
    return parent_value(a_value, b_value) if a_value && b_value

    a_value || b_value
  end

  def down_lazy_tree(tmp_top, lazy_top_value)
    #  最下段かどうかのチェックをしよう
    # 子ノードは親ノードの 1/2 の範囲であるため、
    #  伝播させるときは半分にする
    lazy_child_value = child_lazy_tree_value(lazy_top_value)
    @lazy_tree[tmp_top << 1] = merge_value(@lazy_tree[tmp_top << 1], lazy_child_value)
    @lazy_tree[(tmp_top << 1) + 1] = merge_value(@lazy_tree[(tmp_top << 1) | 1], lazy_child_value)
  end

  # 再帰なのに、なぜか早い
  def prod_top_down(seg_l, seg_r, tmp_seg_l, tmp_seg_r)
    return @element if seg_r <= tmp_seg_l || tmp_seg_r <= seg_l

    # 先に@segment_tree[tmp_seg_l >> (tmp_seg_l ^ (tmp_seg_r - 1)).bit_length]を算出して
    # elementと同じならそこでelementを返す仕組みも一度試した
    # かえって遅くなるので削除
    tmp_seg_top = tmp_seg_l >> (tmp_seg_l ^ (tmp_seg_r - 1)).bit_length
    # lazy_evaluationで値が返る
    full_cover_value = lazy_evaluation(tmp_seg_top, tmp_seg_l, tmp_seg_r)
    return full_cover_value if seg_l <= tmp_seg_l && tmp_seg_r <= seg_r

    # lとrの間。mid
    tmp_seg_m = ((tmp_seg_l + tmp_seg_r) >> 1)
    parent_value(prod_top_down(seg_l, seg_r, tmp_seg_l, tmp_seg_m),
                 prod_top_down(seg_l, seg_r, tmp_seg_m, tmp_seg_r))
  end

  private :private_add, :add_partial_cover, :parent_value, :child_lazy_tree_value, :lazy_evaluation, :down_lazy_tree,
          :prod_top_down, :merge_value
end

# debug = true
