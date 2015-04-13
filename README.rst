=====================
 Makefile for Golang
=====================

Requirements
------------

* Golang >= 1.2
* GNU make
* Git >= 1.7
* Python 2.7 or Python 3.4
  
Installation
------------
::
   
   $ git clone https://github.com/mkouhei/makefile-go.git
  
Basic usage
-----------

Running ``make`` in your repository of Golang.::

   $ install -d /path/to/somerepo  
   $ cp makefile-go/Makefile /path/to/somerepo
   $ cd /path/to/somerepo
   $ make REPO=git@example.org/username/reponame.git

Optional
--------

Support building Sphinx documentation.

License
-------

``makefile-go`` is licensed under GPLv3.
