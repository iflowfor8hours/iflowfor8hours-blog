---
title: Removing Unity from Ubuntu
layout: post
---

This is here for the sake of people trying to use Eclipse under Ubuntu for developing andriod apps or anything else. Basically, when ubuntu changed the desktop environment to unity, it automatically installed some customizations for compiz that cause Eclipse and a few other apps not to display scrollbars. 
When you are trying to build an android app, this is terribly frustrating because in the window where you have to select the target environment, it's impossible to scroll down and hit OK. Seriously, one of the most annoying things I've ever had happen to me, because most other applications behaved normally, and I didn't remember that I had apt-get upgraded recently, so it took forever to find. 
Anyway, here they are: 

    sudo apt-get remove overlay-scrollbar
    sudo apt-get remove liboverlay-scrollbar-0.1-0

Also, in your package NEVER install the following packages

    unity unity-common
