---
title: "New Blog, New Home"
layout: post
---


Getting this box up and running the way I wanted it has proven to be a far more difficult task than I anticipated. All I wanted was:

* A VPS running ubuntu that was cheap, Europe-based, and that allowed me to pay with paypal.
* A blogging platform that I could update using vim, in textile, with a minimal amount of fluff (read plugins/updates/etc). I also wanted to be able to later integrate a decent gallery in the future.
* Some software fetish things, like a secure trac wiki and an svn server are in the works as well.
* A screen session running rtorrent.
* Some backup scripts for my email, homedir, dotfiles.
* Centralized bookmark management. 

To me, this sounded beyond simple. I had all this (minus rtorrent) and a wordpress installation in the past running on a dedicated server that was hosted at my previous job. The server was far from top end, but it was unused and worked well enough, so I had my way with it. Because I recently lost access to the data on that box temporarily, I decided it was not a bad time to start over. I assumed all I needed to do was to find equivalents, apt-get, edit some conf files and I would be on my way. I was wrong. 

I've never worked with VPSs before, but assumed it would be exactly like dedicated servers. In the past I installed ubuntu from CD, configured everything the way I wanted it, and I was on my merry way. I went to lowendbox, found the cheapest vps I could in europe (hostrail), and bought a slice. With this vps, after getting it up and running, I noticed my terminal was dog slow. Using vim was painful, and at times screen refresh at a bash prompt was horrible. I played with this vps for a few days, reinstalling minimal distros, trying at various times of day and night to no avail. It never got any better. I decided to ditch hostrail. 1 week give or take wasted. My fault. Chalk it up to inexperience. 

I tried another vps provider (quickweb) and they seemed to be much better. The web interface was more pleasant, the Java terminal worked well, and they have some forwarding so if I ssh to a port and IP address I can get an actual console session, if I screw up firewall settings or something. I liked it already. The box is located in Germany, so no qualms there. I had some annoying timezone/locale/perl issues that were resolved with swift google-fu. Step one, accomplished.

Things got hairy around the second part. I wasted an unbelievable amount of time picking a blogging platform. I'm in the process of learning clojure, so I thought a static site generator in clojure would have been cool. I played with a few of them with varying levels of success. This was a while ago, so excuse the lack of details, but because my knowledge of clojure is not up to snuff, when I had configuration issues, or problems with java, I wasn't really keen to start debugging. I really just wanted to blog! 

I moved from there onto the KISS principle. Wordpress sprang to mind. It was easy before, so it must be easy now, right? Wrong. I installed it, did all the apache configs with mod_rewrite and editing the wp-config so that the static links worked, installed mysql, configured that... blah blah blah. In the end, I discovered that being a cheapskate can lead to serious problems. 256mb of ram is not enough to run a default configured LAMP stack comfortably. I considered tuning apache and mysql, but I didn't want to go around copy-pasting things I had no idea about. I've never done any mysql tuning, and it's not something I'm really intersted in. This limitation happily ruled out the heavyweight stuff that would be easy to get a proper gallery running on, like Joomla and Drupal. Next solution, back to static site generators.

I really liked the idea of keeping everything inside of a VCS, and the VCS with the hotness is certainly git. The obvious answer? Jekyll! I got this running in the standard fashion, which is cloning TPW's blog and modifying it. Once I was done, the site I created wasn't pretty. While it's certainly not impossible to create nice layouts and have a good-looking site with Jekyll, I was not super keen on doing so. Also, the idea of easily adding a gallery was not preposterous, but would be no simple task either. I went back to the drawing board on Jekyll for these reasons.

I think it's important to say at this point that I was definitely enjoying trying everything under the sun. I'm almost never quick to give up, but when I'm shopping for open source software and spoiled for choice I'll try things just for the sake of it. There are so many choices, and so many modifications and ideas that it's very easy to get ADD and just keep jumping from platform to platform. I think that most people who live/breathe/work in software will do this, then create their own,
then find something they like. 

I decided that since I already had Wordpress configured, and I didn't really mind having everything in a database, I give it another spin. This time I would do nginx and php worker processes. Long story short, I was again short on resources and determined not to upgrade this VPS. 256mb used to be HUGE. I could comfortably emulate neo-geo roms on my p120 with 128mb!! WTF!? </joke>

One can imagine I was feeling a little lost at this point, so I turned where everyone does when the world is a little scary and confusing. Usenet. oops. I mean Stack Overflow. There were plenty of suggestions for static site generators, but nanoc stuck out as one that seems well documented, recenly maintained, and supported images well. 
