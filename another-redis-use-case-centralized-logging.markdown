---
layout: post
title: "Another Redis use case: Centralized logging"
date: 2011-07-30 21:20:23
---

Log analysis has become a difficult task in our production environment at work because logs are distributed on different machines and in different files. So, we wanted all the exception logs from all of our apps to be tracked centrally and viewed in single console. 

And once again, we found another good use case for Redis. Our strategy is to dump all of critical logs in to a Redis List and have a background worker which continuously pulls logs from the Redis List and write stuff in log file.

As we use python for all our backend work, I quickly wrote a Log Handler that can dump log messages in to Redis. 

So RedisLogHandler class looks like this:

{% gist 1115792 %}

To hook up this RedisLogHandler to your application logger, all you need to do is following:

{% gist 1115820 %}

I quickly hooked it up to our all of our background jobs in celery and I can see it working. Let me know what you think of this solution.