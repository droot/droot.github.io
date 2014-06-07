---
layout: post
title: "7 things one can do to scale up a web application"
date: 2014-08-07 21:20:23
---

![scaling up][1]

Recently at work, we had to undertake a quick exercise of scaling up our web application which taught me a few things which I thought of sharing with the community. We are using following technology stack at work: 

* Python as our primary language for most of our work at the backend
* [Pylons][2] (Webframework)
* MongoDB (NoSQL datastore)
* [Redis][3] (Cache)

Lets jump in to the seven steps that worked for us and hope that most of them can be applied to any web application.

1\. Profile your web application: In order to understand the execution pattern from performance perspective, first step would be to profile application. Profiling can bring out some interesting insights about your application. Within 10 minutes of profiling we were able to figure out some of the very important (low-hanging) performance fixes. Another reason for enabling profiling is that if you do some performance fixes, it quickly helps you measure the difference as well.

These days most of the web frameworks provide profiling tools with them. For our web framework Pylons, we used  ProfileMiddlware from paste package.

* You need to install python-profiler package. following command should do the trick for you if you are using Ubuntu:

> sudo apt-get install python-profiler

* Add following lines in your pylon's application middleware.py i.e. <app_name>/config/middleware.py

> from paste.debug.profile import ProfileMiddleware
>
> app = ProfileMiddleware(app, config, log_filename='profile.log.tmp', limit=40) #in the custom middle ware section

With above steps performed, you should see profiler output on the console (stdout) if you are running in dev mode. Now identlfy the code paths which are the real bottlenecks.

2\. DB Query Profiling: Since most of webapps are powered by some kind of data store, profiling data store query profiling would give you some interesting insights about the slower operations in your application. In our case, since we are using mongodb. It provided one command line switch for verbose mode (-vvvvv) for different verbosity levels to understand query execution happening at server. It helped us to identify some of the most frequent and slow queries and in 90% of the cases, all we needed was to define indexes on our collections and we were done. Things may not be that simple in your case but it will ateast give your engineers enough to understand what needs to be attacked in the application.

3\. Enable Data Caching: Caching can be your biggest friend for scaling up and it can be done at various levels. Caching strategy depends on usecases in your application and for some of the popular usecases like page-level-caching etc, most of the frameworks provides support out of the box. For ex. for Pylons, beaker cache module provides supports most of caching use cases.Just to give you example of caching scenarios, in our cases we observed most of our application pages can be cached for non-logged state and we wrote our custom caching module to enable page-level caching for non-logged mode. Now we are in process of going one step down to enable data-level caching for even logged-in version. Caching can be your biggest friend for scaling up your app (I am going to do a follow up blog post on caching work that we did)

4\. Background certain tasks: While improving response time for some of the requests in our webapplication, we found lot of things which were not needed to be performed inline in the request handling path and could be performed as background job. There are some standard off the shelf components available these days for most of the web frameworks. For ex. resque if you are using Ruby on Rails. In our case, we used python based [Celery][4] for backgrounding certain tasks.

5\. Combining JS/CSS:  We observed that we had 17 CSS and 9 JS files being included in different pages of our application which were leading to 26 IO requests which were bad from the server as well page-load perspective. So simply combining all the JS files and CSS files in one file for JS and CSS each, we cut down on 23 IO requests from our server which improved our page load performance as well. Most of the webframeworks provide minification/combining modules for JS/CSS files. In our case, we used MinificationWebHelpers module. javascript_link helper and stylesheet_link needs to be passed with extra flags as shown below.


> ${h.stylesheet_link('/css/ext-libs/jqModal.css',
                    '/css/ext-libs/jquery-ui-1.8.custom.css',
                    '/css/ext-libs/jquery.jcarousel.css',
                    ...........
                    '/css/explore/exp_common.css',
                    minified = True, combined = True, combined_filename = 'app.css')}

6\. Server Static content from Other Server: If your web application contains lot of static content like images etc., then it would be good idea to serve the static content from other services like Amazon S3 which are better suited for this purpose. It will further cut down on IO requests being served from your web server. We used Amazon S3 for serving our images. Also in our case, there was some content which is not exactly static like user images which get changed when user uploads a new image, we used Amazon S3 API (python's boto library) to push the new/changed images on the fly to the Amazon S3. You can take further advantage of hosting images on Amazon S3 by enabling Amazon CDN service to power this content from Amazon's CDN infrastructure which can further improve page-load performance.

7\. Correct Logging Strategy: This one is a very low-hanging one and may not be the problem in your case but we observed that there were lot of logs enabled in our production setup and were needed to bumped down in their log-levels. A quick one hour exercise led to assigning right log levels to all the noisy log statement.

I hope you will find above tips useful. It would be great to hear about some of the tips that you must have applied in your app. We are pretty much done with the vertical scaling exercise and I am going to follow up this post with the horizontal scaling exercise which we are starting off this week.

[1]: http://farm3.static.flickr.com/2383/1976880927_8f936fe4e1_m.jpg
[2]: http://www.pylonshq.com
[3]: http://code.google.com/p/redis/
[4]: http://www.celeryproject.org/
