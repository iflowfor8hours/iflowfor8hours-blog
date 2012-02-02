Ok, starting from zero. no ruby, installed. I'll take care of that!
 
  523  apt-get install ruby 
  525  ruby --version
worked!

  526  gem install sinatra
doh. no gem.

I'll just install that right quick...
  528  apt-get install libgemplugin-ruby

  530  gem install sinatra
Nice, it worked.
 
  532  git clone https://github.com/alexey-chebotar/ruby-ldap.git
Oh, no git.
 
  534  apt-get install git
  535  apt-get update
  536  apt-get install git
hmmm wtf is gnuit? It's certainly not the git I know and love.
skip that one. Whatever. I'm not going to send upstream patches from this box anyway, I'll jsut get the zip

  539  wget https://github.com/alexey-chebotar/ruby-ldap/zipball/master

  541  unzip master 
Oh, no unzip.

  542  apt-get install unzip
ugh... this is getting old...

  544  unzip master 
  546  cd alexey-chebotar-ruby-ldap-71302b3/
  552  ruby extconf.rb --with-openldap2

  553  gem install mkmf
  554  gem search mkmf
nothing.
hmm quick google around, mkmf is in ruby1.8-dev

  561  apt-get install ruby1.8-dev
  564  ruby extconf.rb --with-openldap2
  565  cat mkmf.log 
ok, now we're missing some ldap libraries.
 
  571  apt-cache search ldap | grep libraries
  572  apt-get install libldap-2.4-2   libldap-2.4-2
  575  sudo updatedb
  576  locate ldap.h
Still no ldap.h, guess I'll google around for that one too. 

  591  apt-get install libldap2-dev
  592  vim mkmf.log 
  593  ruby extconf.rb --with-openldap2
nice! now just to compile...
	
	saslconn.c:19:23: error: sasl/sasl.h: No such file or directory

ok, need that one too. 

  596  updatedb
  597  locate sasl.h
nothing... back to google.

  598  apt-get install  libsasl2-dev
  599  updatedb
  600  locate sasl.h
  601  make clean
  602  make 
  603  make install

Great. I got it up and running. Now after playing around with it, I get my first connection object working and then... hit a wall. I pass it my credentials and I get a protocol error. Weird. I change the order, even though it looks right, then decide to do the right thing. Turn on maximum logging, and try again. My log says: 

Jan 26 17:58:40 v2 slapd[17786]: send_ldap_result: err=2 matched="" text="historical protocol version requested, use LDAPv3 instead" 

Jan 26 17:58:40 v2 slapd[17786]: send_ldap_response: msgid=4 tag=97 err=2 

Jan 26 17:58:40 v2 slapd[17786]: conn=1 op=0 RESULT tag=97 err=2 text=historical protocol version requested, use LDAPv3 instead 

So this is where my knowledge ends. I google around again for answers about if ruby-ldap works with LDAPv3, and if so, how. I read the source. 

`LDAP::Conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )`

Fine, it does, awesome. Now to mess around in irb until I get it right. 

