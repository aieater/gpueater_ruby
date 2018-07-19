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
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v0.8  |  image_list()  |  | Listing OS images. |
|  v1.5  |  snapshot_instance(form)  | instance_id, machine_resource_id |  Take a snapshot from instance. |
|  v1.5  |  delete_snapshot(form)  | instance_id, machine_resource_id |  Delete a snapshot. |
|  v1.5  |  create_image(form)  | instance_id, machine_resource_id |  Create an user defined default OS image from instance. |
|  v2.0  |  register_image(form)  | url |  Register an other image from internet. |
|  v1.5  |  delete_image(form)  | image |  Delete a registered image. |


##### SSH Key
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v0.8  |  ssh_key_list()  |  |  Listing registered ssh keys. |
|  v1.0  |  generate_ssh_key()  |  |  Generate SSH key pair. This API just generate, so you have to register after this. |
|  v1.0  |  register_ssh_key(form)  | name, public_key |  Register a SSH key. |
|  v1.0  |  delete_ssh_key(form)  | id |  Delete a registered SSH key. |



##### Instance
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v0.8  |  ondemand_list()  |  |  Listing on-demand instances. |
|  v2.0  |  subscription_list()  |  |  Listing subscription instances. |
|  v0.8  |  launch_ondemand_instance(form)  | product_id, image, ssh_key_id |  Launch an on-demand instance. |
|  v2.0  |  launch_subcription_instance(form)  | subscription_id, image, ssh_key_id |  Launch an on-demand instance. |
|  v0.8  |  instance_list()  |  |  Listing launched instances. |
|  v1.0  |  change_instance_tag(form)  | instance_id, tag |  Change instance tag. |
|  v1.0  |  start_instance(form)  | instance_id, machine_resource_id |  Start instance. When the instance was already RUNNING, it will be nothing happen. |
|  v1.0  |  stop_instance(form)  | instance_id, machine_resource_id |  Stop instance. When the instance was already STOPPED, it will be nothing happen. |
|  v1.0  |  restart_instance(form)  | instance_id, machine_resource_id |  Restart instance. |
|  v0.8  |  terminate_instance(form)  | instance_id, machine_resource_id |  Terminate instance. |
|  v1.0  |  emergency_restart_instance(form)  | instance_id, machine_resource_id |  If communication with the GPU becomes impossible, we provide a function for emergency restart. |

machine_resource_id is including instance object, you don't need to mind the parameters.

Example:
```

instance = g.instance_list()[0]
# instance object has instance_id, and machine_resource_id.

g.terminate_instance(instance)

```

##### Network
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v1.0  |  port_list(form)  | instance_id |  Listing ports. |
|  v1.0  |  open_port(form)  | instance_id, connection_id, port |  Forward a specified port. |
|  v1.0  |  close_port(form)  | instance_id, connection_id, port |  Close a specified port. |
|  v1.0  |  renew_ipv4(form)  | instance_id |  Get a new IPv4, and assign to instance. |
|  v1.0  |  refresh_ipv4(form)  | instance_id |  Rebuild port mappings. |
|  v1.0  |  network_description(form)  | instance_id |  This API reports some network status. |

##### Storage
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v2.0  |  create_volume(form)  | size |  Create a extended volume. |
|  v2.0  |  attach_volume(form)  | volume_id, instance_id |  Attach a extended volume to specified instance. |
|  v2.0  |  delete_volume(form)  | volume_id |  Delete a extended volume. |
|  v2.0  |  transfer_volume(form)  | volume_id,region_id |  Transfer a volume to other region. |

##### Subscription
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v2.0  |  subscription_instance_list()  |  |  Listing subscription instances. |
|  v2.0  |  subscription_storage_list()  |  |  Listing subscription storages. |
|  v2.0  |  subscription_network_list()  |  |  Listing subscription networks. |
|  v2.0  |  subscribe_instance(form)  | subscription_id |  Subscribe instance product. |
|  v2.0  |  unsubscribe_instance(form)  | subscription_id |  Unsubscribe instance product. |
|  v2.0  |  subscribe_storage(form)  | subscription_id |  Subscribe storage product. |
|  v2.0  |  unsubscribe_storage(form)  | subscription_id |  Unsubscribe storage product. |
|  v2.0  |  subscribe_network(form)  | subscription_id |  Subscribe network product. |
|  v2.0  |  unsubscribe_network(form)  | subscription_id |  Unsubscribe network product. |

##### Special
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v2.5  |  live_migration(form)  | product_id, region_id, connection_id |  Upgrade and downgrade instance type and region. Old instance will be terminated automatically. |
|  v2.5  |  cancel_transaction(form)  | transaction_id |  Cancel any transaction. |
|  v2.5  |  peak_transaction(form)  | transaction_id |  Get a progress of any transaction. |

##### Payment
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v1.0  |  invoice_list()  |  |  Listing invoices of charged. |
|  v2.0  |  subscription_invoice_list()  |  |  Listing subscription invoices. |
|  v1.5  |  make_invoice(form)  | invoice_id |  You can make a invoice document as PDF. |

##### Extensions
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v1.2  |  copy_file(form)  | action, src, dst |  Copy a file. action is "get" or "post". get meaning is remote to local, and post is local to remote. src is source path. dst is destination path. |
|  v1.2  |  delete_file(form)  | src, recursive |  Delete remote file. |
|  v1.2  |  move_file(form)  | action, src, dst |  Move file or directory. action is "get" or "post". get meaning is remote to local, and post is local to remote. src is source path. dst is destination path. |
|  v1.2  |  make_directory(form)  | dst |  Make a directory in remote. |
|  v1.2  |  file_list(form)  | src |  Listing remote files. |
|  v1.2  |  synchronize_files(form)  | action, src, dst |  This API is similar rsync. |
|  v1.2  |  login_instance(form)  | instance_id | Login to specified instance as SSH2 client. |
|  v1.2  |  tunnel(form)  | instance_id, port |  This API provides port tunneling between local and remote. |

##### Class API
|  Version  |  Function  | Required | Description  |
| ---- | ---- | ---- | ---- |
|  v0.8  |  new()  |  |  Instanciate gpueater object. |
|  v0.8  |  flist()  |  |  Lisintg available APIs. |



## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details
