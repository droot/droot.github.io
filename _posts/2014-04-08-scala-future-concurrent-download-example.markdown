---
layout: post
title:  "Scala Concurrent Downloader example using Future"
date:   2014-04-08 21:02:50
categories: scala future 
---

I spent this weekend learning more about Scala Futures, and believe me, posts
below are the best written introductory posts about scala futures and promises.

 * [Guide to Scala Future][link1]
 * [Guide to Scala Promise and Future][link2]

In order to learn it for real, I started with an exercise of building a concurrent URL downloader.
Basically idea is, let say, given n urls, how do you download n urls concurrently. 


{% highlight scala %}
import play.api.libs.ws._ //We are using WebService Client from Play's framework
import scala.concurrent._
import java.util.concurrent.Executors
import scala.util.{Success, Failure, Try}

object ConcurrentDownloader {

    def main(args: Array[String]): Unit = {

   //Future need an execution context for running them
      val executorService = Executors.newFixedThreadPool(1)
      implicit val executionContext = ExecutionContext.
                            fromExecutorService(executorService)
      
      //lets define set of URLs to be downloaded
      val urls = List("http://www.google.com",
                      "http://yahoo.com",
                      "http://bing.com",
                      "http://jskdlsycds.com", //invalid url-1
                      "http://amazon.com",
                      "http://hackerne.ws",
                      "http://firstpost.com",
                      "http://rediff.com",
                      "http://wowslskdleodd.com") //invalid url-2

     //Here is how we create the future for each URLs
     //execution context will run start fetching the URLs in the background
      val futures = urls.map { url => WS.url(url).get() }

    //This is a nice little trick to ensure convert a future of T to future of
    Try[T]
      def futureToFutureTry[T](f: Future[T]): Future[Try[T]] =
              f.map(Success(_)).recover { case x => Failure(x) }

      val futureListOfTrys = futures.map(futureToFutureTry(_))

     //This is way to combine all those future into a single future
      val fseq = Future.sequence(futureListOfTrys)

      fseq onComplete {
          case Success(l) => {
              var sCount: Int = 0
              var fCount: Int = 0
              l.foreach {
                      case Success(resp) => {
                          sCount += 1 
                          println("status....=%s".format(resp.status))
                      }
                      case Failure(t) => {
                          fCount += 1
                          println(s"failure $t")
                      }
              }
              println(s"success=$sCount, failures=$fCount")
          }
          case Failure(ex) => {
              println("failure")
          }
      }
    }
}
{% endhighlight %}

There you go, you have a nice little concurrent URL downloader. I am so glad to
write a concurrent program without involving any threads, locks, shared data
structures, feels so refreshing!

[link1]: http://danielwestheide.com/blog/2013/01/09/the-neophytes-guide-to-scala-part-8-welcome-to-the-future.html
[link2]: http://danielwestheide.com/blog/2013/01/16/the-neophytes-guide-to-scala-part-9-promises-and-futures-in-practice.html
