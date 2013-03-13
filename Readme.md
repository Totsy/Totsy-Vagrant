Set up a PHP development box super fast
=======================================

Installation
------------

* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* Add a CentOS 6 box using this [recommended box](http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.3-x86_64-v20130101.box), for example: ```vagrant box add centos http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.3-x86_64-v20130101.box``` (make sure it's named centos)
* Clone this repository
* Install submodules with ```git submodule update --init```
* After running ```vagrant up``` the box is set up using Puppet
* Add a hosts entry to your local system (/etc/hosts for *nix and c:\windows\system32\drivers\etc\hosts for win) for www.totsy.local pointing to 127.0.0.1
* You should now have your working Totsy dev environment under http://www.totsy.local
* Admin is located at http://www.totsy.local/admin. User: admin, Pass: admin
* The code repository is located at www/Totsy-Magento

Hints
-----

**Startup speed**

To speed up the startup process use

.. code-block:: sh

    $ vagrant up --no-provision

after the first run. It just starts the virtual machine without provisioning of the recipes.