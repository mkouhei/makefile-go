=====================
 Makefile for Golang
=====================


Status
------

.. image:: https://travis-ci.org/mkouhei/makefile-go.svg
    :target: https://travis-ci.org/mkouhei/makefile-go

Featurse
--------

* gather the metadata of the Git repository

  * initialize when you have not yet make git repository
  
* set ``GOPATH`` to ``$(CURDIR)/_build``
* ``go get`` the dependencies of your go package, and go tools.
* ``golint``
* ``go vet``
* ``go test``
* ``go tool cover``  
* ``gofmt``
* ``goimports``
* ``go build``
    
Optional
~~~~~~~~

* Support building Sphinx documentation.
* Put ``some.in`` file to extend variables.

Requirements
------------

* Golang >= 1.2
* GNU make
* Git >= 1.7
* Python 2.7 over or Python 3.4 over
* virtualenv (optional)

How to use
----------

1. git clone::

   $ git clone https://github.com/mkouhei/makefile-go.git

2. copy Makefile, make directory if you will create a new Git repository::
          
   $ install -d /path/to/somerepo  # if creating a new repo.
   $ cp makefile-go/Makefile /path/to/somerepo/

3. Change into a repo directory::
        
   $ cd /path/to/somerepo

4. running ``make``, add ``REPO=git@example.org/username/somerepo.git`` when remote.origin.url has not yet set.::

   $ make
   $ make REPO=git@example.org/username/somerepo.git  # firstly only

Tested environments
-------------------

* Debian GNU/Linux Sid
* OS X Yosemite

License
-------

``makefile-go`` is licensed under GPLv3.
