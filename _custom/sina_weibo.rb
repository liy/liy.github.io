require 'faraday'
require 'yaml'
require 'json'

class SinaWeibo
  def initialize
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../_config.yml'))
    @weibo_config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../_weibo_config.yml'))
  end

  def post
    conn = Faraday.new(url: 'https://api.weibo.com')
    response = conn.post '/2/statuses/update.json', access_token: @weibo_config['access_token'], status: generate_post
    puts JSON.pretty_generate(JSON.parse(response.body))
  end

  private
    def generate_post
      template = @weibo_config['template'].force_encoding('utf-8')
      template %{ post_title: get_post_title, post_url: get_post_url }
    end

    def latest_post_filename
      # get _post directory
      posts_dir = File.expand_path(File.dirname(__FILE__) + '/../_posts')
      markdown_files = Dir.glob(posts_dir + "/*").select { |f| f.match(/\.markdown/) }
      # get the latest modified mardown files from the file list
      markdown_files.max_by { |f| File.mtime(f) }
    end

    def get_post_url
      url = @config['url'] + '/blog/' + File.basename(latest_post_filename, '.markdown').gsub(/\d-/){ |s| s[0] + '/' }
      url.force_encoding('utf-8')
    end

    def get_post_title
      title_line = IO.readlines(latest_post_filename)[2]
      title_line['title: '.length + 1..title_line.length - 3].force_encoding('utf-8')
    end
end

weibo = SinaWeibo.new
weibo.post
