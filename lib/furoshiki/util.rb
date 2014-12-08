module Furoshiki
  module Util
    # Ensure symbol keys, even in nested hashes
    #
    # @param [Hash] config the hash to set (key: value) on
    # @param [#to_sym] k the key
    # @param [Object] v the value
    # @return [Hash] an updated hash
    def deep_set_symbol_key(config, k, v)
      if v.kind_of? Hash
        config[k.to_sym] = v.inject({}) { |hash, (k, v)| deep_set_symbol_key(hash, k, v) }
      else
        config[k.to_sym] = v
      end
      config
    end

    def deep_symbolize_keys(hash, defaults = {})
      hash.inject(defaults) { |symbolized, (k, v)| deep_set_symbol_key(symbolized, k, v) }
    end
  end
end
