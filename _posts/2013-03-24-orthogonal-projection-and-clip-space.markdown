---
layout: post
title: "orthogonal projection and clip space"
date: 2013-03-24 12:05
comments: true
categories: 
---
In OpenGL clip space coordinate system is between:```[-1, 1]```. 

{% highlight glsl %}
attribute vec2 a_position;
uniform vec2 u_resolution;

void main(){
	// [0, 1] coordinate system
	vec2 clipSpace = a_position/a_resolution;
	// [0, 2] coordinate system
	clipSpace *= 2.0;
	// [-1, 1] finally clip space coordinate system
	clipSpace -= 1.0;
	gl_Position = vec4(clipSpace, 0, 1);
}
{% endhighlight %}

However, the origin of the clip space will be end up at bottom left corner. We can flip the ```y axis``` to achieve the top left origin, like Adobe Flash and other design tool.

{% highlight glsl %}
attribute vec2 a_position;
uniform vec2 u_resolution;

void main(){
	// [0, 1] coordinate system
	vec2 clipSpace = a_position/a_resolution;
	// [0, 2] coordinate system
	clipSpace *= 2.0;
	// [-1, 1] finally clip space coordinate system
	clipSpace -= 1.0;
	// flip y axis
	clipSpace *= vec2(1, -1);
	gl_Position = vec4(clipSpace, 0, 1);
}
{% endhighlight %}

The OpenGL use column-major matrix. Using a 4x4 matrix represent the projection:

$$
\begin{pmatrix}
 2/width & 0 & 0 & -1 \\
 0 & -2/height & 0 & 1 \\
 0 & 0 & 2/depth & -1 \\
 0 & 0 & 0 & 1 
\end{pmatrix}
$$

Use the above matrix in the GLSL:

{% codeblock lang:glsl %}
attribute vec3 a_position;

// orthogonal projection matrix
uniform mat4 u_pMatrix;

void main(){
  gl_Position = u_pMatrix * vec4(a_position, 1);
}
{% endcodeblock %}

{% jsfiddle nZnK4 result,html %}