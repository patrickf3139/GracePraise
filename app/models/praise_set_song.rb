class PraiseSetSong
  include ActiveModel::Model

  attr_accessor :id, :key

  def initialize(id, key)
    @id = id
    @key = key
  end

  class ArraySerializer
    def self.load(array)
      if array.kind_of?(Array)
        array.map do |pss_json|
          PraiseSetSong.new(pss_json.id, pss_json.key)
        end
      else
        raise ArgumentError, "was expecting argument to be an Array but got a #{array.class} instead"
      end
    end

    def self.dump(array)
      array.map { |pss| pss.serializable_hash }
    end
  end

end