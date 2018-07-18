require "gpueater/version"
require 'faraday' # gem install net-http-persistent faraday
require 'tmpdir'
require 'json'
require 'fileutils'


module GPUEater
  class APIv1
    def initialize
      @debug = true
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
      @alist=["raccoon", "dog", "wild boar", "rabbit", "cow", "horse", "wolf", "hippopotamus", "kangaroo", "fox", "giraffe", "bear", "koala", "bat", "gorilla", "rhinoceros", "monkey", "deer", "zebra", "jaguar", "polar bear", "skunk", "elephant", "raccoon dog", "animal", "reindeer", "rat", "tiger", "cat", "mouse", "buffalo", "hamster", "panda", "sheep", "leopard", "pig", "mole", "goat", "lion", "camel", "squirrel", "donkey"]
      @blist=["happy", "glad", "comfortable", "pleased", "delighted", "relieved", "calm", "surprised", "exciting"]
      
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
      puts u if @debug
      response = @conn.get do |req|
        req.url u
        @g_header.each{|k,v|
          if v
            req.headers[k] = v
          end
        }
      end
      return response
    end
    
    def _post(u,form)
      puts u if @debug
      response = @conn.post do |req|
        req.url u
        @g_header.each{|k,v|
          if v
            req.headers[k] = v
          end
        }
        req.body = form
      end
      return response
    end

    def relogin
      res = _post('/api_login',{'email':@g_config['gpueater']['email'],'password':@g_config['gpueater']['password']})
      if res.headers['set-cookie']
        @g_header['cookie'] = res.headers['set-cookie']
        f = open(@cookie_path,"w")
        f.write(@g_header['cookie'])
        f.close
      end
    end

    class ProductsResnpose
      attr_accessor :images
      attr_accessor :ssh_keys
      attr_accessor :products
      def initialize(j)
        @images = j['images']
        @ssh_keys = j['ssh_keys']
        @products = j['products']
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
    
    
    
    def func_get(api,required_fields=[],query={}, e=nil, try=2)
      raise e if try <= 0
      required_fields.each{|v| raise "Required field => #{v}" unless form.include?(v) }
      j = nil
      begin
        j = JSON.load(_get(api).body)
      rescue => e
        relogin
        return func_get(api, required_fields, query, e, try-1)
      end
      raise j['error'] if j['error']
      j['data']
    end

    def func_post(api,required_fields=[],form={}, e=nil, try=2)
      raise e if try <= 0
      required_fields.each{|v| raise "Required field => #{v}" unless form.include?(v) }
      j = nil
      begin
        j = JSON.load(_post(api,form).body)
      rescue => e
        relogin
        return func_post(api, required_fields, form, e, try-1)
      end
      raise j['error'] if j['error']
      j['data']
    end
    
    def func_post_inss(api,required_fields=[],form={}, e=nil, try=2)
      raise e if try <= 0
      required_fields.each{|v| raise "Required field => #{v}" unless form.include?(v) }
      form["instances"] = [{"instance_id"=>form["instance_id"],"machine_resource_id"=>form["machine_resource_id"]}].to_json;
      j = nil
      begin
        j = JSON.load(_post(api,form).body)
      rescue => e
        relogin
        return func_post(api, required_fields, form, e, try-1)
      end
      raise j['error'] if j['error']
      j['data']
    end
    
    # def func_post_launch(api,required_fields=[],form={}, e=nil, try=2)
    #   raise e if try <= 0
    #   tag = form['tag']
    #   unless tag
    #     form['tag'] = @alist[((rand()*100) % @alist.length).to_i] +"-"+@blist[((rand()*100) % @blist.length).to_i]
    #   end
    #   required_fields.each{|v| raise "Required field => #{v}" unless form.include?(v) }
    #   image = form['image']
    #   ssh_key_id = form['ssh_key_id']
    #   product_id = form['product_id']
    #   unless image.kind_of?(String)
    #   end
    #
    #   j = nil
    #   begin
    #     j = JSON.load(_post(api,form).body)
    #   rescue => e
    #     relogin
    #     return func_post(api, required_fields, form, e, try-1)
    #   end
    #   raise j['error'] if j['error']
    #   j['data']
    # end
    
    def ___________image___________;end #@
    def image_list; func_get('/console/servers/images'); end #@
    def snapshot_instance; raise "Not implemented yet"; end #@
    def delete_snapshot; raise "Not implemented yet"; end #@
    def create_image; raise "Not implemented yet"; end #@
    def register_image; raise "Not implemented yet"; end #@
    def delete_image; raise "Not implemented yet"; end #@
    
    
    def ___________ssh_key___________;end #@
    def ssh_key_list;             func_get('/console/servers/ssh_keys'); end #@
    def generate_ssh_key;         func_get('/console/servers/ssh_key_gen'); end #@
    def register_ssh_key(form);   func_post('/console/servers/register_ssh_key',['name','public_key'],form); end #@
    def delete_ssh_key(form);     func_post('/console/servers/delete_ssh_key',['id'],form); end #@

    def ___________instance___________;end #@
    def ondemand_list; ProductsResnpose.new(func_get('/console/servers/ondemand_launch_list')); end #@
    def subscription_list;                  raise "Not implemented yet"; end #@
    def launch_ondemand_instance(form);     func_post('/console/servers/launch_ondemand_instance',['product_id','image','ssh_key_id','tag'],form); end #@
    def launch_subcription_instance(form);  raise "Not implemented yet"; end #@
    def instance_list;                      func_get('/console/servers/instance_list'); end #@
    def change_instance_tag(form);          func_post('/console/servers/change_instance_tag',['instance_id','tag'],form); end #@
    def start_instance(form);               func_post_inss('/console/servers/start',['instance_id','machine_resource_id'],form); end #@
    def stop_instance(form);                func_post_inss('/console/servers/stop',['instance_id','machine_resource_id'],form); end #@
    def restart_instance(form);             func_post_inss('/console/servers/stop',['instance_id','machine_resource_id'],form); func_post_inss('/console/servers/start',['instance_id','machine_resource_id'],form); end #@
    def terminate_instance(form);           func_post_inss('/console/servers/force_terminate',['instance_id','machine_resource_id'],form); end #@
    def emergency_restart_instance(form);   func_post_inss('/console/servers/emergency_restart',['instance_id','machine_resource_id'],form); end #@
    
    
    def test
      pd = ondemand_list
      image = pd.find_image "Ubuntu16.04 x64"
      ssh_key = pd.find_ssh_key "my_ssh_key2"
      product = pd.find_product "n1.p400"
      
      emergency_restart_instance(instance_list[0]);
      p image
      p ssh_key["id"]
      p product["id"]
      
      #launch_ondemand_instance({"tag"=>"ponkoponko","product_id"=>product["id"], "ssh_key_id"=>ssh_key["id"], "image" => image["alias"]});
      
      
      
      def ssh_key_test
        key = generate_ssh_key
        keyname = 'my_ssh_key2'
        ssh_key_list().select{|e| delete_ssh_key(e) if e["name"] == keyname }
        register_ssh_key({"name"=>keyname,"public_key"=>key["public_key"]})
        pem = File.join(@homedir,'.ssh',keyname+".pem")
        fp = open(pem,"w")
        fp.write(key["private_key"])
        fp.close
        FileUtils.chmod(0600,pem)
        puts ssh_key_list
      end
    end
  end
    
    
    def __________network__________;end #@
    def port_list;                      func_get('/console/servers/port_list'); end #@
    def open_port(form);                func_post('/console/servers/add_port',['instance_id','connection_id','port'],form); end #@
    def close_port(form);               func_post('/console/servers/delete_port',['instance_id','connection_id','port'],form); end #@
    def renew_ipv4(form);               func_post('/console/servers/renew_ipv4',['instance_id'],form); end #@
    def refresh_ipv4(form);             func_post('/console/servers/refresh_ipv4',['instance_id'],form); end #@
    def network_description(form);      func_get('/console/servers/instance_info',['instance_id'],form); end #@
    
    
    def __________storage__________;end #@
    def create_volume;                  raise "Not implemented yet"; end #@
    def delete_volume;                  raise "Not implemented yet"; end #@
    def transfer_volume;                raise "Not implemented yet"; end #@
    
    def _________subscription__________;end #@
    def subscription_instance_list;                  raise "Not implemented yet"; end #@
    def subscription_storage_list;                  raise "Not implemented yet"; end #@
    def subscription_network_list;                  raise "Not implemented yet"; end #@
    def subscribe_instance;                  raise "Not implemented yet"; end #@
    def unsubscribe_instance;                  raise "Not implemented yet"; end #@
    def subscribe_storage;                  raise "Not implemented yet"; end #@
    def unsubscribe_storage;                  raise "Not implemented yet"; end #@
    def subscribe_network;                  raise "Not implemented yet"; end #@
    def unsubscribe_network;                  raise "Not implemented yet"; end #@
    
    def _________special__________;end #@
    def live_migration;                  raise "Not implemented yet"; end #@
    def cancel_transaction;                  raise "Not implemented yet"; end #@

    def _________payment__________;end #@
    def invoice_list;                  raise "Not implemented yet"; end #@
    def subscription_invoice_list;     raise "Not implemented yet"; end #@
    def make_invoice;                  raise "Not implemented yet"; end #@

    def _________extensions__________;end #@
    def copy_file;                  raise "Not implemented yet"; end #@
    def delete_file;                  raise "Not implemented yet"; end #@
    def move_file;                  raise "Not implemented yet"; end #@
    def make_directory;                  raise "Not implemented yet"; end #@
    def file_list;                  raise "Not implemented yet"; end #@
    def synchronize_files;                  raise "Not implemented yet"; end #@
    def login_instance;                  raise "Not implemented yet"; end #@
    def tunnel;                  raise "Not implemented yet"; end #@
    
    def __________________________;end #@
  


  
  def self.new #@
    return APIv1.new
  end

