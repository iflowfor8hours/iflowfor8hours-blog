title: Why do we need Chef?
content_class: flexbox vcenter

<pre class="note">
We need to build all this for the app to run.
</pre>

![app stack](images/infrastructure.png)

---

title: Why do we need Chef?
content_class: flexbox vcenter

<pre class="note">
http://en.wikipedia.org/wiki/Software_configuration_management
Repeatable deployments
Consistent deployment across multiple platforms
Avoid snowflake servers
Infrastructure as code

Software Configuration Management concerns itself with answering the question "Somebody did something, how can one reproduce it?"
</pre>

![Blown-up version](images/blowed-up.png)

---

title: Why does Chef do this?
content_class: flexbox vcenter

<pre class="note">
- With Chef, you write abstract definitions as source code to describe how you want each part of your infrastructure to be built, and then apply those descriptions to individual servers.
</pre>

![How it was done, vs now](images/bashvsruby.png)

---

title: What is Chef?
content_class: flexbox vcenter


- Chef is an open-source automation platform built for provisioning servers and automated deployment of applications and services.

---

title: Core components of Chef
content_class: flexbox vcenter

- Chef is made up of a few components
    - Chef Server
    - Chef Client
    - Chef Workstation
    - Chef Solo

---

title: Chef Server
content_class: flexbox vcenter

- Chef server is the component that performs searches across nodes, serves cookbooks to clients, and manages certificates.

![picture of chef](images/chef-architecture.png)

---

title: Chef Client
content_class: flexbox vcenter

<pre class="note">
Chef-client is the actual thing that executes the cookbooks
</pre>

- Chef client communicates with the chef server, authenticates clients, and compiles and executes cookbooks on the clients. 

![picture of chef](images/chef-architecture.png)

---

title: Chef Workstation
content_class: flexbox vcenter

- Chef workstation uses Knife, a command line tool, to manipulate Chef constructs on the Chef Server.

![picture of chef](images/chef-architecture.png)

---

title: Chef Solo
content_class: flexbox vcenter


<pre class="note">
Add picture to show chef-server and chef-client combined with things being thrown out to become chef-solo

To provide the raw execution of cookbook recipes, the complete cookbook needs to be present on the disk.
</pre>

- Chef Solo is a more limited chef client that allows you to run cookbooks without a chef server.

---

title: Cookbooks

<pre class="note">
make this stuff fly in
</pre>

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - Resources
    - Providers
    - Templates
    - Metadata
    - Files 
    - Librares

---

title: Cookbooks

<pre class="note">
make this stuff fly in
</pre>

- Cookbooks are Chef's fundamental units of distribution
    - [Recipes](www.google.com)
    - Attributes
    - Resources
    - Providers
    - Templates
    - Metadata
    - Files 
    - Libraries

---
title: Getting started with recipes

<pre class="note">
sequential
collection of resources
utilizes attributes
</pre>

apache2/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">
  package "apache2"

  template "/etc/apache2/apache2.conf" do 
    user   "www-data"
    group  "www-data"
    mode   node["apache2"]["mode"]
    source "apache2.conf.erb"
  end

  service "apache2" do
    action :enable
  end
</pre>

---

title: Attributes

<pre class="note">
make this stuff fly in
TODO: include Ohai slide
</pre>

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - [Attributes](www.google.com)
    - Resources
    - Providers
    - Templates
    - Metadata
    - Files 
    - Libraries

---

title: Attributes

<pre class="note">
Parameters to recipies 
node specific data
</pre>

apache2/attributes/default.rb

<pre class="prettyprint" data-lang="ruby">
  default["apache2"]["user"] = "www-data"
  default["apache2"]["group"] = "www-data"
  default["apache2"]["mode"] = "0644"
</pre>

---

title: Attributes

<pre class="note">
</pre>

