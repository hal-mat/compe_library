NODES_COUNT, EDGES_COUNT = gets.split.map(&:to_i) # 配列から多重代入
EDGES = Array.new(EDGES_COUNT) { gets.split.map(&:to_i) }

ADJUST_LIST_LAMBDA = lambda do |need_pred = true|
  buffer_answer = Array.new(NODES_COUNT)
  EDGES.each do |node_a, node_b|
    node_a -= 1 if need_pred
    node_b -= 1 if need_pred
    buffer_answer[node_a] ||= []
    buffer_answer[node_a] << node_b
    buffer_answer[node_b] ||= []
    buffer_answer[node_b] << node_a
  end
  buffer_answer
end

ADJ_LIST = ADJUST_LIST_LAMBDA.call
IS_BIPARTITE = lambda do
  # n = ADJ_LIST.size # ノードの数
  color = []

  # DFS関数
  dfs = lambda do |tmp_node, tmp_color = 0|
    return true unless ADJ_LIST[tmp_node]

    another_color = 1 - tmp_color
    return false if color[tmp_node] == another_color

    color[tmp_node] = tmp_color # ノードに色を割り当てる
    ADJ_LIST[tmp_node].all? do |next_node|
      color[next_node] == another_color || dfs.call(next_node, another_color)
    end
  end

  # すべてのノードに対してDFSを実行（連結でないグラフに対応）
  NODES_COUNT.times.all? do |i|
    # 色が未割り当ての場合のみ初期色を0としてDFSを実行
    color[i] || dfs.call(i)
  end
end
# puts IS_BIPARTITE.call ? 'Yes' : 'No'
