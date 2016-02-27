Vagrant Box for Ansible Control Machine
============================

## Box name

[`williamyeh/ansible`](https://atlas.hashicorp.com/williamyeh/boxes/ansible)

## Included software

- [debian-8.3.0-amd64](http://cdimage.debian.org/cdimage/release/8.3.0/amd64/) for its smaller size than Ubuntu.

- [Ansible](https://github.com/ansible/ansible), of course.

- Some supporting stuff for Ansible [Cloud Modules](http://docs.ansible.com/ansible/list_of_cloud_modules.html).

- [Zsh](http://www.zsh.org/)

- [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)

- A few handy tools, such as [ack](http://beyondgrep.com/), [htop](http://hisham.hm/htop/).


## Purpose

Ansible **control machine** is designed to run on Unix. According to official [Windows Support](http://docs.ansible.com/ansible/intro_windows.html) document:

> **Reminder: You Must Have a Linux Control Machine**

> Note running Ansible from a Windows control machine is NOT a goal of the project. Refrain from asking for this feature, as it limits what technologies, features, and code we can use in the main project in the future. A Linux control machine will be required to manage Windows hosts.*

> Cygwin is not supported, so please do not ask questions about Ansible running from Cygwin.*

That said, you may still need to use Windows as the control machine. An easier way is to install Ansible *inside a Linux virtual machine*, recommended by Jeff Geerling in his *[Ansible for DevOps](https://leanpub.com/ansible-for-devops)* book.

### What if I don't want to use the virtual machine approach?

Another way is to use Cygwin, but there may be some strange issues.

Experiment with the following articles at your own risk!

1. [Install a Babun (Cygwin) Shell and Ansible for Windows](https://chrisgilbert1.wordpress.com/2015/06/17/install-a-babun-cygwin-shell-and-ansible-for-windows/)
2. [ansible-playbook-shim](https://github.com/rivaros/ansible-playbook-shim)




## Build the box yourself

Here are steps you can follow to build the box on your own.


First, install the [Packer](https://www.packer.io/) tool on your host machine.

Second, pull the [Bento](https://github.com/chef/bento) submodule:

```
# pull the Bento project
git submodule init

# copy Bento stuff to sub-directories
# since Packer doesn't push soft links to Atlas (defects!)...
./copy-bento.sh
```

Third, choose the box directory of your choice:


```
# change working directory to any specific OS;
# for example, "debian-jessie" (currently the only one)
cd debian-jessie
```


Now, you can either generate the Vagrant box file *on your machine*:


```
# build `ansible-control-machine`:
packer build ansible-control-machine.json


# build `ansible-control-machine`, VirtualBox version only:
packer build -only=virtualbox-iso  \
       ansible-control-machine.json


# build `ansible-control-machine`, VirtualBox version only,
# with pre-downloaded ISO file from `file:///Volumes/ISO/`:
packer build -only=virtualbox-iso  \
       -var 'mirror=file:///Volumes/ISO/'  \
       ansible-control-machine.json
```

you'll get an 'XXX.box' file in the `builds` directory, if successful.


Or, you can *delegate the building and hosting tasks* to [Atlas](https://atlas.hashicorp.com/):

```
# make sure the following environment variables are set:
#   ATLAS_TOKEN
#   ATLAS_USERNAME
packer push ansible-control-machine.json
```



## License

Licensed under [MIT license](http://creativecommons.org/licenses/MIT/).

Copyright © 2015-2016 William Yeh - [https://github.com/William-Yeh](https://github.com/William-Yeh).
