---
layout: post
title: "Asynchronous IF implementation using JQuery Deferred Objects"
date: 2012-02-25 21:20:23
hidePostInHomePage: true
---

I ran in to a situation in a project recently where I got an opportunity to use [JQuery Deferred Objects][1]. I wanted to implement an Async IF operation. Async IF operation is like watching a condition to become true (may be in future) and then invoking something when it becomes true. So this is essentially an "if" operation in async mode and your logic might involve watching more than one condition to be met.

For example:

Consider a [demo web application][2] where colored boxes (red or green) can appear on the screen depending on some logic or user action. We want to do certain things if a red box appears or a green box appears or both of them appears.

Let say we we want to do something when a red box becomes visible on our screen, so it will look something like this:

> async_if is_box_visible, "red"
>
> whenever it is true, then do_something

Another one, let say, we want to pop up blue box when we see red and green boxes are visible on our screen for the first time, so it will look something like this

async_if is_box_visible, "red"

async_if is_box_visible, "green"

whenever both the above are true, then inject blue box

So here we are composing operations which involves some async operations because we do not know when these conditions will be met. This is exactly where Deferred objects shines.

I prepared a demo for the above scenario and rest of the part, I will walk you through some samples. I have shared the entire code in github repository at [async_if][3]. You can see the demo [here][2].

Async IF Operation: It is a generic construct which takes two arguments:

* A function which checks a condition (lets call it checker function henceforth)
* Arguments to be passed to the checker function
* timeout (milliseconds) for reporting failure if condition is not met within timeout milliseconds

Async IF operation returns an object of type [Promise][4] which can be used to compose higher level application logic using jquery's operations around deferred objects. Following javascript code is generated from the coffee script [async_if.coffee][5].

```js
/* asynchronous IF construct implementation */

async_if = function(fn, args, timeout) {
    var curr_probe, dfd, probe;
    dfd = new jQuery.Deferred();
    curr_probe = null;

    probe = function() {
      if (fn(args)) {
        dfd.resolve(args); /* this will invoke success callback */
        return curr_probe = null;
      } else {
        /* lets return after 5 milliseconds to re-run checker function */
        return curr_probe = setTimeout(probe, 5); 
      }
    };
    if (timeout) {
      /* if this is timeout async operation, return failure if condition is not met within timeout */
      setTimeout(function() {
        curr_probe && clearTimeout(curr_probe);
        return dfd.reject(args);
      }, timeout);
    }
    probe();
    return dfd.promise();
};
```

Use of Async IF Operation: In code below, we are trying to build logic which is when red and green box both appears on the screen, inject a blue box on the screen. Now appearance of red and green box is purely async which will happen on user action like "injecting a box" by clicking on buttons in the demo application.

```js
/* function to detect if a box of given color is visible on screen or not */
is_box_visible = function(color) {
    var selector;
    selector = "." + color + "box:visible";
    return $(selector).length > 0;
};

$.when(async_if(is_box_visible, 'green') /* green box is visible */, 
       async_if(is_box_visible, 'red') /* red box is visible */
      ).then(
        function() {
               /* when both the red and green box appeared, inject a blue box */
               inject_box('blue');
        }
);

/* a timeout sample usecase, detect a redbox within 10seconds of start */
async_if(is_box_visible, 'red', 10000).then(
       function(color) { 
              alert('red box detected'); 
       }, 
      function(status) {
          alert("couldn't detect redbox 10 seconds....");
      });
```

Let me know your thoughts about this construct. Drop a note below or contact me at [@_sunil_][6]

[1]: http://api.jquery.com/category/deferred-object/
[2]: http://droot.github.com/async_if/
[3]: https://github.com/droot/async_if
[4]: http://wiki.commonjs.org/wiki/Promises/A
[5]: https://github.com/droot/async_if/blob/master/async_if.coffee
[6]: http://twitter.com/_sunil_
