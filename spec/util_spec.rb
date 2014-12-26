require_relative 'spec_helper'

describe "Utility functions" do
  let(:utils) { Object.new.extend(Furoshiki::Util) }
  let(:hash_with_string_keys) {
    {
      'one' => 1,
      :two => 2,
      'three' => {
        'a' => 'apple',
        :b => 'banana',
        'c' => :cantaloupe
      }
    }
  }
  let(:hash_with_symbolized_keys) {
    {
      :one => 1,
      :two => 2,
      :three => {
        :a => 'apple',
        :b => 'banana',
        :c => :cantaloupe
      }
    }
  }
  let(:hash_of_defaults) {
    {
      :one => 'uno',
      :three => 'tres',
      :four => 'cuatro'
    }
  }
  let(:merged_hash_with_symbolized_keys) {
    {
      :one => 1,
      :two => 2,
      :three => {
        :a => 'apple',
        :b => 'banana',
        :c => :cantaloupe
      },
      :four => 'cuatro'
    }
  }

  it "symbolizes hash keys" do
    symbolized = utils.deep_symbolize_keys(hash_with_string_keys)
    expect(symbolized).to eq(hash_with_symbolized_keys)
  end

  it "merges with hash of defaults" do 
    merged = utils.merge_with_symbolized_keys(hash_of_defaults, hash_with_string_keys)
    expect(merged).to eq(merged_hash_with_symbolized_keys)
  end

end
