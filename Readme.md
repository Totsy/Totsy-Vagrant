Set up a PHP development box super fast
=======================================

Installation
------------

* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* Add a CentOS 6 box using this [recommended box](http://totsy:d3v@chris.totsy.com/centos.box), for example: ```vagrant box add centos http://totsy:d3v@chris.totsy.com/centos.box``` (make sure it's named centos)
* Clone this repository
* Install submodules with ```git submodule update --init```
* Add an entry in your /etc/hosts file: ```192.168.33.10 www.totsy.local totsy.local```
* Install vagrant mirror following the instructions on its [Readme](https://github.com/ingenerator/vagrant-mirror/#vagrantmirror)
* After running ```vagrant up``` the box is set up using Puppet
* You should now have your working Totsy dev environment under http://www.totsy.local
* Admin is located at http://www.totsy.local/admin. User: admin, Pass: admin
* The code repository is located at www/Totsy-Magento

Hints
-----

**Startup speed**

To speed up the startup process use

    $ vagrant up --no-provision

after the first run. It just starts the virtual machine without provisioning of the recipes.

**Clearing out an instance**

To get a fresh instance, simply run

    $ vagrant destroy

then

    $ vagrant up
