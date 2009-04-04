class CachedArray
  include Enumerable
  
  def initialize(key)
    @key = key
    @cache = Rails.cache
    @data = @cache.fetch(key){ Array.new }
  end
  
  def push(data)
    @cache.write(@key, @data + [data] )
  end
  
  def clear
    @data = nil
    @cache.delete @key
  end
  
  def delete(data)
    @data.delete(data)
    @cache.write(@key, @data)
  end
  
  def to_a
    @data.dup
  end
  
  def get_array_and_clear
    tmp = @data.dup
    # self.clear
    @cache.write(@key, []) unless tmp.empty?
    return tmp
  end
  
  def each
    @data.each do |d|
      yield d
    end
  end
end

def CachedArray(key)
  CachedArray.new key
end