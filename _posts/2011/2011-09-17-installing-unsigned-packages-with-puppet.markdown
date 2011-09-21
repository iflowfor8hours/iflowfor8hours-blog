---
title: Installing unsigned packages with puppet
layout: post
---

When you are running your own repo, installing packages that  you built yourself or don't have       signatures, apt-get complains, and the puppet run fails. This frustrated me pretty seriously until I figured out what needed to be done. All you need to do is create a file in `/etc/apt/apt.conf/` with the contents `APT::Get::AllowUnauthenticated yes`. 
The smart way of doing this is of course, in your apt module. Add a section to it with

    # It's OK to install unsigned packages
    File {
    "/etc/apt/apt.conf.d/99auth":       
     owner     => root,
     group     => root,
     content   => "APT::Get::AllowUnauthenticated yes;",
     mode      => 644;
     }
 
and you should be on your merry way. 
