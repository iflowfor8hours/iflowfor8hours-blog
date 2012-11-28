---
title: Opscode Community Summit 2012
layout: post
---

The opscode community summit was a two day, community organized, unconferences. It was organized like many other unconferences with no set schedule or talks, merely a bunch of people sharing the same interests and then scheduling around open spaces. This format worked really well for the size of the summit, which was around 250 people.

The tl;dr summary was that almost every discussion eventually touched on the idea that our chef workflow is very broken. There were tons of differing opinions on testing, development, and management of modules. There is progress being made on all of them, but because there is no one recommended or set path for doing cookbook testing, the tools around them are constantly changing and getting abandoned.

Quick summary of some of the talks I participated in:

## Berkshelf - Jamie of RiotGames

Berkshelf is a tool that one can use to manage dependencies in cookbooks and keep a sane record of what versions of cookbooks are running. Philosophically, each unit of your infrastructure cookbooks, such as nginx and MySQL are unimportant until packaged with your application, so why do we manage them this way?

Chef server is merely an artifact repository for software, and each cookbook is an individual piece of software, therefore it deserves it's own git repo and test suite. Berkshelf can take some of the pain out of this by allowing you to specify a source and a version for each cookbook in a Berksfile, much like a Gemfile. The source can be a git repo, a filesystem, or a chef-server api endpoint.

Jamie recommends writing cookbooks that can be used in chef solo to make manual testing significantly easier and automated testing possible. At RiotGames they use Berkshelf, minitest, and test-kitchen for cookbook testing.

Jamie also reimplemented roles as cookbooks, because roles are dangerous and should not be used as they cannot be versioned, and that makes them useless. Use wrapper cookbooks.

## Instant Infrastructure - Chris of Opscode

The idea behind instant infrastructure is two fold.

One is to give people the tools to describe their real world problems so that things can be done about them. The tool he has chosen for this task is Gherkin.

The other is to give non-technical people a way to deploy a sane, managed infrastructure. The plan for this is to deploy a usb stick that will wipe a laptop or desktop, replace it with ubuntu running a chef workstation, with some example cookbooks and the ability to create more usb keys.

The idea of getting people to write acceptance critera using gherkin seems like a great idea. Giving non technical people the ability to describe their problems in a way that a developer can address directly is a good one.

## MotherBrain: Orchestration with Chef - Jamie of RiotGames

(coming to RiotGames (Riot Games) · GitHub soon)

MotherBrain has yet to be released, but it's a tool that allows one to add layers of protection to your chef runs by interacting with the chef-server API. MotherBrain files contain logic about what services must be notified before making changes. For example, they allow the user to explain to motherbrain that before bringing up the application servers, the database server configuration must be complete.

It also allows you to stop convergence of specific parts of your recipes while you debug or troubleshoot servers that are configured to converge via a cron job. This feature sounds incredibly useful for real life failover and redundancy orchestration.

## Tools to watch:
 
Cucumber-chef 2
Chef 11 !!! (mid nov release date, apparently will converge orders of magnitude faster)
minitest
test-kitchen
rspec (library testing)
fauxhai
Berkshelf
MotherBrain

## Cookbooks to look at for inspiration:

Application cookbook by opscode (how to tie a bunch of library cookbooks together properly)

Redis by miah_ (has some tests)

mysql by opscode (also has good minitest suite)

## Upcoming books:

Test Driven infrastructure with Chef (yes, again, written by the same guy so... buyer beware)

## Books to read anyway:

The cucumber book

Metaprogramming ruby

I went to more talks, mostly about TDD with chef and other testing tools. If you interested in chatting about this stuff, or have any questions hit me up! We had interesting discussions about how to isolate cookbooks in your pipeline, but no real decisions were made. Many ideas, but we're really not there yet.
