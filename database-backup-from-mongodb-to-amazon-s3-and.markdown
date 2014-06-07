---
layout: post
title: "Database Backup from MongoDB to Amazon S3 and Restoring it Back."
date: 2010-05-02 21:20:23
---

![Database Backup from MongoDB and Restore ][1]
Copyright: [John Boston][2]

I couldn't have asked for better picture for my blog entry. I am going to use [John's words][3] straight from this photo page on flicker to set the ground for today's blog post.

{% blockquote %}
> This server was destroyed in the Choteau fire in NE Oklahoma on 11/27. This is why I stress to my clients the need for off-site backups. That's a telephone on top.
>
> Any small business owners out there should ask themselves "What would I do tomorrow if none of my data was retrievable". The answer in many cases is "I'd go out of business". Backups are cheap insurance, and if you don't store them off-site, you will regret it one day. Even taking yesterday's tape home with you is better than leaving it at the office.
{% endblockquote %}

Offsite back is much needed (checkout real example the [ma.gnolia disaster][4]) and everyone writes their own mechanism to take offsite backup. Last week, I spent sometime developing a simple mechanism of taking snapshot of certain section of database. We are using MongoDB at work. Though we have all the real-time replication mechanism in place but we wanted to take offsite backup for some section of user data in another place and we decided to go with [Amazon S3 service][5]. I thought of shareing some of the code snippets here because I think there are lot of foIks who could make use of this and save their time.  So, rest of the blog discusses steps for backing up data from MongoDB, storing it to Amazon S3 store and then restoring back from Amazon S3.

The first step is to take backup of database. The documentation on MongoDB website describes various strategies for taking backup, the one that I followed was:

1.  Fsync, Write Lock
2.  Backup
3.  Unlock

Now this strategy would work well for the scenario where the datasize you are backing up is small because the first operation is going to prevent any writes on the DB and will pretty much halt your application.

## Fsync, WriteLock
  Fsync, Writelock operation ensures flushing all pending writes to datafiles and then locks the DB for any further writes. It is good point to take snapshot of database because it dataset is in consistent state with no pending writes.I created a JS file fsync_lock.js.

  {% gist 387231 %}

  Here is the command to do the first operation:
      /opt/mongodb/bin/mongo admin fsync_lock.js

## Backup:
  Next step is to actual taking backup of your database. There are different methods of taking backup mentioned on [mongodb website][6] and I have used export method in this example. Lets assume the database you want backup has name "my_db".

The following command will take backup your db.
      /opt/mongodb/bin/mongodump -d my_db -o dump

The above command will general backup files in folder dump/my_db

## Unlock database:
  Since we are done with the snapshotting exercise, unlock the database. I have created a small JS unlock.js for unlocking operation. The script contains following one JS line.

>   db.$cmd.sys.unlock.findOne();
>   Following command will unlock the database:
>   /opt/mongodb/bin/mongo admin unlock.js

### Saving the backup archieve in S3:
I will share a python script that I wrote for four common operations that you will be doing with the Amazon S3 store:

* Saving a backup archieve in the S3 bucket
* List operation to check all archieves in S3 buckets
* Retrieving a backup archive from S3
* Deleting all backup archieves

There is a python library called[ boto][7] which is widely used for accessing Amazon Web Services programmatically. There is very good [tutorial][8] to get started with boto. You need to create the bucket for saving the data in the S3 store first.

Here is aws_s3.py file code which does the above three operations I just described.

{% gist 387235 %}

Here is the complete shell script which takes backup for you:

{% gist 387237  %}

### When shit happens:

Rest part of the blog will focus on restoring your database from the backup saved in S3. For restoring backup, following are the steps involved:

1. Getting the backup archive from S3: you can use list operation from aws_s3.py to list the backup archieves that you have saved in S3. To retrieve a backup archieve from S3, use following command

python aws_s3.py get <archive_name>

2. Restoring your DB: Restoring database from is a simple step. You need to stop your application from accessing the database.

Assuming unarhieving backup archive will create a directory dump which contains my_db folder with all the files.

/opt/mongodb/bin/mongorestore -d my_db dump/my_db

Here is a complete shell script to do the complete restore operation:

{% gist 387240 %}

This is pretty much it. Let me know your comments or reply me at [@_sunil_][9] incase you face any trouble you face using these scripts.

[1]: http://farm1.static.flickr.com/35/68017710_123de4638c.jpg
[2]: http://flickr.com/photos/roadhunter/68017710/sizes/m/ "Flickr"
[3]: http://www.flickr.com/photos/roadhunter/68017710/in/dateposted/
[4]: http://www.wired.com/epicenter/2009/01/magnolia-suffer/
[5]: http://aws.amazon.com/s3/
[6]: http://www.mongodb.org/display/DOCS/Backups
[7]: http://code.google.com/p/boto/
[8]: http://boto.s3.amazonaws.com/index.html
[9]: http://www.twitter.com/_sunil_
