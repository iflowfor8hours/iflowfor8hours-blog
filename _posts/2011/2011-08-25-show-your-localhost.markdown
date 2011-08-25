---
title: Show Your localhost
layout: post
---

I came across this handy command that allows you to show your localhost server to the world. This comes in handy if you have something running on your local box, like a webserver that has your up to the second design or configuration ideas and you need to show them to someone else. It saves you the trouble of having to setup an apache server and all that for when it's just something simple you want to showoff. This is what showoff.io was supposed to do, but for some reason, they appear to be defunct. 

`ssh -nNT -R 9000:localhost:3000 your_server`

This would show the service running on your localhost on port 9000 on `your_server` which is a publicly reachable server running ssh.