apache2/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">
  package "apache2"

  template "/etc/apache2/apache2.conf" do 
    user   "www-data"
    group  "www-data"<b>
    mode   node["apache2"]["mode"]</b>
    source "apache2.conf.erb"
  end

  service "apache2" do
    action :enable
  end
</pre>

---

title: Resources & Providers

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - [Resources](www.google.com)
    - [Providers](www.google.com)
    - Templates
    - Metadata
    - Files 
    - Libraries
---

title: Resources & Providers

<pre class="note">
zypper, yum, apt, pkg-add, ips
service is running debian upstart vs chkconfig vs redhat service
</pre>

apache2/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">
<b>package "apache2"</b>

  template "/etc/apache2/apache2.conf" do 
    user   "www-data"
    group  "www-data"
    mode   node["apache2"]["mode"]
    source "apache2.conf.erb"
  end

  service "apache2" do
    action :enable
  end
</pre>

---

title: Resources & Providers
content_class: flexbox vcenter

<pre class="note">
zypper, yum, apt, pkg-add, ips
service is running debian upstart vs chkconfig vs redhat service
</pre>

![Providers for package](images/providers.png)
 
---

title: Resources & Providers

<pre class="note">
service is running debian upstart vs chkconfig vs redhat service
</pre>

apache2/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">

  package "apache2"

  template "/etc/apache2/apache2.conf" do 
    user   "www-data"
    group  "www-data"
    mode   node["apache2"]["mode"]
    source "apache2.conf.erb"
  end

<b>service "apache2"</b> do
    action :enable
  end
</pre>

---

title: Resources & Providers
content_class: flexbox vcenter

<pre class="note">
zypper, yum, apt, pkg-add, ips
service is running debian upstart vs chkconfig vs redhat service
</pre>

![Providers for service](images/service_provider.png)
 
---

title: Lightweight Resources & Providers
content_class: flexbox vcenter

<pre class="note">
  cookbook can have an LWRP with no recipes. 
  LWRPs require less ruby knowledge as they are built using chef's DSL
</pre>

![feather image](images/11.jpg)
 
---

title: Lightweight Resources & Providers

<pre class="note">
</pre>

cookbooks/opscode/resources/database.rb

<pre class="prettyprint" data-lang="ruby">
actions :create, :delete

attribute :name, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String
</pre>


---

title: Lightweight Resources & Providers

<pre class="note">

</pre>

cookbooks/opscode/providers/mysql.rb

<pre class="prettyprint" data-lang="ruby">
action :create do
  execute "create database" do
    not_if "mysql -e 'show databases;' | grep #{new_resource.name}"
    command "mysqladmin create #{new_resource.name}"
  end
end
 
action :delete do
  execute "delete database" do
    only_if "mysql -e 'show databases;' | grep #{new_resource.name}"
    command "mysqladmin drop #{new_resource.name}"
  end
end
</pre>

---

title: Lightweight Resources & Providers

<pre class="note">

</pre>

cookbooks/monkeynews-app/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">
opscode_database "monkeynews" do
  type      "innodb"
  action    :create
  provider  "opscode_mysql"
end 
</pre>

---
title: Templates

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - Resources
    - Providers
    - [Templates](www.google.com)
    - Metadata
    - Files 
    - Libraries

---

title: Templates

<pre class="note">
note the apache2.conf.erb
</pre>

apache2/templates/default/apache2.conf.erb
<pre class="prettyprint" data-lang="ruby">
ServerRoot <%= node['apache']['dir'] %>
PidFile    <%= node['apache']['pid_file'] %>
Timeout    <%= node['apache']['timeout'] %>
Include    <%= node['apache']['dir'] %>/conf.d/
Include    <%= node['apache']['dir'] %>/sites-enabled/
</pre>

---

title: Templates

<pre class="note">
</pre>

apache2/recipes/default.rb

<pre class="prettyprint" data-lang="ruby">

  package "apache2"

  template "/etc/apache2/apache2.conf" do 
    user   "www-data"
    group  "www-data"
    mode   node["apache2"]["mode"]
    <b>source "apache2.conf.erb"</b>
  end

  service "apache2" do
    action :enable
  end
