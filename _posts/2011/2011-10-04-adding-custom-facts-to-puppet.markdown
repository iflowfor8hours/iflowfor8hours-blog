---
title: Adding custom facts to puppet
layout: post
---

Earlier today, I was trying to do something silly with facter, where I wanted to compare the uptime that facter was reporting with the actual uptime that the machine was reporting using the `uptime` command. 
I used [this](http://docs.puppetlabs.com/guides/custom_facts.html) doc to get an idea of what I was supposed to do, but couldn't figure out where to actually put the fact on the client I was testing with. 
Luckily, facter reports this information through `facter lib`. 
Here's the custom fact I added to puppet:

    #realuptime.rb

    Facter.add("realuptime") do
        setcode do
                %x{/usr/bin/uptime | /bin/grep -o '[0-9][0-9]':'[0-9][0-9]':'[0-9][0-9]'}.chomp
        end
    end
 
This file has to go in `{modulepath}/{module}/lib/facter/{factname}.rb` if you want to use it on your clients, as well as in `/var/lib/puppet/lib/facter` if you want to test/use it locally on the machine you're working on. 
