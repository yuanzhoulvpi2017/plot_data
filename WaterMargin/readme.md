![工程结果](https://github.com/yuanzhoulvpi2017/plot_data/blob/master/WaterMargin/%E6%88%AA%E5%B1%8F2020-12-31%20%E4%B8%8B%E5%8D%8812.53.58.png)

文件介绍：

1. WaterMargin.Rproj 文件是Rstudio的工程文件。如果电脑上使用的是Rstudio。可以打开这个文件然后Rstudio会自动进入这个工程目录里面。
2. getheros.R这个代码是用来获得108位英雄的，从百度百科上下载英雄的名字绰号等。这个代码生成的是allheros.csv这个文件
3. calrelation.R这个代码是使用小说水浒传这个文本（也就是文件夹中的shz_good.txt文件），对这个文本和小说人物做关系统计，如果两个人物在同一句话中，那么这个两个人之间就代表有一个关系，依次累加，找到所有人物两两之间的关系。最后汇总结果、生成herosrelation.csv这个文件。
4. plotnetwork.R代码是依靠allheros.csv和herosrelation.csv两个文件，整理一定的数据，然后输出network.html文件，这个文件可以使用chrome谷歌浏览器打开。network.html是一个基础的网络图，各个节点就是一个圆点
5. plotnetwork2.R代码是依靠allheros.csv和herosrelation.csv两个文件，整理一定的数据，然后输出network2.html文件，这个文件可以使用chrome谷歌浏览器打开。network2.html输出的结果是给各个节点加上了各个人物的照片。但是照片并不是特意找的，而是通过百度图片爬虫、然后随机选择的（导致照片风格都不一样）



问题：

1. 有人反应少了晁天王。（问题解决了，原来是108将里面没有晁天王🤪）

2. 这里的人物只有108将。没有别的人物。

3. 人物之间的关系太复杂了。我只是简单的将各个人物之间的关系大概描述了，起码他们在一句话里面，被提到被引用被对话之类的。

4. 因为大概所有的关系有5000多个关系，因此如果完全将5000多个关系画在网络图上，会造成html文件太大，chorme浏览器无法渲染大型的html文件，因此我在代码的部分对edges数据进行了处理：只是随机选择400个关系。

   

代码运行介绍：

1. 第一步： getheros.R应该是第一个运行的，但是可以运行也可以不运行，只要有allheros.csv即可。
2. 第二步：calrelation.R应该是第二运行的，但是可以运行也可以不运行，只要有herosrelation.csv即可。
3. plotnetwork.R 和plotnetwork2.R可以运行也可以不运行，因为分别输出的是network.html和network2.html。这两个图是差不多的，具体细节看文件介绍。
4. 因为网络图关系太大了，应该使用浏览器打开html文件，Rstudio处理中文和大型的html文件会崩溃。


参考链接：

1. [百度百科对水浒传的介绍](https://baike.baidu.com/item/%E6%B0%B4%E6%B5%92%E4%BC%A0/348#3_3)






