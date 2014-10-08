title: Why is this important?
content_class: flexbox vcenter

<pre class="note">
Need to add picture that represents this.
</pre>

### To make it simple for organizations to leverage from and contribute to the community.

---

title: How can we do that?
content_class: flexbox vcenter

<pre class="note">
Need to add picture that represents this.
</pre>

### By aligning on a set of practices.

---

title: What?

- Develop a set of standards around cookbooks design-patterns and structures.
    - Wrapper-Library cookbook design pattern
    - Extract ruby into libraries
    - Overriding attributes
    - Roles, what's its role?
- Cookbook workflow and pipeline
    - Local testing
    - Pipeline testing
    - Streamlining

---

title: What?

- Develop a set of standards around cookbooks design-patterns and structures.
    - [Wrapper-Library cookbook design pattern](http://nowhere.com)
    - Extract ruby into libraries
    - Overriding attributes
    - Roles, what's its role?
- Cookbook workflow and pipeline
    - Local testing
    - Pipeline testing
    - Streamlining


---

title: Wrapper-Library cookbook design pattern
content_class: flexbox vcenter

<pre class="note">
Mention that library isn't the library in cookbooks
</pre>

Why do we need this?

---

title: RainyDay Inc.
content_class: flexbox vcenter

<b>Marsha</b>, a software developer with RainyDay Inc. has to configure tomcat instances for her application.

![Marsha thinking about tomcat in the app stack](images/tomcat_app.png)

---

title: Open-Source Tomcat Cookbook
content_class: flexbox vcenter

<pre class="note"> 
Rather than re-inventing the wheel, she uses the tomcat cookbook found in the opscode community cookbook library to configure the tomcat instances for the organization.
</pre>


![Tomcat community cookbook](images/github_tomcat.png)

---

title: Problem

<pre class="note"> A rash way to fix it would be to hard code the values to whatever aligns with RainyDay's policies. </pre>

tomcat/recipes/default.rb: (open source community cookbook)

<pre class="prettyprint" data-lang="ruby">
    ...
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb"<b>
      owner "root"
      group "root"</b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
    ...
</pre>

---

title: Solution (?)

<pre class="note">  Another way to fix this would be to move these values into attributes that can be overridden externally.
- Adding organization-specific customizations and features will prevent the developer from contributing innovation back to the community.
- It will also prevent the developer from getting enhancements without having to merge them in. This makes everyone's life harder. </pre>

tomcat/recipes/default.rb: (Rainyday-ified cookbook)

<pre class="prettyprint" data-lang="ruby">
    ...
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb" <b>
      owner "webadm"
      group "webadm"</b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
    ...
</pre>

---

title: <del>Solution</del> Short-term Hack

<pre class="note"> Another way to fix this would be to move these values into attributes that can be overridden externally. </pre>

tomcat/recipes/default.rb: (Rainyday-ified cookbook)

<pre class="prettyprint" data-lang="ruby">
    ...
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb" <b>
      owner "webadm"
      group "webadm"</b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
    ...
</pre>

---

title: Problem

<pre class="note">
A rash way to fix it would be to hard code the values to whatever aligns with RainyDay's policies.
</pre>

tomcat/recipes/default.rb: (open source community cookbook)

<pre class="prettyprint" data-lang="ruby">
    ...
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb"<b>
      owner "root"
      group "root"</b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
    ...
</pre>

---

title: Solution (?)
content_class: flexbox vcenter
<pre class="note">
The current best practice suggests that we extract this block into an LWRP and provide an interface to configure this resource. 
</pre>

Can we do this?

<pre class="prettyprint" data-lang="ruby">
    tomcat_application "goat_finder" do
      owner node["rainyDayTomcat"]["user"]
      group node["rainyDayTomcat"]["group"]
      action :configure
    end
</pre>


---

title: Solution
content_class: flexbox vcenter
<pre class="note">
The current best practice suggests that we extract this block into an LWRP and provide an interface to configure this resource. 
</pre>

Yes!

<pre class="prettyprint" data-lang="ruby">
    tomcat_application "goat_finder" do
      owner node["rainyDayTomcat"]["user"]
      group node["rainyDayTomcat"]["group"]
      action :configure
    end
</pre>


---

title: Abstract Resources into LWRP

<pre class="note">
</pre>

tomcat/recipes/default.rb: (open source community cookbook)

<pre class="prettyprint" data-lang="ruby">
    ...
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
    ...
</pre>

---

title: Abstract Resources into LWRP

tomcat/providers/application.rb
     
<pre class="prettyprint" data-lang="ruby">
    action :configure do
      ...
      name = new_resource.name<b>
      tomcat_owner = new_resource.owner
      tomcat_group = new_resource.group</b>
      ... 
      template "#{catalina_base}/tomcat6" do
        source "default_tomcat6.erb"<b>
        owner tomcat_owner
        group tomcat_group</b>
        mode "0644"
        notifies :restart, resources(:service => "tomcat")
      end
      ... 
      new_resource.update_by_last_action(true)
    end
</pre>

---

title: Set the interface of LWRP

tomcat/resources/application.rb

<pre class="prettyprint" data-lang="ruby">
    actions :configure
    ... 
    attribute :name, :kind_of => String, :name_attribute => true<b>
    attribute :owner, :kind_of => String, :default => "root"
    attribute :group, :kind_of => String, :default => "root"</b>
    ...
</pre>

---
title: Wrapper Cookbook: rainyDayTomcat

<pre class="note">
Calling this resource is now as simple as calling any other defined resource in chef. This allows for code re-use, not copy pasting and everything that comes with doing that.
</pre>

rainyDayTomcat/metadata.rb

<pre class="prettyprint" data-lang="ruby">
      name "rainyDayTomcat"
      version 0.1.0
      description "Configure tomcat for RainyDay Inc."
      ...
      depends tomcat
      ...
</pre>

---

title: Wrapper Cookbook: rainyDayTomcat

<pre class="note">
Calling this resource is now as simple as calling any other defined resource in chef. This allows for code re-use, not copy pasting and everything that comes with doing that.
</pre>

rainyDayTomcat/recipes/goat_finder.rb

<pre class="prettyprint" data-lang="ruby">
  tomcat_application "goat_finder" do
    owner node["rainyDayTomcat"]["user"]
    group node["rainyDayTomcat"]["group"]
    action :configure
  end
</pre>

rainyDayTomcat/attributes/default.rb
<pre class="prettyprint" data-lang="ruby">
  default["rainyDayTomcat"]["user"] = "webadm"
  default["rainyDayTomcat"]["group"] = "webadm"
  ...
</pre>

---

title: Upload To Community Repo
content_class: flexbox vcenter

<pre class="note"> 
</pre>


![Tomcat community cookbook](images/github_tomcat.png)

---

title: Umbrella Corp 
content_class: flexbox vcenter

Now, <b>Tashawnda</b>, a developer with Umbrella Corp has to configure tomcat instances for her application, Zombie Finder.

![Tashanda thinking about tomcat in the app stack](images/tomcat_app.png)

---

title: Problem

<pre class="note">
After she pushes it back to the community, if a another user needs to change a value that is hard-coded in the library cookbook, this is where LWRPs in library cookbooks shine. This is because, the original creator of the LWRP library cookbook doesn't need to over-engineer while allowing the community to add or modify with ease. For example, a company called Umbrella has a security policy dictating the mode of the tomcat configuration file to be 600. The library cookbook's LWRP automatically sets it to 644. Here, Umbrella's engineer can modify the LWRP without changing the default behavior like so: 
</pre>

tomcat/providers/application.rb
     
<pre class="prettyprint" data-lang="ruby">
    action :configure do
      ...
      tomcat_group = new_resource.group
      ... 
      template "#{catalina_base}/tomcat6" do
        source "default_tomcat6.erb"
        owner tomcat_owner
        group tomcat_group<b>
        mode "0644"</b>
        notifies :restart, resources(:service => "tomcat")
      end
      ... 
      new_resource.update_by_last_action(true)
    end
</pre>


---

title: Solution

tomcat/providers/application.rb

<pre class="prettyprint" data-lang="ruby">
    action :configure do
      ...
      tomcat_group = new_resource.group<b>
      tomcat_mode = new_resource.mode</b>
      ... 
      template "#{catalina_base}/tomcat6" do
        source "default_tomcat6.erb"
        owner tomcat_owner
        group tomcat_group<b>
        mode tomcat_mode</b>
        notifies :restart, resources(:service => "tomcat")
      end
      ... 
      new_resource.update_by_last_action(true)
    end
</pre>

---

title: Solution

Set the interface of LWRP

tomcat/resources/application.rb

<pre class="prettyprint" data-lang="ruby">
    actions :configure
    ... 
    attribute :group, :kind_of => String, :default => "root"<b>
    attribute :mode, :kind_of => String, :default => "0644"</b>
    ...
</pre>

---
title: Wrapper Cookbook: umbrellaTomcat

<pre class="note">
</pre>

umbrellaTomcat/metadata.rb

<pre class="prettyprint" data-lang="ruby">
      name "umbrellaTomcat"
      version 0.1.0
      description "Configure tomcat for Umbrella Corp"
      ...
      depends tomcat
      ...
</pre>

---

title: Wrapper Cookbook: umbrellaTomcat

<pre class="note">
</pre>

umbrellaTomcat/recipes/zombie_finder.rb

<pre class="prettyprint" data-lang="ruby">
  tomcat_application "zombie_finder" do
    owner node["umbrellaTomcat"]["user"]
    group node["umbrellaTomcat"]["group"]<b>
    mode node["umbrellaTomcat"]["mode"]</b>
    action :configure
  end
</pre>

rainyDayTomcat/attributes/default.rb
<pre class="prettyprint" data-lang="ruby">
  default["umbrellaTomcat"]["owner"] = "tomcat"
  default["umbrellaTomcat"]["group"] = "tomcat"<b>
  default["umbrellaTomcat"]["mode"] = "0600"</b>
  ...
</pre>

---

title: Upload To Community Repo
content_class: flexbox vcenter

<pre class="note"> 
</pre>


![Tomcat community cookbook](images/github_tomcat.png)
---

title: RainyDay Can Update Without Fear

<pre class="note">
It will be easy for Marsha to update the cookbook
</pre>

tomcat/resources/application.rb

<pre class="prettyprint" data-lang="ruby">
    actions :configure
    ... 
    attribute :name, :kind_of => String, :name_attribute => true
    attribute :owner, :kind_of => String, :default => "root"
    attribute :group, :kind_of => String, :default => "root"<b>
    attribute :mode, :kind_of => String, :default => "0644"</b>
    ...
</pre>

---

title: Does this get us closer...
content_class: flexbox vcenter

<pre class="note">
</pre>

to make it simple for organizations to leverage from and contribute to the community?

---

title: Yes
content_class: flexbox vcenter

<pre class="note">
Don't need to over-engineer at start.

TODO:Picture for wrapper-library cookbook design pattern
</pre>

- code reuse
- change

---

title: Credits
content_class: flexbox vcenter

- http://wiki.opscode.com/
- https://github.com/opscode-cookbooks
- https://code.google.com/p/io-2012-slides/

