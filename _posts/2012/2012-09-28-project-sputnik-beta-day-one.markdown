---
title: Project Sputnik Beta Day one
layout: post
---

I'm taking part in the beta program for Dell's [project sputnik](http://content.dell.com/us/en/enterprise/d/campaigns/sputnik), and I'm going to be writing up some of my notes on what I think of the machine. This is the day one review, so more will follow. 
A little background: I've been a desktop/laptop linux user for about five years now, and have been administrating linux and unix servers in some capacity for the past nine. I'm coming from a [linux mint](http://linuxmint.com/) based [Lenovo ThinkPad x220](http://shop.lenovo.com/us/products/professional-grade/thinkpad/x-series/x220/index.html). I have had exactly zero linux related woes with that box. I love ThinkPad design, and will probably continue using them for the rest of my life. Everything works as expected, it resumes and sleeps without issue, the battery life is great, and keyboard is flawless as far as I'm concerned. I'm a little biased considering I have been using ThinkPads exclusively since IBM released the [ThinkPad 560](http://www.thinkwiki.org/wiki/Category:560) in 1996, so keep that in mind. 
I haven't used it much yet, so keep in mind this post will primarialy be about the hardware.
###Hardware###
This is a high end [Dell XPS 13 Ultrabook](http://www.dell.com/us/p/xps-13-l321x/pd). To say this box is macbook air inspired is a massive understatement. It's nearly indistinguishable from the outside. I've never oned or used one of those, but this looks identical. It has the apple style chicklet keyboard, the power button is in the same place, and the outside of it is completely clean, except for the dell logo in the center of the top.
I would say it's a pretty cool looking machine. 
###X220 vs XPS###
Keep in mind I maxed out my x220 when I got it from the Lenovo depot. 
Intel's ARK [Processor Comparison](http://ark.intel.com/compare/53464,54618) has the specs and there's no point repeating them.
My immediate concern is that the 1.70ghz proc (compared to the x220's 2.80ghz) is going to be a bottleneck when I'm running a bunch of boxes in vagrant, but since I haven't tried it yet, I can't really comment. The client I'm working at right now requires me to use Microsoft Outlook and communicator, so I'm running a windows xp VM all day while I'm spinng up multi-vm test environments for chef development and other tasks. I'll report back on that later.
The lack of connectivity on the XPS is also a huge concern for me. The ThinkPad has 3 USB ports, a VGA port, a gigEthernet port and an SD card reader, all of which I use daily. I'm wondering how well I'll cope with having to carry adaptors and a USB NIC around all the time. Probably not well. If they are marketing this to devs/devops people, I would think an ethernet port would be a priority, but I suppose everyone uses wifi at their office now. Do they?
I'm also going to miss the ThinkPad's dedicated volume controls and PgUp/PgDn key cluster. 
On the x220 my trackpad is disabled as I think it is infuriating when you accidentaly touch it while typing, and I've been unable to get the software that prevents that from happening to work properly on any platform, ever. I use a real mouse when I'm at a desk and the trackpoint when I'm not. I'm concerned about this on the XPS as I've seen reports of trackpad issues. I hope it's not a productivity killer.
The final gripe is the XPS has 4gb of ram and the ThinkPad has 8gb. Nuff' said.
###Installation of Sputnik Software###
I'm using my normal method for installing an os, which is download the image and use unetbootin to create a bootable USB drive and install from there. It seems to be going as planned.
###Moving my homedir and configuration###
Planning on just tarring up my whole homedir and scping it across. I suppose we'll see how that goes. The only tricky things I think are going to be installing the RSA client under wine, and I remember I had to do some hackery to get my Verizon 4g device working. I wish I had documented that somewhere...
###Summary###
I sound much like a crochety old man who dislikes change. I'm going to give this a go and see what happens. I'm now embarking on the always annoying task of getting my homedir and configurations from one machine to the other. I'll report back after some real usage.
