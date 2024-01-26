---
layout: post
title: "URL Shortener Service Using Redis"
date: 2010-01-06 21:20:23
hidePostInHomePage: true
---

I have been following ['Redis'][1] from sometime and got an opportunity to use it in one of the weekend projects (URL Shortner). I had a great experience using Redis in the project, so thought of writing a blog entry describing some aspect of the project to demonstrate a use case for Redis.

The project was to build URL shortener web application. We want our URL shortner service to provide following functionalities:

* URL Shorten/Expand: Given a long URL (say, <http://www.google.com/....)>, our service will generate a short-key e.g. xyz so that a short URL <http://ab.ly/xyz> (hosted on a domain <http://ab.ly>) when accessed, visitor will be redirected to the original long URL (<http://www.google.com/..)>
* Record Clicks: We want to record the number of times a short URL (<http://ab.ly/xyz)> has been visited
* Recent Visitors for a short URL: We want to store basic information e.g referrer, user agent, ip etc for recent n visitors for a given short URL.
* List of Recent Short URLs generated by the service.

Skipping the web-application details, I would focus on the core URL-Shortner module that I wrote in python using Redis as back-end storage. You can read more about the Redis at [http://code.google.com/p/redis/][2], here is a quick description from Redis website.

> "Redis is an advanced key-value store. It is similar to memcached but the dataset is not volatile, and values can be strings, exactly like in memcached, but also lists, sets, and ordered sets. All this data types can be manipulated with atomic operations to push/pop elements, add/remove elements, perform server side union, intersection, difference between sets, and so forth. Redis supports different kind of sorting abilities." [more][3]..

One good part about the redis is that it took just 2 minutes (a few lines of instructions) to get Redis up and running. I loved the simplicity and documentation of the project. I think simplicity of installation and getting a sample app running in few minutes are signs of a good open source project.  Big thanks to [Salvator Sanfilippo][4] (lead developer of Redis and team) for the wonderful work. 

Rather than debating over why Redis for storage part, I want to focus on HOW Redis can be used to build a URL shortener service (that is the best part I like about weekend projects, you dont have to break your head to justify why you are doing things in a specific manner :)).

The core module is written in python, so we will use py-redis, the python bindings for Redis client. You can download latest code of py-redis from the project's [github page][5]. Again, py-redis is also a very well documented library and Thanks to [Andy McCurdy][6].

## Basic Design:

The basic design is that we will use a global counter with redis key 'next.url.id' for generating key for short urls. So everytime we generate a new short URL, we just increment the global counter and returns the hexadecimal version of the counter value as the short url key.

Assuming current value of the counter stored in the key 'next.url.id' is 1000. So next URL shorten request for a URL (say, <http://www.google.com/...)> will increment the counter to 1001 (hex value = 3e9). So Redis key 'url:<short-url-key>:id' (e.g.'url:3e8:id') for short url <http://ab.ly/3e8> will contain string value for long URL 'http://www.google.com/...'

For each short URL, we need to store clicks. So, we will maintain another key 'clicks:<short-url-key>:url'  (e.g.'clicks:3e8:url') with value type int to store number of clicks.

For each short URL, we also will maintain another key 'visitors:<short-url-key>:url' (e.g. 'visitors:3e8:url') which will point to list data structure which will store each visitor detail in form of JSON format. 

A global key with name 'global:urls' pointing to a LIST data structure containing the hex-code of n recent short URLs.

## Code Details:

Lets look at some code of the UrlShortner module. please note that you will encounter references to 'self.r' in the code which refers to the redis object created using self.r = Redis(db=0) in the  __init__ method of our core module.

Now lets look at the basic functions of the URL shortner core module.

1\. Shorten function of our module will look something like this. Given a long_url, this function generates the short-url-key which can be distributed to outside world. e.g. for <http://www.xyz.com/..>. ==> 3e8 as above, short-url = <http://ab.ly/3e8>

```python
  def shorten(self, long_url=None):
    url_hash = '%x' % self.r.incr('next.url.id') #hex value of the counter
    #next we store the long_url against this hex key
    self.r.set('url:%s:id' % url_hash, long_url)
    #push this new short url in global list of urls
    self.r.push('global:urls', url_hash)
    return url_hash 
```

2\. Expand function is required by the service to resolve a short URL needed for redirection when a user visits the short url. So expand function will look like this:

```python
  def expand(self, url_hash = None):
    return self.r.get('url:%s:id' % url_hash) 
```

3\. When someone visits a short URL, then we need a function to record the visit information (e.g IP address, user agent, http referrer etc). Here is what visit function will look like:

```python
  def visit(self, url_hash = None, ip_addr = None, agent = None, referrer = None):
    #create an object of Visitor types
    visitor = Visitor(ip_addr, agent, referrer)
    #push the visitor object in the visitor list of this short URL
    self.r.push('visitors:%s:url' % url_hash, json.dumps(visitor))
    #increments the clicks of the short url
    return self.r.incr(clicks:%s:url % url_hash)
```

Please note that we would have wanted the above two operations to be atomic. but I realized very soon that they do not have any side effect if they are performed in an interleaved fasion. 

4\. In order to find out the click count of a short URL, the code will be very simple as:

```python
  def clicks(self, url_hash = None):
    return self.r.get(self.URL_CLICKS_KEY % url_hash)
```

5\. In order to list down the recent 100 visitors of a given short URL, the function will look like this:

```python
  def recent_visitors(self, url_hash = None):
    visitors = []
    for v in self.r.lrange('visitors:%s:url' % url_hash, 0, 100):
      visitors.append(json.loads(v))
    return visitors 
```

Please note above, as we were storing visitor info object in JSON format, we need to convert back in to python object.        

6\. In order to view recent 100 short urls in the system, another helper function in the module will look something like this:

```python
  def short_urls(self):
    return self.r.lrange('global:urls', 0 , 100)
```

So a web application on top of this core module can be written to power up URL Shortening web service. I will share the core module on github after giving some final touches and will share the link. 

I hope the post will help users to think more about use cases for Redis. Do share your thoughts in comments.

[1]: http://github.com/antirez/redis
[2]: http://code.google.com/p/redis/<mce:script%20type=
[3]: http://code.google.com/p/redis/
[4]: http://www.twitter.com/antirez
[5]: http://github.com/andymccurdy/redis-py/
[6]: http://github.com/andymccurdy