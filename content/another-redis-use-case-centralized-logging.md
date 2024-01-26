---
layout: post
title: "Another Redis use case: Centralized logging"
date: 2011-07-30 21:20:23
hidePostInHomePage: true
---

Log analysis has become a difficult task in our production environment at work because logs are distributed on different machines and in different files. So, we wanted all the exception logs from all of our apps to be tracked centrally and viewed in single console. 

And once again, we found another good use case for Redis. Our strategy is to dump all of critical logs in to a Redis List and have a background worker which continuously pulls logs from the Redis List and write stuff in log file.

As we use python for all our backend work, I quickly wrote a Log Handler that can dump log messages in to Redis. 

So RedisLogHandler class looks like this:

```python
import redis
import logging

class RedisLogHandler:
    """Log handler for logging logs in some redis list
    """
    def __init__(self, host = None, port = None, db = 0, log_key = 'log_key'):
	self._formatter = logging.Formatter()
	self._redis = redis.Redis(host = host or 'localhost', port = port or 6379, db = db)
	self._redis_list_key = log_key
	self._level = logging.DEBUG
		
    def handle(self, record):
	try:
	    self._redis.lpush(self._redis_list_key, self._formatter.format(record)) 
	except:
	    #can't do much here--probably redis have stopped responding...
	    pass

    def setFormatter(self, formatter):
	self._formatter = formatter

    @property
    def level(self):
	return self._level 

    def setLevel(self, val):
	self._level = val
```

To hook up this RedisLogHandler to your application logger, all you need to do is following:

```python
log = logging.getLogger('')

rh = RedisLogHandler() #you can specify all redis params here
rh.setLevel(logging.WARNING) #set the filter for critical logs only
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s') #custom formatter
rh.setFormatter(formatter)

log.addHandler(rh)
```

I quickly hooked it up to our all of our background jobs in celery and I can see it working. Let me know what you think of this solution.