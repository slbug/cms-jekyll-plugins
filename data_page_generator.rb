# Generate pages from individual records in yml files
# (c) 2014 Adolfo Villafiorita
# Distributed under the conditions of the MIT License

module Jekyll
  class DataPage < Page
    attr_reader :data_source, :source_path

    def initialize(site, base, dir, data, name, template, source_dir)
      @site = site
      @base = base
      @dir = dir
      @name = sanitize_filename(name) + ".html"
      @data_source = source_dir + '/' + sanitize_filename(name) + '.json'
      @source_path = '_layouts/' + template + '.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template + ".html")
      self.data.merge!(data)
      self.data['title'] ||= name
      permalink = self.data['permalink']

      if permalink && !(permalink.end_with?('/') || permalink.end_with?('.html'))
        p "Permalink #{permalink} is invalid. Must ends with '/' or html extension"
        self.data['permalink'] += '.html'
      end
    end

    private
      # strip characters and whitespace to create valid filenames, also lowercase
      def sanitize_filename(name)
        return name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      end
  end

  class DataPagesGenerator < Generator
    safe true

    def generate(site)
      data = site.config['page_gen']

      if data
        data.each do |data_spec|
          # todo: check input data correctness
          template = data_spec['template'] || data_spec['data']
          dir = data_spec['dir'] || data_spec['data']

          if site.layouts.key? template
            records = site.data['_models'].send(data_spec['data'])
            records.each do |record|
              page = DataPage.new(site, site.source, dir, record.data, record.id, template, data_spec['data'])
              site.pages << page
            end
          else
            puts "error. could not find template #{template}"
          end
        end
      end
    end
  end
end