</pre>


---

title: Metadata

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - Resources
    - Providers
    - Templates
    - [Metadata](www.google.com)
    - Files 
    - Libraries

---

title: Metadata

<pre class="note">
Version
</pre>

apache2/metadata.rb

<pre class="prettyprint" data-lang="ruby">
<b>name</b>             "apache2"
<b>maintainer</b>        "Opscode, Inc."
<b>maintainer_email</b>  "cookbooks@opscode.com"
<b>license</b>           "Apache 2.0"
<b>description</b>       "Installs and configures all aspects of apache2 using Debian style 
symlinks with helper definitions"
<b>long_description</b>  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
<b>version</b>           "1.6.0"
<b>recipe</b>            "apache2", "Main Apache configuration"
%w{redhat centos scientific fedora debian ubuntu arch freebsd amazon}.each do |os|
  <b>supports</b> os
end
</pre>

---

title: Metadata

nagios/metadata.rb

<pre class="prettyprint" data-lang="ruby">
<b>name</b>              "nagios"
<b>maintainer</b>        "Opscode, Inc."
<b>maintainer_email</b>  "cookbooks@opscode.com"
<b>license</b>           "Apache 2.0"
<b>description</b>       "Installs and configures Nagios server and the NRPE client"
<b>long_description</b>  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
<b>version</b>           "4.0.0"

%w{ apache2 build-essential php nginx nginx_simplecgi }.each do |cb|
  <b>depends</b> cb
end
...
</pre>

---

title: Files

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - Resources
    - Providers
    - Templates
    - Metadata
    - [Files](www.google.com)
    - Libraries

---

title: Files

<pre class="note">
- Often, you need to distribute files to your servers. The Files within a cookbook are where you can do just that.
</pre>

mongodb/file/default/replicaset.json

<pre class="prettyprint" data-lang="json">
{ "mongodb":
           { members: [
             "member1": "host1.corp.com:27017",
             "member2": "host2.corp.com:27017",
             "member3": "host3.corp.com:27017"]
           }
}
</pre>

mongodb/recipes/replicaset.rb

<pre class="prettyprint" data-lang="ruby">
...
cookbook_file "/tmp/replicaset.json" do
  source "replicaset.json"
end
...
</pre>

---

title: Libraries

- Cookbooks are Chef's fundamental units of distribution
    - Recipes
    - Attributes
    - Resources
    - Providers
    - Templates
    - Metadata
    - Files
    - [Libraries](www.google.com)

---

title: Libraries

<pre class="note">
Libraries allow you to include arbitrary Ruby code, either to extend Chef's language or to implement your own classes directly.
</pre>

mongodb/libraries/mongodb.rb

<pre class="prettyprint" data-lang="ruby">
<b>class Chef::Recipe::MongoDB
  def self.initialize_replicaset(replicaset_name, mongo_nodes, credentials)</b>
    require 'rubygems'
    require 'mongo'
    ...
    mongo_nodes.each do |mongo_node|
      bson_member = BSON::OrderedHash.new
      bson_member['_id'] = new_member_id
      new_member_id += 1
      bson_member['host'] = "#{mongo_node['fqdn']}:#{mongo_node['mongodb']['port']}"
      members << bson_member
    end 
    config['members'] = members
    ...
  <b>end
end</b>
</pre>

---

title: Libraries


mongodb/recipes/replicaset.rb

<pre class="prettyprint" data-lang="ruby">
...
ruby_block "Initialize Replicaset" do
  block do
    Chef::Recipe::MongoDB.initialize_replicaset(...)
  end
end
...
</pre>

---

title: Big Picture
content_class: flexbox vcenter

![Big Picture](images/comprehensive_chef.png)

---

title: Anatomy of a Chef run
content_class: flexbox vcenter

![anatomy](images/chef-run.png)
