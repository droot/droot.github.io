---
layout: post
title: "NewRelic's default conf drags Play Scala app "
date: 2014-06-14 21:20:23
---

Last week I learned about an important tweak in NewRelic configuration to avoid performance issues with Play Scala webframework.

While benchmarking our play-scala app I was surprised to see poor performance numbers given that play framework claims to be one of high performant web frameworks around.
App wasn't able to serve more than 200~230 requests per seconds for a simple DB lookup operation. Some serious digging revealed that default configuration of NewRelic for Play framework adds serious drag to the app's performance.


I contacted folks at NewRelic and they were quick to respond. Here is what I learned from them about the instrumentation: 

>In order to properly track async activity, we instrument Scala promises and
>futures. Unfortunately naming the tracers using these classes are not helpful
>at all. In effort to improve trace segment naming, I take a Thread.stacktrace
>and navigate up the stack to find a useful caller and name based on that. The
>call to Thread.stacktrace can be relatively expensive and result in
>significant overhead. The setting we suggested disables this functionality and
>has reduced overhead significantly for several other customers.

So, all you need to do is to turn off *stack_based_naming* in your newrelic.yml. Remember to put this configuration under transaction_tracer section.

```python
  transaction_tracer:
      stack_based_naming: false
```

Here is a side by side comparison of running Apache Benchmark (ab) with 10K requests with concurrency of 10 with/without the configuration tweak.

![image-src](/new_relic_play_configuration_tweak.png)

You can see the difference in throughput *1300 requests per second* vs *220 requests per second*.

NewRelic should turn off *stack_based_naming* setting by default. 

Hope you find this tip helpful. If I had known about it, it would have saved me couple of days :).
