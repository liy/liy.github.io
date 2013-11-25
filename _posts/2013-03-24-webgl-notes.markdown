---
layout: post
title: "webgl notes"
date: 2013-03-24 10:25
comments: true
categories: 
---
### [Framebuffer](http://games.greggman.com/game/webgl-image-processing-continued/)
Framebuffer is not a buffer. It is a collection of states, which has very low memory footprint. Imagine it is a C struct with lots of pointer to a real buffer, etc.


### [Renderbuffer](http://stackoverflow.com/questions/2213030/whats-the-concept-of-and-differences-between-framebuffer-and-renderbuffer-in)

Renderbuffer object is newly introduced for offscreen rendering. It allows to render a scene directly to a renderbuffer object, instead of rendering to a texture object. Renderbuffer is simply a data storage object containing a single image of a renderable internal format. It is used to store OpenGL logical buffers that do not have corresponding texture format, such as stencil or depth buffer.