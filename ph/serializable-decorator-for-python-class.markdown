---
layout: post
title: "Serializable decorator for Python Class"
date: 2014-08-07 21:20:23
---

I am going to describe a quick recipe for adding serializability to a Python Class. I was playing with [Redis][1] lately and needed a quick way to save python objects in Redis. I wanted objects to be saved in JSON format and found [jsonpickle][2] to be an appropriate module to use.

Initially I thought of having a base class with serialize/deserialize functions which other class could simple inherit to add serialize functionality. Here is the base class:

To add serialize functionality to a Python class, all i have to do is simply inherit from the above class shown below and I am done. (Note that deserialize is a static method)

> class Visitor(Serializer): pass  

But then I thought of an elegant way of doing the same would be if I can specify a decorator '@serializable' while defining the class. So here is the code for decorater.

So now, I can simple specify the decorator on Visitor class to make it serializable as shown in following snippet.


So this was it. Both the above approaches has got its GOOD and BAD. Do share your views about it. If you are interested in python decorators, you might find [PythonDecoratorLibrary][3] useful.

[1]: http://code.google.com/p/redis/
[2]: http://jsonpickle.github.com/
[3]: http://wiki.python.org/moin/PythonDecoratorLibrary
