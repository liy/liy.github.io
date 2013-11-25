---
layout: post
title: "WebGL State Sorting"
date: 2013-03-31 17:05
comments: true
categories: 
---
今天又思考了一下 OpenGL alpha 问题。很早之前就研究过，因为一会儿 Ruby on Rails 一会儿 Node.js，翻来覆去就忘了。

Reducing OpenGL state changes is one of the several ways to optmize the performance. Sorting the objects into categories directly reduced state changes.

Alpha transparency is definitely required in game. This also requires objects sorting. Opaque object must be drawn first, before translucent object.

### What order?

1. From my understanding first of all, the objects must be transformed using ``model view matrix``, into eye coordinates.
2. Second, because opaque must be drawn before translucent object. Objects must be sorted into 2 categories: opaque and translucent. 
3. Sort by other states, into categories, e.g., texture id.
4. Opaque objects must be sorted into ``near to far`` order.
5. Translucent objects must be sorted into ``far to near`` order.

Of course, z-order is related to the eye position, near means closer to eye.

### How to sort? 

Here is a simple JavaScript code. Basically, it is a very simple [insertion sort](http://en.wikipedia.org/wiki/Insertion_sort). 

JavaScript can use ``Array.sort``.

{% highlight javascript linenos %}
var list = [];
var len = 100;
for(var i=0; i<len; ++i){
  var obj = {
    texture: Math.ceil(Math.random()*4),
    translucent: Math.random() < 0.5 ? true : false,
    z: Math.ceil(Math.random() * len)
  };
  list[i] = obj;
}

list.sort(sortFunc);

function sortFunc(a, b){
  if(a.translucent != b.translucent){
    if(b.translucent)
      return 1;
    else
      return -1;
  }
  
  if(a.texture != b.texture){
    if(a.texture < b.texture)
      return 1;
    else
      return -1;
  }

  if(a.z != b.z){
    if(a.z < b.z)
      return (a.translucent) ? -1 : 1;
    else if(a.z == b.z)
      return 0;
    else
      return (!a.translucent) ? -1 : 1;
  }

  return 0;
}

for(var i=0; i<list.length; ++i){
  console.dir("translucent: " + list[i].translucent + " texture: " +list[i].texture + " z: " + list[i].z);
}
{% endhighlight %}

{% jsfiddle rVzQd result,js %}

You can view the log result in the developer tool's console.

This is a very naive code, hopefully it will work in the future proper implementation. 

References:

[stackoverflow](http://stackoverflow.com/questions/4424936/opengl-how-to-design-efficient-rendering-system-using-vertex-arrays-with-depth)

[state sorting tutorial](http://stackoverflow.com/questions/4424936/opengl-how-to-design-efficient-rendering-system-using-vertex-arrays-with-depth)