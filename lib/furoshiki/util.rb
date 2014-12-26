module Furoshiki
  module Util
    # Ensure symbol keys, even in nested hashes
    #
    # @param [Hash] config the hash to set (key: value) on
    # @param [#to_sym] k the key
    # @param [Object] v the value
    # @return [Hash] an updated hash
    def deep_set_symbol_key(hash, key, value)
      if value.kind_of? Hash
        hash[key.to_sym] = value.inject({}) { |inner_hash, (inner_key, inner_value)| deep_set_symbol_key(inner_hash, inner_key, inner_value) }
      else
        hash[key.to_sym] = value
      end
      hash
    end

    def deep_symbolize_keys(hash)
      merge_with_symbolized_keys({}, hash)
    end

    # Assumes that defaults already has symbolized keys
    def merge_with_symbolized_keys(defaults, hash)
      hash.inject(defaults) { |symbolized, (k, v)| deep_set_symbol_key(symbolized, k, v) }
    end
  end
end
