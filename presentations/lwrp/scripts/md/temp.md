---

title: What am I doing wrong?
class: build

- Pulling cookbooks from a community repository
- Realizing there is unecessary complexity (supporting platforms and features your org does not use or care about)
- Rewriting the parts you use, and cutting out the parts you don't or don't understand
- Falling out of touch with improvemnts to the community cookbook because you have entered merge hell
- Being unable to contribute your innovations back because of merge hell
- Finding yourself stuck in a silo tied to your specific infrastructure


--- 

title: How do I avoid this?

.notes: The key here is to ensure that these parameterized values' default values are maintained so other users in the community can continue using the changed library cookbook.

- All non company specific *stuff* goes into a library cookbook. This cookbook is organization agnostic and only configures what is needed to run the application. 
- Put everything into LWRPs and *only* parameterize the values that you change from the library cookbook's sane, common default values as attributes.
- All your organization specific customizations to a wrapper cookbook that `requires` your library cookbook, and override the defaults where required by your infrastructure. 
- If you encounter a parameter or configuration option that you need to change, add it to the library cookbook with the default value and override it in the wrapper cookbook. 

---

title: What kind of chaos?

- Cookbooks are usually pulled from the community then hacked on locally to incorporate organization specific infrastructure.
- They are then pushed to the local chef-server with arbitrary version numbers that were invented internally. 

---


title: Adhering to good standards and design patterns (Reorganize this with the previous 4 slides)

- There is a [pattern](http://devopsanywhere.blogspot.com/2012/11/how-to-write-reusable-chef-cookbooks.html) called the library-wrapper pattern that the community has adopted. Knowing it and how to use it makes collaborating with others much easier. Check out the [apache2](http://github.com/opscode-cookbooks/apache2) cookbook to see what it looks like.

---

title: Why should I use this pattern?
class: build

- Reusability
- Separation of code and internal data
- Testability (?)
- Contributing to the community
- Change

---

title: Example

<pre class="note">
- In this example, of our attributes for the tomcat cookbook we have coupled our version of the community tomcat cookbook to our particular infrastructure. We have made an incorrect assumption that nagios will be used on every instance of tomcat. By doing this, we have effectively prevented ourselves from confidently updating to later revisions of the community cookbook and from contributing our developments back to the community.
- Also, in the community tomcat cookbook, there is an assumption that the tomcat configuration file should be owned by root. This directly violates RainyDay Inc.'s security policies and guidelines. 
</pre>

---

title: Solution (?)

<pre class="note">
Another way to fix this would be to move these values into attributes that can be overridden externally.
</pre>

tomcat/recipes/default.rb: (Rainyday-ified next attempt)
<pre class="prettyprint" data-lang="ruby">
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb" <b>
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"] </b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
</pre>

tomcat/attributes/default.rb:
<pre class="prettyprint" data-lang="ruby">
    default["tomcat"]["user"] = "webadm"
    default["tomcat"]["group"] = "webadm"
</pre>
      
---

title: <del>Solution</del> Better, but not sustainable

<pre class="note">
In this example, our attributes for the tomcat cookbook we have coupled our version of the community tomcat cookbook to our particular infrastructure. We have made an incorrect assumption that nagios will be used on every instance of tomcat. By doing this, we have effectively prevented ourselves from confidently updating to later revisions of the community cookbook and from contributing our developments back to the community.

</pre>

tomcat/recipes/default.rb: (Rainyday-ified next attempt)
<pre class="prettyprint" data-lang="ruby">
    template "/etc/default/tomcat6" do
      source "default_tomcat6.erb" <b>
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"] </b>
      mode "0644"
      notifies :restart, resources(:service => "tomcat")
    end
</pre>

tomcat/attributes/default.rb:
<pre class="prettyprint" data-lang="ruby">
    default["tomcat"]["user"] = "webadm"
    default["tomcat"]["group"] = "webadm"
</pre>
      
---



<pre class="note">
we should have these beside the recipe file to show that nothing have changed except for variables, owner and group.
</pre>
## tomcat/providers/application.rb
    !ruby
    action :configure do
      name = new_resource.name
      tomcat_application_home = new_resource.tomcat_application_home
                  #HIGHLIGHT
      tomcat_owner = new_resource.owner
      tomcat_group = new_resource.group
                  #HIGHLIGHT
      catalina_base = "#{tomcat_application_home}/#{name}"
    
      ...
    
      template "#{catalina_base}/conf/default_#{name}.conf" do
        source "default_tomcat6.erb"
                  #HIGHLIGHT
        owner tomcat_owner
        group tomcat_group
                  #HIGHLIGHT
        mode "0644"
        notifies :restart, "service[#{name}]"
      end
    
      ...
    
      new_resource.update_by_last_action(true)
    end


