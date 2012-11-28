---
title: Chef Testing Stratagies Compared
layout: post
---

## MiniTest/chefspec:

Minitest is an integration testing tool that allows one to make assertions about the final state of the machine after the cookbook run. This requires a 'clean' machine to run your cookbooks on to get accurate results.

* Pros:
The most logical way to automate tests that you would generally do manually. Gives you the freedom to refactor a cookbook or library and still confirm that it performs your intended actions.

* Cons:
Slow, you must spin up a machine using test-kitchen, vagrant, or some other virtualization technology. LXC is a great candidate for running minitests, but that is bound to a single platform.

* Link:
https://github.com/calavera/minitest-chef-handler
https://github.com/acrmp/chefspec

* Pipelineable?
Yes. This framework was designed with pipelines in mind.

# Example

    describe 'mysql::server' do
      it 'runs as a daemon' do
        service(node['mysql']['service_name']).must_be_running
      end
    end

This example will check if mysql is running, provided that attribute is populated.

## Cucumber Chef:

Cucumber chef is an integration testing tool that uses an easy to read and write syntax to describe testing scenarios and infrastructure.

* Pros: 
Allows you to use gherkin syntax to describe your infrastructure and test the outcome of your recipes. A natural choice for doing true TDD on your cookbooks. 

* Cons:
Many people don't like gherkin as it is very verbose. It makes some serious assumptions about your workflow and intentions. Not necessarily a bad thing, but it is very opinionated. By default it sets up an EC2 instance that your tests will run inside using LXC. This takes a while and requires you to be online.

* Speed:
Cucumber itself is fast enough, but this process feels like a kludge. Needing to be online and spending (marginal) amounts of money when I have a linux computer in front of me feels bizarre. I understand the cross platform reasoning behind it, but I would prefer some options.

* Link:
https://github.com/Atalanta/cucumber-chef/wiki

* Pipelineable?
Not a natural fit for a pipeline due to it's reliance on EC2, but could be done. 

# Example

     Scenario: Chef-Client is running as a daemon
      When I run "ps aux | grep [c]hef-client"
        Then I should see "chef-client" in the output
        And I should see "-d" in the output
        And I should see "-i 1800" in the output
        And I should see "-s 20" in the output

## Test-Kitchen:

Test kitchen simply runs your cookbooks against a few clean virtualbox nodes running different versions of different operating systems. It does not run any external verification, but you can leverage minitest to accomplish this. 

* Pros: 
Really easy to understand the results. Great replacement for manual testing. 
Can spin up a bunch of different platforms for testing your cookbook on different operating systems.

* Cons:
Time Consuming. Needs to build a bunch of VMs using vagrant and run against it.

* Link:
https://github.com/opscode/test-kitchen

* Pipelineable?
Debatable, at great length. It can be, but the length of time it takes, and the difficulty of capturing useful output limits its effectiveness.

## chef whyrun: 
Whyrun is a mode that in chef 10.14 or higher will give you an idea of what chef would have done on the node, had you run without it. This is similar to puppet's dry-run mode, but has a few gotchas, such as it always assumes the positive outcome of only_if and not_if statements. It also does not cope well with interdependencies between cookbooks, as it has no way of verifying if a previous run was successful. 

* Pros:
Better than nothing, good for debugging single cookbooks and recipes.

* Cons:
Very verbose output, hard to parse for correctness with anything other than trained eyeballs. 

* Link:
http://www.opscode.com/blog/2012/09/07/chef-10-14-0-released/

* Pipelinable?
It is, but you would need to parse and capture the output and visualize it in an information radiator, which would not be impossible. It belongs on the left-ish.

## Foodcritic:
Foodcritic is a linting tool to ensure Consistency and enforce some best practices in your cookbooks. There are two additional sets of rules that you can add to it, etsy and customink. 
This is run simply with `foodcritic -I $location_of_custom_rules $cookbook_path/$cookbook_name`

* Pros:
Enforces Cons:istency and a clean style for your cookbooks. Fast. Easy to use.

* Cons:
none.

Pipelineable?
Definitely. This belongs on the far left of the pipeline, or ideally run pre-commit. 

