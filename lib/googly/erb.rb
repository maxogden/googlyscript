class Googly

  # Basic support for ERB templates.

  class Erb
    
    include Responses

    def initialize(root)
      @root = root
    end

    def call(env)
      
      path_info = Rack::Utils.unescape(env["PATH_INFO"])

      return forbidden if path_info.include? ".."
      
      template = Errno::ENOENT
      filename = path_info.gsub(/\.html$/, '.erb')
      if filename != path_info
        template = File.read(File.join(@root, filename)) rescue Errno::ENOENT
      end
      if template == Errno::ENOENT
        #TODO Content-Type for non-html
        template = File.read(File.join(@root, path_info + '.erb')) rescue Errno::ENOENT
      end
      if template == Errno::ENOENT
        template = File.read(File.join(@root, path_info + '.html.erb')) rescue Errno::ENOENT
      end
      return not_found if template == Errno::ENOENT

      require 'erb'
      
      body = ::ERB.new(template).result
      [200, {"Content-Type" => "text/html",
         "Content-Length" => body.size.to_s},
       [body]]
    end
    
  end
end
