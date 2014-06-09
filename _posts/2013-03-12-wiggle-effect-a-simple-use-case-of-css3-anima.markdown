---
layout: post
title: "Highlight Call to Action by giving a small Wiggle"
date: 2013-03-10 21:20:23
---

Today, when I was trying out a new application [bufferapp][1], I noticed something very interesting in their interface which immediately caught my attention. Although it is a tiny little detail about the interface, but I think it is one of the very important ones especially in context of a web app, so I thought of writing it down.

If you have used bufferapp, you will notice following things (shown in the picture below):

* High level navigation at the top (header section).
* Notification with some call to action right beneath the header section (in this case Install Chrome extension)
* Main content section which is about buffering your tweets. 

![][2]

The detail that I wanted to point out was, when I am navigating from bottom section to the header section, I would see "install" button wiggles for a moment. Now that momentary wiggle made me pay attention and read that message to understand install what ?  It felt exactly like as if you are navigating through your office corridor and someone calls you out to show you something. So this "wiggle for .2 seconds" was almost like someone calling out to make sure I read that message. You can see this in action [here][3] in modern browsers specifically Chrome, Safari or Firefox.

You will see this layout pattern in lot of places where application is trying to communicate something important to the user and would like him/her to take an action like in this case Buffer wanted me to install their chrome extension as I was using Google Chrome. Typically, users develop a blind eye to some of these layout patterns and it becomes very challenging for the interface designer to craft an experience which could draw user's attention to an important action.

These simple but important details separates a good design from a great design. In rest part of the post, I would throw some light on implementation details for this wiggle effect. Most of the modern browsers support animation through CSS3 these days.

keyframe definition for wiggle effect would look like this: (omitting the browser prefix for better readability)

{% highlight css %}
@keyframes wiggle {
  0% { transform: rotate(2deg); }
  50% { transform: rotate(-2deg); }
  100% { transform: rotate(2deg); }
}
{% endhighlight %}

Think of keyframes directive as defining a animation function which will be called later on elements like buttons in our UI. We implement wiggle function by first rotating the subject by 2 degree anticlockwise, then to 2 degree clockwise and then rotate it back by 2 degree anticlockwise.

Let say our html markup for flash message looks like this:

{% highlight html %}
<div class="flash_message">
  Install Now
</div>
{% endhighlight %}

Inorder to invoke it on a mouseover of the flash message block. Our invokation code in CSS would look like this:

{% highlight css %}
.flash_message:hover a.call_to_action {
  animation: wiggle 0.2s;
}
{% endhighlight %}

This is a classic example of applying CSS3 techniques at the experience layer in your application. Let me know what you think of such experiences, drop a note below in the comment section or tweet me [@_sunil_][4] .

[1]: http://bufferapp.com/
[2]: https://phaven-prod.s3.amazonaws.com/files/image_part/asset/29299/SJdP9iq-WbjZoN04vhLbZQDvDsU/medium_Wiggle_Example.jpg
[3]: http://droot.github.com/wiggle/
[4]: http://twitter.com/_sunil_
