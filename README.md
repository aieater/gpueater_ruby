# GPUEater Console API

## Getting Started
GPUEater is a cloud computing service focusing on Machine Learning and Deep Learning. Now, AMD Radeon GPUs and NVIDIA Quadro GPUs are available. 

This document is intended to describe how to set up this API and how to control your instances through this API.

Before getting started, register your account on GPUEater.
https://www.gpueater.com/

### Prerequisites
1. Ruby 2.x is required to run GPUEater Console API.
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

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details
