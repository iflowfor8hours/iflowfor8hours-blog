---
title: Puppet Vim Development Environment
layout: post
---

This assumes that we're running linux, vim is your main editor and you are comfortable in it, and bzr is the vcs you are using.

Install puppet, facter, and bzr on your local box:

    sudo apt-get install puppet facter bzr

On the vim side of things, you need to install a few plugins to make your life easier.

[NERDTree][1] for file navigation

[Snipmate][2] to make it more difficult for you to forget commas in manifests

[VCSPlugin][3], because you will be working with bzr in our case, but you can use whatever VCS you please

You also need the puppet [snippet][4] file, which is a good start, but editing it will get you far. I have one that I have added a few sections to that I will publish to my github. The link is at the top of this page. This goes in `~/.vim/snippets/`

For bzr we need to add a few plugins as well. 

Put the following script into your ~/.bazaar/plugins directory, chmod +x it and name it `pre_commit.py`

    #!/usr/bin/env python
    #
    # BZR pre-commit hook, which will run some basic syntax checking on manifests
    # in the current branch.
    #
    # To use this script, place it in your ~/.bazzar/plugins directory (create
    # this directory if it doesn't exist).
    #
    from bzrlib import branch
    import os
    import sys
    import subprocess
    def get_branch_root(directory):
        """Find the root directory of the current BZR branch."""
        while os.path.exists(directory):
            if os.path.exists(os.path.join(directory, '.bzr')):
                return directory
            if directory == '/':
                break
            (parent, dir) = os.path.split(directory)
            directory = parent
        print "Commit FAILED:  Can't locate BZR Root."
        sys.exit(1)
    def check_puppet_syntax(local, master, old_revno, old_revid, future_revno,
                           future_revid, tree_delta, future_tree):
        """This will run some basic syntax checking on the puppet manifests."""
        # Check syntax on changed files
        errors = []
        os.chdir(get_branch_root(os.getcwd()))
        print "\n" # make some space so we aren't clobbered by bzr's status msgs
        for file in tree_delta.added + tree_delta.renamed + tree_delta.modified:
            file = file[0]
            if file.endswith(".pp"):
                print "Checking syntax in: %s" % (file)
                try:
                    process = subprocess.Popen(["puppet", "parser", "validate", file],
                        stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
                    process.wait()
                    if process.returncode != 0:
                        errors.append((file, ''.join(process.stdout.readlines())))
                except OSError, e:
                    print "\n\n Error: failed to execute 'puppet': %s" % (e)
                    sys.exit(1)
        if errors:
            print "\nSyntax errors were found:\n"
            for error in errors:
                print "%s: %s" % (error[0], error[1]),
            print "\nCommit FAILED"
            sys.exit(1)
        else:
            print "\nAll syntax checks PASSED"
    # This is where the magic happens
    branch.Branch.hooks.install_named_hook('pre_commit', check_puppet_syntax,
                                           'Check puppet manifests for syntax errors.')


You also need the bzr push-and-update plugin. This allows you to (obviously) push your changes and update a working tree elsewhere in one command. It's annoying to have to run to your puppetmaster box and type `bzr up` every time your push a change.

    cd ~/.bazaar/plugins
    bzr branch lp:bzr-push-and-update

Now in the browser:

If you're just starting out, having this open builds confidence and gets you past some of the head banging associated with the teething problems in puppet. Most of the stuff mentioned in this doc we're already past, but it's a good reference anyway.
http://bitcube.co.uk/content/puppet-errors-explained

Always keep this open somewhere, its the type reference that you will be building with:
http://docs.puppetlabs.com/references/2.7.0/type.html

I can't say enough nice things about this guy's blog. When I was searching for answers on how to do things I consistently came across it. A great resource:
http://www.devco.net/

I also always idle in the #puppet irc channel on freenode. Helpful folks there. I'm abetterlie there, but there are many people far more knowledgeable and helpful than I am idling there.

Now you can start developing on your local box. To test modules or just about anything, you can use

    puppet --debug --verbose modules/common/manifests/init.pp

This checks syntax and performs whatever you have in that init.pp and spits very useful debug information.

If you just want to check the syntax, you can use:

    puppet --parseonly *.pp

This isn't completely necessary, as the bzr plugin checks the syntax for you, but it's helpful to know if you're not sure when something is correct. I'm working on puppet syntax highlighting for vim at the moment. Should have something out soon.

When you're testing between clients and the puppetmaster, run the puppetmaster like so:

    puppet master --verbose --logdest console --no-daemonize

This keeps the master in the foreground and you may watch everything it's doing. 

On the client:

    puppetd --debug --verbose --logdest console --no-daemonize --server puppetmaster.vo-stage.srfarm.net

You can also ad the `--noop` flag if you want it to dry run instead.

When you are ready to push changes, do a 

    bzr commit -m "commit message"
    bzr push bzr+ssh://root@192.168.12.164/etc/puppet

This should push the changes and update the tree on the puppetmaster, if you have the push-and-update plugin for bzr installed.

## Puppet structure ##

The best source of ideas of how to structure your puppet modules and infrastructure, I have seen is definitely in the [example42 git repo][5]

[1]:http://http://www.vim.org/scripts/script.php?script_id=1658
[2]:http://www.vim.org/scripts/script.php?script_id=2540
[3]:http://www.vim.org/scripts/script.php?script_id=90
[4]:http://www.devco.net/code/puppet.snippets
[5]:http://www.github.com/example42

The way they do it is easiest to understand if looked at like so:

    site.pp
    -medium/site.pp
    --baselines/minimal.pp
    ---modules/$modulename/manifests/init.pp
    --nodes/vo-stage.srfarm.net.pp
    -roles/*.pp

### Handy general debugging commands

To clean Certificates for a single client:
On the server:
`puppetca --clean client.hostname`
On the client:

    rm -rf /etc/puppet/ssl/certs/*
    rm -rf /etc/puppet/ssl/private_keys/*
    rm -rf /etc/puppet/ssl/certificate_requests/*
    rm -rf /etc/puppet/ssl/public_keys/*

To test snippets of code:

    puppet --debug --verbose test.pp /*
