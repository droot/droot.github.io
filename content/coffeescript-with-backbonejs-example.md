---
layout: post
title: "CoffeeScript with Backbone.js Example - Violet Hill"
date: 2011-04-06 21:20:23
hidePostInHomePage: true
---

I have been spending sometime researching development strategies for building heavy Javascript application. I have been having some fun playing with backbone.js and coffeescript. I did not find some good tutorials that explains combine usage of these two awesome projects, so I thought of writing one myself.

Before we start, here is a quick intro about Backbone.js and Coffee Script from from their main website itself.

> 1. Backbone.js: [Backbone][1] supplies structure to JavaScript-heavy applications by providing modelswith key-value binding and custom events, collections with a rich API of enumerable functions, views with declarative event handling, and connects it all to your existing application over a RESTful JSON interface.
>
> 2. Coffee Script: [CoffeeScript][2] is a little language that compiles into JavaScript. Underneath all of those embarrassing braces and semicolons, JavaScript has always had a gorgeous object model at its heart. CoffeeScript is an attempt to expose the good parts of JavaScript in a simple way.

In order to demonstrate usage of backbone.js and coffeescript, let me first describe you a simple example that we going to build today. You can see the final build example [here][3]. Basically, we will build a color-box configurater which takes size and color for square box to be drawn. Changes in the configuration should reflect in real time on screen. This type of functionality you see in any visual designer part of an IDE.

![Coffeescript and Backbone.js example][4]

 

Example consist of following parts:

## Configuration Model
It basically contains three configuration properties, i.e. height, width and color of the box. We create ConfigModel class which inherits Backbone.Model class and its initialize method (which gets invoked when an instance is created) sets up the default values of the three properties. 

```js

class ConfigModel extends Backbone.Model
  initialize: ->
    @set 'color': 'blue', 'width': '100', 'height': '100'

```

## Configuration View
This view contains two input text boxes which are initialized with default values. This view is responsible for capturing inputs and updating the underlying model. We define two form fields color-input and width-input for taking color and size of the square. Note the identifiers (color-input/width-input) of these two elements and identifier (config-input) of the config container as they will be used coffee script part of the code.

{{< gist droot 905984 >}}

ConfigInputView class defines the presentation layer of the configuration input and it inherits from Backbone.View class. Initialize method creates a linking between the underlying model with this instance of ConfigInputView class. Events field of the class basically binds keyup events on both the input boxes to updateConfig function. updateConfig function simply updates the underlying model's three properties height, width and color. Note the thick arrow here "=>" which specifies that updateConfig function should be invoked in context of this instance of ConfigInputView. 

{{< gist droot 905969 >}} 

## ColorBoxView
This view is responsible for presenting a single colored box as per the configuration. This view responds to changes on configuration model. Another point to note here is there can be more than one instance of such views and all of them respond to changes in the configuration. We define ColorBoxView which inherits from Backbone.View. Initialize method of the view create a compiled class from a template which is also defined below. We define a method render which simply redraws the content of color box by generating HTML for the containing element from current configuration. Note we bind render method to be invoked on any change event on the underlying model. The underlying model is config model which gets changed on every keystroke in any of the two input boxes. Render function again defined using thick arrow "=>" makes sure that render function is invoked in context of ColorBoxView instance.

{{< gist droot 905972 >}}

This is the HTML template file that we use for a color box presentation. We are using jquery template library. Two data pieces ${width} and ${color} are filled in the render function to generate the template.

```html

<script type="text/x-jquery-tmpl" id="color-box-template">
     <div style="margin: 20px; float: left;height:${width}px; width: ${width}px; background-color: ${color}; border: 2px solid;">
     </div>
</script>

```
 

## Controller
Controller is kind a core which binds everything together basically the above three components together. Controller class inherits from Backbone.Controller class and instantiates one instance of ConfigModel, ConfigInputView each and five instances of ColorBoxView. Each of the ColorBoxView gets ConfigModel instance as underlying model.

```js
class ColorBoxController extends Backbone.Controller
    initialize: ->
       model = new ConfigModel
       color_input = new ConfigInputView 'el': $('#config-input'), 'model': model
       for x in [1..5]
          view = new ColorBoxView {model: model}
          $('#color-boxes').append view.render().el
```
 

Lastly we define a global init method which create an instance of ColorBoxController and is invoked on documentLoad event of JQuery.

```js
init = ->
    cbl = new ColorBoxController
 
$(document).ready init

```
I am sure you will have a few questions about the post, please comment below or tweet me [@_sunil_][5]

[1]: http://github.com/documentcloud/backbone/
[2]: http://jashkenas.github.com/coffee-script/
[3]: http://droot.github.com/colorbox/app.html
[4]: http://droot.github.com/colorbox/cf_1.png
[5]: http://twitter.com/_sunil_
