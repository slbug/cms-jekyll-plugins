class Array
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

class DataStorage
  attr_reader :collection

  def initialize(models, definitions)
    @collection = {}

    models_path = File.expand_path("../../_data/_models", __FILE__)
    models.each do |model_name, model_data|
      Dir.chdir("#{models_path}/#{model_name}") do
        raise "_data/_models/#{model_name} contains subdirectories" if Dir.glob('*').any?{|f| File.directory? f }
      end
      collection[model_name] = model_data.map{|d| DataObject.new(d, definitions[model_name] || {}, self) }
    end
  end

  def method_missing(name, *arguments, &block)
    if name.to_s =~ /find_(\w+)_by_(\w+)/ && !collection[$1].nil?
      keys = Array.wrap(arguments.first)
      keys.size == 1 ? find($1, $2, keys).first : find($1, $2, keys)
    elsif !collection[name.to_s].nil?
      collection[name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    !collection[name.to_s].nil? || (name.to_s =~ /find_(\w+)_by_(\w+)/ && !collection[$1].nil?) || super
  end

  def to_liquid
    self
  end

  def [](property)
    send(property)
  end

  def has_key?(property)
    collection.has_key?(property)
  end

  private
    def find(name, key, param)
      collection[name].select{|obj| obj.match?(key, param) }
    end
end
