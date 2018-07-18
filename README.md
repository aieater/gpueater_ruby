# GPUEater API Console

## Getting Started
GPUEater is a cloud computing service focusing on Machine Learning and Deep Learning. Now, AMD Radeon GPUs and NVIDIA Quadro GPUs are available.

This document is intended to describe how to set up this API and how to control your instances through this API.

Before getting started, register your account on GPUEater.
https://www.gpueater.com/

### Prerequisites
1. Ruby 2.x is required to run GPUEater API Console.
2. Create a JSON file in accordance with the following instruction.

At first, open your account page(https://www.gpueater.com/console/account) and copy your access_token. The next, create a JSON file on ~/.eater

```
{
        "gpueater": {
                "access_token":"[YourAccessToken]",
                "secret_token":"[YourSecretToken]"
        }
}
```

or

```
{
        "gpueater": {
                "email":"[YourEmail]",
                "password":"[YourPassword]"
        }
}
```
* At this time, permission control for each token is not available. Still in development.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gpueater'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gpueater


## Run GPUEater API

Before launching an instance, you need to decide product, ssh key, OS image. Get each info with the following APIs.

#### Get available on-demand product list

This API returns current available on-demand products.
```
require('gpueater')

g = GPUEater.new
puts g.ondemand_list()
```
#### Get registered ssh key list

This API returns your registered ssh keys.
```
require('gpueater')

g = GPUEater.new
puts g.ssh_keys()
```

#### Get OS image list

This API returns available OS images.
```
require('gpueater')

g = GPUEater.new
puts g.image_list()
```

#### Instance launch

Specify product, OS image, and ssh_key for instance launching.

```
require('gpueater')

g = GPUEater.new
res = g.ondemand_list()

image = res.find_image('Ubuntu16.04 x64')
ssh_key = res.find_ssh_key('[Your ssh key]')
product = res.find_product('a1.rx580')

param = {
    'product_id' => product['id'],
    'image' => image['alias'],
    'ssh_key_id' => ssh_key['id'],
    'tag' => 'HappyGPUProgramming'
}

res = g.launch_ondemand_instance(param)
puts res
```
In the event, the request has succeeded, then the API returns the following empty data.
{data:null, error:null}

In the event, errors occurred during the instance instantiation process, then the API returns details about the error.

#### Launched instance list

This API returns your launched instance info.
```
require('gpueater')

g = GPUEater.new
res = g.instance_list()
```
#### Terminate instance

Before terminating an instance, get instance info through instance list API. Your instance_id and machine_resource_id are needed to terminate.

```
require('gpueater')

g = GPUEater.new
res = g.instance_list()
res.select{|e| e['tag'] == 'HappyGPUProgramming' }.each{|e|
	puts g.terminate_instance(e)
}
```

-----


#### API list

##### Image
- image_list
- ~~snapshot_instance(form)~~
- ~~delete_snapshot(form)~~
- ~~create_image(form)~~
- ~~register_image(form)~~
- ~~delete_image(form)~~

##### SSH Key
- ssh_key_list
- generate_ssh_key
- register_ssh_key(form)
- delete_ssh_key(form)

##### Instance
- ondemand_list
- ~~subscription_list~~
- launch_ondemand_instance(form)
- ~~launch_subcription_instance(form)~~
- instance_list
- change_instance_tag(form)
- start_instance(form)
- stop_instance(form)
- restart_instance(form)
- terminate_instance(form)
- emergency_restart_instance(form)

##### Network
- port_list
- open_port(form)
- close_port(form)
- renew_ipv4(form)
- refresh_ipv4(form)
- network_description(form)

##### Storage
- ~~create_volume(form)~~
- ~~delete_volume(form)~~
- ~~transfer_volume(form)~~

##### Subscription
- ~~subscription_instance_list~~
- ~~subscription_storage_list~~
- ~~subscription_network_list~~
- ~~subscribe_instance(form)~~
- ~~unsubscribe_instance(form)~~
- ~~subscribe_storage(form)~~
- ~~unsubscribe_storage(form)~~
- ~~subscribe_network(form)~~
- ~~unsubscribe_network(form)~~

##### Special
- ~~live_migration(form)~~
- ~~cancel_transaction(form)~~

##### Payment
- invoice_list
- ~~subscription_invoice_list~~
- ~~make_invoice(form)~~

##### Extensions
- ~~copy_file(form)~~
- ~~delete_file(form)~~
- ~~move_file(form)~~
- ~~make_directory(form)~~
- ~~file_list(form)~~
- ~~synchronize_files(form)~~
- ~~login_instance(form)~~
- ~~tunnel(form)~~

##### Instanciate
- new



## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details
