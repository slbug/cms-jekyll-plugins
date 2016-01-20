require 'json'

module Jekyll
  class DataReader
    alias_method :read_orig, :read

    def read(dir)
      read_orig(dir)
      @locale = @site.active_lang
      @default_locale = @site.default_lang

      @content = assign_associations(translate_data(@content, @locale, @default_locale)).tap do |content|
        content['_models'] = convert_models(content['_models'])
      end
    end

    def convert_models(models)
      data_pages = @site.config['page_gen'].map{|p| p['data'] }

      models.each do |model, values|
        if values.kind_of?(Hash) && !data_pages.include?(model)
          models[model] = [].tap do |content|
            values.keys.map(&:to_i).sort.each do |key|
              content << values[key.to_s].tap{|val| val['id'] = key }
            end
          end
        end
      end

      models
    end
  end
end

