class CachedArray
  include Enumerable
  
  def initialize(key)
    @key = key
    @cache = Rails.cache
    @data = @cache.fetch(key){ Array.new }
  end
  
  def push(data)
    @data = @data + [data]
    write
  end
  
  def clear
    @data = nil
    @cache.delete @key
  end
  
  def delete(data)
    @data = @data - [data]
write  end
  
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
  
  private
  def write
    @cache.write @key, @data
  end
end

def CachedArray(key)
  CachedArray.new key
end