#!/usr/bin/env ruby
$LOAD_PATH.unshift('.')

require 'gpueater'


def clear_instance
  g = GPUEater.new
  ls = g.instance_list
  p ls
  ls.each{|e|
    puts e
    ret = g.terminate_instance(e)
    puts ret
  }
  puts "clear_instance - done"
end

def clear_images
  g = GPUEater.new
  ls = g.registered_image_list
  p ls

  ls.each{|e|
    puts "+++++++++"
    puts e
    ret = g.delete_image(e);
    puts ret
  }
  puts "clear_images - done."
end

def create_test_instance
    g       = GPUEater.new
    ps      = g.ondemand_list()
    image   = ps.find_image("Ubuntu16.04 x64")
    ssh_key = ps.find_ssh_key("guest")
    product = ps.find_product("a1.vegafe")
    ret     = g.launch_ondemand_instance({"tag"=>"test_instance","product_id"=>product["id"], "ssh_key_id"=>ssh_key["id"], "image" => image["alias"]});
    puts ret
end


def test_instance
  puts "------------------------------------------"

  clear_instance()

  create_test_instance()

  clear_instance()

  puts "------------------------------------------"
end


def create_user_defined_image()
    g = GPUEater.new
    puts "registered_image_list"
    p g.registered_image_list()
    ins = g.instance_list().pop()
    puts ins
    ins['image_name'] = 'test_image'
    ret = g.create_image(ins)
    puts ret
end



def test_image
  puts "------------------------------------------"

  clear_images()
  clear_instance()


  g = GPUEater.new
  puts "image_list"
  p g.image_list()

  puts "registered_image_list"
  p g.registered_image_list()

  create_user_defined_image()

  puts "------------------------------------------"
end


create_user_defined_image()

def test_networking
  puts "------------------------------------------"
  puts "Start networking test"
  g = GPUEater.new
  is = g.instance_list()
  if is.length > 0
    ins = g.instance_list()[0]
    puts g.network_description(ins)
    ins['port'] = 9999
    g.open_port(ins)
    puts g.port_list(ins)
    g.close_port(ins)
    puts g.port_list(ins)
  else
    puts "No instance"
  end
  puts "networking test - done."
  puts "------------------------------------------"
end

def test
  pd = ondemand_list
  image = pd.find_image "Ubuntu16.04 x64"
  ssh_key = pd.find_ssh_key "my_ssh_key2"
  product = pd.find_product "n1.p400"

  emergency_restart_instance(instance_list[0]);
  p image
  p ssh_key["id"]
  p product["id"]

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
