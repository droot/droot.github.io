---
layout: post
title: "Redis Lua Scripting - Violet Hill"
date: 2014-08-07 21:20:23
---

![][1] [Redis][2] is one of my favorite data storage platform and I won't miss a single chance to use it wherever I can. One of the biggest strengths of Redis has been that you can define your data modelling in the most natural form like key-value/hashes/lists/sets. I prefer thinking of data storage in form of list, hashes, sets instead of tables :).

Redis provides a very good set of APIs(commands) which pretty much allows majority of the operations you would like to perform on these data types in a single command. 

But in the past, I encountered situations where solution design required the following:

* Executing more than one Redis commands.
* Outcome of one command would determine whether to run other commands or not.
* Atomic execution of 1 & 2 [Transactional].
* Contention environement for such operations, so optimistic locking schemes wont work.

Situations like above pretty much made me turn away from Redis in the past. 

This is going to change now. About a month ago, [@antirez][3] (creator of Redis) released [Lua-Scripting support][4] in a different branch by hacking over a weekend (that shows how terrific hacker he is).

Lua-Scripting support Redis pretty much solves majority of the problems of the nature described above. This has great potential and can't wait to see what community do with it.

I spend sometime today to try out scripting, so thought of doing a quick write up about what I did today.

I started with simple goal of implementing two new commands zpop and zrevpop for sorted set data type using scripting.

1\. ZPOP: This will allow popping out element with lowest score from a sorted set.

2\. ZREVPOP: This will allow popping out element with highest score from a sorted set.

Setup:

Follow these steps to get scripting version of Redis running on your machine.

> 2\. cd redis
>
> 3\. git checkout scripting
>
> 3\. make

Now you should all the binaries ready in the src folder (redis-server and redis-cli). Run the server by running redis-server binary.

ZPOP Implementation:

Redis implements redis.call interface to invoke redis commands from Lua code. Here is Lua script for zpop command.

Testing:

Redis server implements new command "eval" to invoke lua scripts. Quick syntax goes like this:


    EVAL <body> <num_keys_in_args> [<arg1> <arg2> ... <arg_N>]

You can test your lua script using redis-cli program. 

Lets populate sorted set named zset by inserting a, b, c with scores values 1, 2 and 3 respectively.

> ./redis-cli zadd zset 1 a
>
> ./redis-cli zadd zset 2 b
>
> ./redis-cli zadd zset 3 c

Here is command to test zpop.lua file. You should see 

> ./redis-cli -p 10000 eval "$(cat path-to-zpop.lua-file)" 1 zset
>
> 1) "a"
>
> ./redis-cli -p 10000 eval "$(cat path-to-zpop.lua-file)" 1 zset
>
> 1) "b"

On the similar lines, zrevpop can be implemented using following lua script.

I am going to do a follow up post with some complex examples to demostrate the true potential of Lua scripting.

Thanks @antirez for keeping this project on the edge by innovating at all the levels of the project. 

[1]: http://redis.io/images/redis-300dpi.png
[2]: http://redis.io "Redis"
[3]: http://twitter.com/antirez
[4]: http://antirez.com/post/scripting-branch-released.html
