require 'json'

module Jekyll
  class DataReader
    alias_method :read_orig, :read

    def read(dir)
      read_orig(dir)
      @locale = @site.active_lang
      @default_locale = @site.default_lang

      @content = translate_data(@content, @locale, @default_locale).tap do |content|
        content['_models'] = DataStorage.new(convert_models(content['_models']), content['_definitions'] || {})
      end
    end

    def convert_models(models)
      data_pages = (@site.config['page_gen'] || []).map{|p| p['data'] }

      (models || []).each do |model, values|
        if values.kind_of?(Hash)
          models[model] = [].tap do |content|
            values.keys.each do |key|
              content << values[key.to_s].tap do |val|
                raise "Data file #{key} has id property" if data_pages.include?(model) && !val['id'].nil?
                val['id'] ||= key
              end
            end
          end
        end
      end

      models
    end
  end
end