# Example: 

    stillinvisible ~/Corp/CorpChef $ foodcritic -I foodcritic/* cookbooks/CorpBuildTools 
    CINK001: Missing CHANGELOG in markdown format: cookbooks/CorpBuildTools/CHANGELOG.md:1
    FC033: Missing template: cookbooks/CorpBuildTools/recipes/phantomjs.rb:13

This output means that my CorpBuildTools cookbook violates a few rules, and FC033 would cause my cookbook to fail to converge. Absolutely valuable, time-saving output.


## knife cookbook test: 
This is merely a syntax checker. Handy, but not nearly as comprehensive as it should be. As long as your recipies parse properly, this will pass. That means that you can have something like

    execute "clean yum cache" do
      command "yum clean all"
      command "yum install ruby"
      mode "744"
      action :nothing
    end

There are two glaring mistakes in that execute statement, but `knife cookbook test` won't catch them, despite the fact that the cookbook won't even compile. Don't depend on this too heavily.

* Pros:
Will catch syntactic errors and prevent you from checking in stupid mistakes.

* Cons:
Fails to catch errors that will cause the cookbook to not compile.
Pipelineable?: Definitely. Belongs on the WAY left side of the pipeline, or better yet, pre-commit.

## Fast and dirty debugging

Iterating with chef-server is a pain if you're pinning your cookbook versions (which you should be). A way around this is to use chef-solo where you can. I am definitely not advocating this workflow, but if you're looking at why a machine converged a certain way, it can be helpful to try this. 

Create a file with the following contents:

#   solo.rb
    file_cache_path "/var/chef-solo"
    cookbook_path ["/var/chef/cache/cookbooks/"]

Create another file with whatever attributes you need to use, and a run_list:

# solo.json
    { 
      "run_list": [ 
      "recipe[CorpBuildTools::buildgems]"
      ] 
    }

Run `chef-solo -j solo.json`. Observe the results, and make some changes. This can be useful when debugging a recipe on a disposable machine.


## Tying it all togther:
Strainer is a tool that allows you to setup a workflow of testing tools and then run them against a cookbook while you are developing. My `Colanderfile` looks like this: 

    knife test: bundle exec knife cookbook test $COOKBOOK
    foodcritic: bundle exec foodcritic -I foodcritic/* cookbooks/$COOKBOOK
    chefspec: bundle exec rspec cookbooks/$COOKBOOK

I keep it in the same directory as the cookbook's metadata.rb. From the top level run `bundle exec strain cookbook_name` and this will run knife test, foodcritic with any custom rules indicated by the -I flag, and then run the specs. This saves a bunch of typing, and can be automated with watchr or similar if you desire. Why-run could also be used as part of this workflow. 

    stillinvisible ~/work/Corp/CorpChef $ tree cookbooks/CorpBuildTools 
    cookbooks/CorpBuildTools
    |-- attributes
    |   `-- default.rb
    |-- Colanderfile
    |-- files
    |   `-- default
    |       `-- tests
    |           `-- minitest
    |-- Gemfile
    |-- Gemfile.lock
    |-- metadata.rb
    |-- README.md
    |-- recipes
    |   |-- buildgems.rb
    |   |-- bundler.rb
    |   |-- default.rb
    |   |-- foodcritic.rb
    |   |-- git.rb
    |   |-- phantomjs.rb
    |   `-- ruby.rb
    |-- spec
    |   |-- buildgems_spec.rb
    |   |-- bundler_spec.rb
    |   |-- default_spec.rb
    |   |-- git_spec.rb
    |   `-- phantomjs_spec.rb
    |-- templates
    |   `-- default
    |       |-- CorpSoftware-phantomjs.repo.erb
    |       `-- Gemfile-build.erb
    `-- test
    `-- kitchen
    `-- Kitchenfile

Your cookbooks will begin to look more like real software when tests are added. If you're hosting them internally, perhaps it's time to start treating them that way and giving each one it's own git repo.

## Conclusion:
We're using a combination of chefspec, minitest, foodcritic and vagrant for our pipeline. We haven't completed it yet, but will publish details when we do. Local development is done using foodcritic, chefspec, and vagrant as well. I'm open to suggestions and would be interested in hearing what others are doing. 

* Pipelineable is a real word in the resource extraction business, so I thought it was ok to use here.
