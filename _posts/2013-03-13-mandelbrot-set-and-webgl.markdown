---
layout: post
title: "Mandelbrot set and WebGL"
date: 2013-03-13 22:45
comments: true
categories: 
---
大二的时候学过 Computer Graphics。其中某堂课作业就是要求弄个 Mandelbrot set，当时是用的 Mesa OpenGL，仿佛弄得还多轻松的。结果时隔多年今天看了一下，连复数是咋回事儿都差不多搞忘了，赶紧复习了一下，照着教程 [advanced shader](http://dev.opera.com/articles/view/raw-webgl-101-part-3-advanced-shader/) 做了一个: [Mandelbrot set](http://jsfiddle.net/zUUQp/)

方向键移动，加减号放大缩小。

{% jsfiddle zUUQp result,html %}

需要支持 WebGL 的主流浏览器，Chrome, Firefox, Safari 之类的才能看得到。IE 内核的肯定没戏。

这个图片核心就在这个公式: 

	f(x) = x*x + c 

上边公式里的 ***x*** 跟坐标轴没有关系，就是一个参数。

而 c 才是最重要的，它是一个复数: 

	c = x + yi

这里边的 ***x*** 和 ***y*** 意思实际就是像素的坐标值。把每个像素的坐标值看成复数，带入到 ***f(x)*** 里边就可以判断该像素是不是属于 Mandelbrot set。

最后这个神奇的图像的意思就是：遍历所有像素，如果该像素的 ***f(x)*** 数值趋近于 ∞ 。那么它就不在 Mandelbrot set里边，并且给它上个色（非黑色）。反过来说，黑色的像素点就表示 Mandelbrot set。

如何判断该像素在 ***f(x)*** 下边是否趋近无穷？多循环几次，把前一次的结果带入下一次的 ***f(x)*** 作为参数 ***x***，仿佛只要 ***x^2 + y^2 >= 4*** 都可以直接判断为 ∞ 。嗯，反正大概就是这么一回事儿……
	
看 wikipedia 看得我一愣一愣的，整数学的人就是爱故弄玄虚，啥子 complex plane 嘛！有好“复杂”嘛！说得好高深！结果就相当于普通的 x, y 坐标系（故弄玄虚得叫笛卡儿坐标系 Cartesian coordinate system）。

反正老子记不到！是我越活越蠢还是啥子喃……

