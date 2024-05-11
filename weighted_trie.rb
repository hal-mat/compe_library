# use array instead of hash, if you don't need debug
weighted_trie = { 0 => 0 }
WEIGHTED_TRIE_ADD_LAMBDA = lambda do |bytes|
  weighted_trie[0] += 1
  tmp_trie = weighted_trie
  bytes.each do |byte|
    tmp_trie[byte] ||= { 0 => 0 }
    tmp_trie = tmp_trie[byte]
    tmp_trie[0] += 1
  end
end
