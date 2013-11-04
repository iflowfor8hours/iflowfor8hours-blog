---
title: Vagrant, chef-solo, and databags learning experience
layout: post
---

I've never had to use databags before in chef-solo, but this past week I needed to do some exploration with the [opscode squid cookbook](https://github.com/opscode-cookbooks/squid). Aside from the [opscode databag docs](http://docs.opscode.com/essentials_data_bags.html), I couldn't find much good information on it, so here goes. 
### Vagrant
This part is straightforward. Just add a directory where your Vagrantfile lives and then include a databags_path in your provisioning block. 

	config.vm.provision :chef_solo do |chef|
	  chef.data_bags_path = "data_bags"

	  chef.run_list = [
	    "recipe[rubygems_proxy::default]"
	  ]
	end
### Databag structure
Databags must be in a directory with a name matching the databag. Each individual databag must be a json file, the only requirement being a `id` element. The (truncated for clarity) directory structure looks like:

	.
	|-- Berksfile
	|-- cookbooks
	|   `-- squid
	|-- data_bags
	|   |-- squid_acl_actions
	|   |   `-- rubygems.json
	|   `-- squid_hosts
	|       |-- everythingelse.json
	|       `-- rubygems.json
	`-- Vagrantfile
### Databag items
Databag items themselves, as mentioned above, only need to contain an `id` element to be considered valid. 

	{                                                                                  
	  "type": "dstdomain", 
	  "id": "everythingelse",
	  "net": [
	    "all"
	  ]
	} 

### Using Databags
In the squid cookbook, databags are used to describe ACL rules and hosts which are retrieved using a library. To access  them in your recipes (or libraries or resources), use the `data_bag()` method. In a chef server and chef client environment, you can leverage `search()`, but this is not available in chef-solo out of the box.

	def squid_load_host_acl
	  host_acl.push [group['id'],group['type'],host]
	      end
	    end
	  rescue
	    Chef::Log.info "no 'squid_hosts' data bag"
	  end
	  host_acl
	end

I hope this helps get started with databags, chef-solo, and vagrant. 