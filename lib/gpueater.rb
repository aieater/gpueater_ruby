require "gpueater/version"
require 'faraday' # gem install net-http-persistent faraday
require 'tmpdir'
require 'json'


module GPUEater
  class APIv1
    def initialize
      @base = 'https://www.gpueater.com'
      if ENV['GPUEATER_URL']
        @base = ENV['GPUEATER_URL']
      end

      @homedir     = File.expand_path('~')
      @tmpdir      = Dir.tmpdir
      @cookie_path = File.join(@tmpdir,"gpueater_cookie.txt")

      @g_config = {}
      @g_header = {'User-Agent':'RubyAPI'}
      @conn = Faraday::Connection.new(:url => @base) do |builder|
        builder.use Faraday::Request::UrlEncoded
        # builder.use Faraday::Response::Logger
        builder.use Faraday::Adapter::NetHttpPersistent # gem install net-http-persistent
      end
      
      begin
        @g_config = JSON.load(open(".eater").read)
      rescue
        @g_config = JSON.load(open(File.join(@homedir,".eater")).read)
      end

      begin
       @g_header['cookie'] = open(@cookie_path).read
      rescue => e
      end
    end


    def _get(u,q={})
      response = @conn.get do |req|
        req.url u
        @g_header.each{|k,v| req.headers[k] = v }
      end
      return response
    end
    
    def _post(u,form)
      response = @conn.post do |req|
        p u
        p @g_header
        p form
        req.url u
        @g_header.each{|k,v| req.headers[k] = v }
        req.body = form
      end
      return response
    end

    def relogin
      res = _post('/api_login',{'email':@g_config['gpueater']['email'],'password':@g_config['gpueater']['password']})
      @g_header['cookie'] = res.headers['set-cookie']
      f = open(@cookie_path,"w")
      f.write(@g_header['cookie'])
      f.close
    end

    class ProductsResnpose
      attr_accessor :images
      attr_accessor :ssh_keys
      attr_accessor :products
      def initialize(j)
        @images = j['data']['images']
        @ssh_keys = j['data']['ssh_keys']
        @products = j['data']['products']
      end
      def find_image(n)
        @images.values.select{|v| v['name'] == n }.pop
      end
      def find_ssh_key(n)
        @ssh_keys.select{|v| v['name'] == n }.pop
      end
      def find_product(n)
        @products.select{|v| v['name'] == n }.pop
      end
    end

    def instance_list
      j = nil
      begin
        j = JSON.load(_get('/console/servers/instance_list').body)
      rescue
        relogin
        return instance_list
      end
      return j['data']
    end

    def image_list
      j = nil
      begin
        j = JSON.load(_get('/console/servers/images').body)
      rescue
        relogin
        return image_list
      end
      return j['data']
    end
  
    def ssh_key_list
      j = nil
      begin
        j = JSON.load(_get('/console/servers/ssh_key_list').body)
      rescue
        relogin
        return ssh_key_list
      end
      return j['data']
    end

    def ondemand_list
      j = nil
      begin
        j = JSON.load(_get('/console/servers/ondemand_launch_list').body)
      rescue
        relogin
        return ondemand_list
      end
      return ProductsResnpose.new(j)
    end

    def launch_ondemand_instance(form)
      j = nil
      unless form['tag']
        form['tag'] = ""
      end
      raise "required product_id" unless form['product_id']
      raise "required image" unless form['image']
      raise "required ssh_key_id" unless form['ssh_key_id']

      begin
        j = JSON.load(_post('/console/servers/launch_ondemand_instance',form).body)
      rescue
        relogin
        return launch_ondemand_instance
      end
      return j
    end

    def terminate_instance(form)
      j = nil
      raise "required instance_id" unless form['instance_id']
      raise "required machine_resource_id" unless form['machine_resource_id']
      unless form['tag']
        form['tag'] = ""
      end

      begin
        arr = [{'instance_id'=>form['instance_id'],'machine_resource_id'=>form['machine_resource_id']}]
        j = JSON.load(_post('/console/servers/force_terminate',{'instances'=>arr.to_json}).body)
      rescue
        relogin
        return terminate(form)
      end
      return j
    end
    
  end
   
  def self.new
    return APIv1.new
  end

end
