---
title: ruby web-based LDAP password changer
layout: post
---

(I was just turning my notes into a blog post, so if it seems weird, rambling, and contains too many shell commands, that's why.)

I noticed that at my company when someone uses the change password tool in [Pidgin](http://www.pidgin.im/), they get an access denied, and no one can set their own passwords. Pain in the ass. Every time a user forgets, or their pidgin client somehow loses the password, they have to ask us for it, and we have to generate a password that they must remember. How frickin' prehistoric. I set out to figure out why this was, and how to fix it. 

The fixing it part, not so much. Turns out that our chat server, [openfire](http://www.igniterealtime.org/projects/openfire/), treats the LDAP database as read only. I can imagine why, but that's pretty annoying. So there needed to be another way around this. I figured, why not use this as an opportunity to learn some new things! I banged out a password changer in python in about 20 minutes. It worked, but I wanted to see how I could do this in ruby. Turns out the whole _batteries included_ bragging rights of the python community really means something. I'm not blaming anyone, I'm merely illustrating that getting something up and running from zero in ruby on Debian Lenny is not as easy as you would hope. 

Here's what I spent the first hour or so doing with ruby:

No ruby, installed. I'll take care of that!
 
  apt-get install ruby 
  ruby --version
worked!

  gem install sinatra
doh. no gem.

I'll just install that right quick...
  apt-get install libgemplugin-ruby
  gem install sinatra

Nice, it worked.
Now I need a ruby ldap module. That should be a solved problem a million times over. This one looked stable enough to me, and coincidentally was the first result on google for ruby ldap. 
  git clone https://github.com/alexey-chebotar/ruby-ldap.git

Oh, no git.
  apt-get install git

Hmmm WTF is gnuit? Ah, it's like Norton Commander, an OFM! Awesome! I love those. Except, it's not the git I know, love, and need. Screw it, I'll skip that one. Whatever. I'm not going to send upstream patches from this box anyway, I'll just get the zip
  wget https://github.com/alexey-chebotar/ruby-ldap/zipball/master
  unzip master 

Oh, no unzip.
ugh... this is getting old...
  apt-get install unzip
  unzip master 
  cd alexey-chebotar-ruby-ldap-71302b3/
  ruby extconf.rb --with-openldap2

It's complaining about mkmf. I don't know what that is, but I know I need it to build this.
  gem install mkmf
  gem search mkmf

nothing.
Quick google around, mkmf is in ruby1.8-dev
  apt-get install ruby1.8-dev
  ruby extconf.rb --with-openldap2
  cat mkmf.log 

ok, now we're missing some ldap libraries.
  apt-cache search ldap | grep libraries
  apt-get install libldap-2.4-2
  sudo updatedb
  locate ldap.h

Still no ldap.h, guess I'll google around for that one too. 
  apt-get install libldap2-dev
  ruby extconf.rb --with-openldap2

nice! now just to compile...
  saslconn.c:19:23: error: sasl/sasl.h: No such file or directory

ok, need that one too. 
  locate sasl.h

nothing... back to google.
  apt-get install  libsasl2-dev
  updatedb
  locate sasl.h
  make clean
  make 
  make install

Great. I got it up and running. Now after playing around with it, I get my first connection object working and then... hit a wall. I pass it my credentials and I get a protocol error. Weird. I change the order, even though it looks right, then decide to do the right thing. Turn on maximum logging, and try again. My log says: 

  Jan 26 17:58:40 v2 slapd[17786]: send_ldap_result: err=2 matched="" text="historical protocol version requested, use LDAPv3 instead" 
  Jan 26 17:58:40 v2 slapd[17786]: send_ldap_response: msgid=4 tag=97 err=2 

So this is where my knowledge ends. I google around again for answers about if ruby-ldap works with LDAPv3, and if so, how. I wind up reading the source. Ruby does generate some awesome docs. 
  `LDAP::Conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )`

Fine, it does, awesome. Now to mess around in irb until I get it right. 
After about 45 minutes of typing and getting things wrong, I had my command line password changer for LDAP. 
  #/usr/bin/ruby -w
  
  #arguments UserName CurrentPassword NewPassword 
  username        = ARGV[0].to_s
  currentpassword = ARGV[1].to_s
  newpassword     = ARGV[2].to_s
  
  if ARGV.length < 1
    puts "clichangepass.rb UserName CurrentPassword NewPassword"
    exit
  end
  
  require 'ldap'
  
  $HOST =    'localhost'
  $PORT =    LDAP::LDAP_PORT
  
  LDAP::Conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
  
  
  def changepass(username, currentpassword, newpassword)
    conn = LDAP::Conn.new($HOST, $PORT)
    conn.bind("uid=#{username}, ou=people, dc=test, dc=com","#{currentpassword}")
    changepw=[LDAP::Mod.new(LDAP::LDAP_MOD_REPLACE, 'userPassword', ["#{newpassword}"]),]
    begin
      conn.modify("uid=#{username}, ou=people, dc=test, dc=com", changepw)
    rescue LDAP::ResultError
      conn.perror("modify")
      exit
    conn.unbind
    end
  end
  
  puts "#{username}"
  puts "#{currentpassword}"
  puts "#{newpassword}"
  
  changepass("#{username}", "#{currentpassword}", "#{newpassword}")

Supposedly that was the hard part. Getting a ruby application to go from the command line to a web application is supposed to be CAKE from what I've heard. I had my doubts. I looked into rails for this, but didn't really want to get all that involved. I don't intend on doing anything other than submitting a form with this app, so rails is overkill. Sinatra seemed like the natural choice. 
I installed it and got to messing with it. Seemed really really easy at first. Got the hello world up in a matter of seconds. Got my /form route done even faster. In all the tutorials, it looks like we're using erb, which I know rubyists despise in favor of any other templating engine, so I skipped it entirely and went with haml. 

HAML was a really nice surprise. Concise, easy, to the point. I was trying to do some not-so-fancy stuff with inheritance and couldn't figure that out immediately, but getting the application working is my first priority, and I'll worry about how to make the code look good later. 

The script itself looks alot like the one above. I just changed the names of the username currentpassword and newpassword variables and was on my way. The sinatra side of things is below.

  require 'rubygems'
  require 'sinatra'
  require 'changepass'
  
  get '/form' do
    username        = params[:username]
    currentPassword = params[:currentPassword]
    newPassword     = params[:newPassword]
    haml :form
  end
  
  post '/form' do
    changepass("#{params[:username]}", "#{params[:currentPassword]}", "#{params[:newPassword]}")
  end

I have the application working now, and have to worry about deploying it now. It's just a few lines of ruby, and I would like to run it from sinatra and WebBRICK, but I know that's really not the right thing to do if the server is already running an apache instance, which is was. 

I jumped through all the (admittely easy) hoops of installing installing passenger and getting it up and running. The thing that screwed me up was that I didn't know that you had to have an empty directory named /public under the application root. That piece of information was integral, and really frustrating. It actually was the most time consuming part of this whole project. After I installed and got passenger running, I debugged this issue for about 2 hours. I know, what a waste, I should have just known I needed it. Oh well. Now I know. Woot.

I learned quite a bit, and am looking forward to coding in ruby more often, as I plan on building some web apps in the very near future. 