end

if __FILE__ == $0
  def test
    g = GPUEater.new
    g.test
  end
  def gen
    ret = []
    ret2 = []
    st = open(__FILE__).read
    flg = false
    st.split("\n").each{|e|
      unless flg
        if e.include? "def "
          if e.include? "#@"
            name = e.split("def ")[1].split("#")[0].split("(")[0].strip
            name = name.gsub("self.","")
            name = name.split(";")[0]
            ret += ["# " + name]
          end
        end
        ret2 += [e]
        #puts e
        if e == "##@@ GEN @@##"
          flg = true
        end
      end
    }
  
    st2 = ret2.join("\n")
    fp = open(__FILE__,"w")
    fp.write(st2)
    fp.write("\n")
    fp.write(ret.join("\n"))
    fp.close
  end
end


##@@ GEN @@##
# ___________image___________
# image_list
# snapshot_instance
# delete_snapshot
# create_image
# register_image
# delete_image
# ___________ssh_key___________
# ssh_key_list
# generate_ssh_key
# register_ssh_key
# delete_ssh_key
# ___________instance___________
# ondemand_list
# subscription_list
# launch_ondemand_instance
# launch_subcription_instance
# instance_list
# change_instance_tag
# start_instance
# stop_instance
# restart_instance
# terminate_instance
# emergency_restart_instance
# __________network__________
# port_list
# open_port
# close_port
# renew_ipv4
# refresh_ipv4
# network_description
# __________storage__________
# create_volume
# delete_volume
# transfer_volume
# _________subscription__________
# subscribe_instance_list
# subscribe_storage_list
# subscribe_network_list
# subscribe_instance
# unsubscribe_instance
# subscription_instance_list
# subscribe_instance
# unsubscribe_instance
# subscribe_storage
# unsubscribe_storage
# subscribe_network
# unsubscribe_network
# _________special__________
# live_migration
# cancel_transaction
# _________payment__________
# invoice_list
# subscription_invoice_list
# make_invoice
# _________extensions__________
# copy_file
# delete_file
# move_file
# make_directory
# file_list
# synchronize_files
# login_instance
# tunnel
# __________________________
# new