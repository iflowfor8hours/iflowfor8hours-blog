---
title: CI with puppet, amazon, jenkins, git-flow, tomcat, and gitolite
layout: post
---

These are notes I took while doing an assignment for a friend. I was on a pretty serious time constraint, so I cut some corners, which I will address at the end of the article. I'm not advocating that this is the best way to structure a project like this, but I think it's pretty good given the situation.

_We're writing a tomcat app in eclipse, on windows boxes. As it stands, we're not doing any kind of automated testing, we have version control (svn) , but we're not particularlly attached to it, and we would like to be able to single-click deploy to a number of environments. We have a small team of developers that wear different hats, but we have dedicated QA people. Can you build us something that would make our dev and deploment process smoother?_

The most interesting part of this setup is the [gitolite](https://github.com/sitaramc/gitolite) server. It's not using 'true' [git-flow](https://github.com/nvie/gitflow) because one of the stipulations was that the developers were using eclipse on windows to develop their tomcat application. This means that they can't use the git-flow scripts until someone writes a git flow plugin for eclipse. I may do this in the near future if this comes up often enough.

My solution is going to look like this:
- Puppet for installing and maintaining configuration
- Jenkins for builds and deployment of environments
- git for version control, the repo broken into feature develop QA release hotfix and master(prod), al-la git-flow
 
#### The server setup ####

For fun, I used [geppetto](https://github.com/cloudsmith/geppetto) to write and test my modules. I thought that I might deploy this [stackhammer](http://blog.cloudsmith.com/?tag=stack-hammer), but didn't wind up doing that in the end. Both of them are cool projects. I think for something like this, geppetto was a little overkill, but it was interesting to use a new tool regardless.

This is only a single server, so I'm going to do everything in puppet standalone "mode". I think that this is an often overlooked and incredibly useful way to develop modules and avoid repeating mistakes one has the tendency to make with shell scripts. 

What I mean by this is that I wrote a module then wrote a test and ran `puppet apply --modulepath=/etc/puppet/modules/ --verbose ${modulename}/tests/init.pp`. Doing it this way means that if it were necessary, we could deploy these modules and configurations to many machines and have an idea about how it would work.

First thing I did was run `apt-get update` followed by `apt-get upgrade`. Just to get a baseline of security updates and make sure the system is up to date. 

#### Puppet ####
Nothing really special here, I just added the apt repo from puppet labs, and added their key.

    echo -e "deb http://apt.puppetlabs.com/ lucid main\ndeb-src http://apt.puppetlabs.com/ lucid main" >> /etc/apt/sources.list.d/puppet.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv 4BD6EC30

There were some dependency issues with libaugeas-ruby1.8, and I saw that it was not in the hardy repo. I added the lucid apt repo and got it from there. 
  
    echo -e "deb http://us.archive.ubuntu.com/ubuntu/ lucid main restricted" >>/etc/apt/sources.list.d/lucid.list
    echo -e "deb-src http://us.archive.ubuntu.com/ubuntu/ lucid main restricted" >>/etc/apt/sources.list.d/lucid.list

    apt-get update 
    apt-get -y install puppet git git-core apt curl

At this point. I removed the "rogue" repos, because I plan on administrating repositories with puppet.
  
For the rest of the package management and configuration I want to automate, I'm going to be using puppet. 

If this were a production box, I would probably create an image or snapshot from this point. I worked this exercise out using virtualbox, on my local machine so I took a snapshot.

#### Jenkins ####
At work, I had just used an excellent puppet module for installing and configuring jenkins, so I hit that one up first.

I had to make some modifications for ubuntu 8, namely including the sun jdk instead of the included openjdk. I built a little module for installing the sun jdk and jre, and then included them as requirements for jenkins.
Jenkins also needed keys and it's gitconfig setup. I put those in it's puppet module. This is available on my github.
        
##### additional configuration #####

* Installing the git plugin (done with web interface)
* Building the ant file for different environments 


Jenkins is checking out different branches of the project and building and deploying them upon checkin. There are 4 branches in the repo and jenkins can read all of them. Jenkins checks out each branch, builds it, and then runs an ant task (qa prod dev stage). The ant tasks will compile, war, and deploy to their respective places in the tomcat server, then restart it. Each is accessible by it's name and environment, and wiped clean every time the jenkins runs the build.

    http://hostname:8180/fightingChickenDev
    http://hostname:8180/fightingChickenQA
    http://hostname:8180/fightingChickenStage
    http://hostname:8180/fightingChickenProd
  
        
####Gitolite server ####
I built a module for installing and configuring gitolite. The users still have to be managed by hand. I wound up using a package from the natty repo for this, which I installed using an apt module that I've used in the past.
The users for gitosis could be managed using puppet templates, I chose not to for the sake of saving time. In production, I would probably manage this by hand anyway, or if the team was big enough and growing, externalize this with LDAP. 

the git server is accessible via 

    git clone git@hostname:fightingChicken
    git clone git@hostname:gitolite-admin
    
##### additional configuration #####
Users are managed by adding their keys to `gitolite-admin/keydir` directory in the admin repo. The filename of the key has to match the username.
Permissions are managed by the `gitolite-admin/conf/gitolite.conf` file. I did something interesting in the `gitolite.conf` file:

**There are 4 branches in the repo, development, qa, stage, master.**

#gitolite.conf
@developers = dick tom
@qa         = vikram
@ops        = matt adminkey

        repo    gitolite-admin
                RW+     =   adminkey
                RW+     =   admin

        repo    fightingChicken
                RW+           =   adminkey
                RW+           =   admin
                R             =   jenkins
                RW+   develop =   @all
                RW+   qa$     =   @developers
                RW+   stage$  =   @qa
                RW+   master$ =   @ops
       

The development process would go like this: 

Developers (and everyone else) can push to dev and qa. Once the code arrives at QA, it is deployed to the qa environment. If the code is satisfactory, it can only be pushed to stage by the QA team members. If it is not, it is pushed back to the development branch for more work. QA can push to stage, where the ops team looks at it and makes sure that it will deploy without issues. Once that is verified, ops can push to the master, where it is deployed to production. 
    
All of the builds are automated, but in reality, I would probably make that last push a manual one, or at least on that wasn't on a cron job. If it were more than 2 steps, I would automate it, but I think forcing members of the ops team to actually decide to deploy the application after it is in the master repo (and tagged so we can roll back!) is OK. 
        
What commands to execute to deploy the application?
Clicking on the build now in jenkins will build and deploy the application. You can also do it from the command line by launching ant from the root of the application directory. 
  
The challenges I've faced in implementing this process have been:
  I should have actually checked the machine out first instead of developing blindly on my local box. I would have saved some time that way. 
  I wish I knew more about deploying tomcat applications. I added some logging (/var/log/tomcat5.5/tomcat.log) and still couldn't figure out what was wrong. I'm fairly certain what I need is in the web.xml file, but I'm not sure what it is. 
  I'm sure there's a better way of writing that build.xml file, but this works and is maintainable for the moment.
    
If I had more time: 
  The ops side of my brain is screaming because this box doesn't exist because it's not monitored, and the basics (ntp, dns, ip, hostname, tomcat, etc..) are unmanaged. I could have included a bunch of modules that I use regularly, but I think that would just confuse things for this project. 
  Redmine. Setting up redmine by hand is really easy. Doing an automated redmine deployment and integrating it with jenkins is not. I would have set it up by hand 'for show', but I came to the conclusion that it didn't make any sense to do so. I think having a ticket tracking system is essential to any good software project, and if you're not going to pay for JIRA (free tools only in the project description) then redmine is the way to go.
  I would write an egit wrapper for git-flow. git-flow makes so much sense to me, but windows users can't use it.
  My restart tomcat on every build paradigm is clumsy. I would manage each container seperately so that restarts on the qa environment would not effect anyone else. Doing this would probably necessitate managing tomcat through puppet, which would be the right way of deploying thisin production. As I said above, I would have built modules for all of the components of the system that required configuration. Every once in a while, a build fails because /etc/init.d/tomcat tomcat fails to execute. This could be fixed by siloing each environment and just reloading instead of restarting. 
  
Why were certain tools selected:
  Jenkins because I think it is the best tool for the job when it comes to continious integration. It's mature, stable, and easy to deploy. There are a ton of plugins, and it scales well. Authentication can be added pretty easily, 
  Puppet because I'm most familiar with it. I could have used any number of configuration management tools, but this is the one I know best. 
  Git because I think it's the best dvcs there is. It is a pain that windows users have to use a graphical interface but I think most windows developers are used to that. 

What is your recommendation for future work if time allows? 
  I would build modules for the 'moving parts' of the server, as I mentioned above, and figure out why the application did not deploy properly. 

