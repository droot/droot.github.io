---
layout: post
title: "Database Backup from MongoDB to Amazon S3 and Restoring it Back."
date: 2010-05-02 21:20:23
hidePostInHomePage: true
---

![Database Backup from MongoDB and Restore ][1]
Copyright: [John Boston][2]

I couldn't have asked for better picture for my blog entry. I am going to use [John's words][3] straight from this photo page on flicker to set the ground for today's blog post.

> This server was destroyed in the Choteau fire in NE Oklahoma on 11/27. This is why I stress to my clients the need for off-site backups. That's a telephone on top.
>
> Any small business owners out there should ask themselves "What would I do tomorrow if none of my data was retrievable". The answer in many cases is "I'd go out of business". Backups are cheap insurance, and if you don't store them off-site, you will regret it one day. Even taking yesterday's tape home with you is better than leaving it at the office.

Offsite back is much needed (checkout real example the [ma.gnolia disaster][4]) and everyone writes their own mechanism to take offsite backup. Last week, I spent sometime developing a simple mechanism of taking snapshot of certain section of database. We are using MongoDB at work. Though we have all the real-time replication mechanism in place but we wanted to take offsite backup for some section of user data in another place and we decided to go with [Amazon S3 service][5]. I thought of shareing some of the code snippets here because I think there are lot of foIks who could make use of this and save their time.  So, rest of the blog discusses steps for backing up data from MongoDB, storing it to Amazon S3 store and then restoring back from Amazon S3.

The first step is to take backup of database. The documentation on MongoDB website describes various strategies for taking backup, the one that I followed was:

1.  Fsync, Write Lock
2.  Backup
3.  Unlock

Now this strategy would work well for the scenario where the datasize you are backing up is small because the first operation is going to prevent any writes on the DB and will pretty much halt your application.

## Fsync, WriteLock
  Fsync, Writelock operation ensures flushing all pending writes to datafiles and then locks the DB for any further writes. It is good point to take snapshot of database because it dataset is in consistent state with no pending writes.I created a JS file fsync_lock.js.

  ```js
  function freeze_db() {
        rc = db.runCommand({fsync: 1, lock: 1});
        if (rc.ok == 1){
            return 1;
        } else {
            return 0;
        }
    }
  freeze_db();
  ```

  Here is the command to do the first operation:
  ```bash
  $ /opt/mongodb/bin/mongo admin fsync_lock.js
  ```

## Backup:
  Next step is to actual taking backup of your database. There are different methods of taking backup mentioned on [mongodb website][6] and I have used export method in this example. Lets assume the database you want backup has name "my_db".

The following command will take backup your db.
```bash
$ /opt/mongodb/bin/mongodump -d my_db -o dump
```

The above command will general backup files in folder `dump/my_db`.

## Unlock database:
  Since we are done with the snapshotting exercise, unlock the database. I have created a small JS unlock.js for unlocking operation. The script contains following one JS line.

```js
  db.$cmd.sys.unlock.findOne();
  // Following command will unlock the database:
  /opt/mongodb/bin/mongo admin unlock.js
```

### Saving the backup archieve in S3:
I will share a python script that I wrote for four common operations that you will be doing with the Amazon S3 store:

* Saving a backup archieve in the S3 bucket
* List operation to check all archieves in S3 buckets
* Retrieving a backup archive from S3
* Deleting all backup archieves

There is a python library called[ boto][7] which is widely used for accessing Amazon Web Services programmatically. There is very good [tutorial][8] to get started with boto. You need to create the bucket for saving the data in the S3 store first.

Here is aws_s3.py file code which does the above three operations I just described.

```bash
ACCESS_KEY='YOUR AMAZON API KEY'
SECRET='YOUR AMAZON SECRET'
BUCKET_NAME='database_backup_bucket' #note that you need to create this bucket first

from boto.s3.connection import S3Connection
from boto.s3.key import Key

def save_file_in_s3(filename):
    conn = S3Connection(ACCESS_KEY, SECRET)
    bucket = conn.get_bucket(BUCKET_NAME)
    k = Key(bucket)
    k.key = filename
    k.set_contents_from_filename(filename)

def get_file_from_s3(filename):
    conn = S3Connection(ACCESS_KEY, SECRET)
    bucket = conn.get_bucket(BUCKET_NAME)
    k = Key(bucket)
    k.key = filename
    k.get_contents_to_filename(filename)

def list_backup_in_s3():
    conn = S3Connection(ACCESS_KEY, SECRET)
    bucket = conn.get_bucket(BUCKET_NAME)
    for i, key in enumerate(bucket.get_all_keys()):
        print "[%s] %s" % (i, key.name)

def delete_all_backups():
    #FIXME: validate filename exists
    conn = S3Connection(ACCESS_KEY, SECRET)
    bucket = conn.get_bucket(BUCKET_NAME)
    for i, key in enumerate(bucket.get_all_keys()):
        print "deleting %s" % (key.name)
        key.delete()

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print 'Usage: %s <get/set/list/delete> <backup_filename>' % (sys.argv[0])
    else:
        if sys.argv[1] == 'set':
            save_file_in_s3(sys.argv[2])
        elif sys.argv[1] == 'get':
            get_file_from_s3(sys.argv[2])
        elif sys.argv[1] == 'list':
            list_backup_in_s3()
        elif sys.argv[1] == 'delete':
            delete_all_backups()
        else:
            print 'Usage: %s <get/set/list/delete> <backup_filename>' % (sys.argv[0])
```

Here is the complete shell script which takes backup for you:

```bash
#!/bin/sh

MONGODB_SHELL='/opt/mongodb/bin/mongo'

DUMP_UTILITY='/opt/mongodb/bin/mongodump'
DB_NAME='my_db'

date_now=`date +%Y_%m_%d_%H_%M_%S`
dir_name='db_backup_'${date_now}
file_name='db_backup_'${date_now}'.bz2'

log() {
    echo $1
}

do_cleanup(){
    rm -rf db_backup_2010* 
    log 'cleaning up....'
}

do_backup(){
    log 'snapshotting the db and creating archive' && \
    ${MONGODB_SHELL} admin fsync_lock.js && \
    ${DUMP_UTILITY} -d ${DB_NAME} -o ${dir_name} && tar -jcf $file_name ${dir_name}
    ${MONGODB_SHELL} admin unlock.js && \
    log 'data backd up and created snapshot'
}

save_in_s3(){
    log 'saving the backup archive in amazon S3' && \
    python aws_s3.py set ${file_name} && \
    log 'data backup saved in amazon s3'
}

do_backup && save_in_s3 && do_cleanup
```

### When shit happens:

Rest part of the blog will focus on restoring your database from the backup saved in S3. For restoring backup, following are the steps involved:

1. Getting the backup archive from S3: you can use list operation from aws_s3.py to list the backup archieves that you have saved in S3. To retrieve a backup archieve from S3, use following command

```bash
python aws_s3.py get <archive_name>
```

2. Restoring your DB: Restoring database from is a simple step. You need to stop your application from accessing the database.

Assuming unarhieving backup archive will create a directory dump which contains my_db folder with all the files.

```bash
/opt/mongodb/bin/mongorestore -d my_db dump/my_db
```

Here is a complete shell script to do the complete restore operation:

```bash
#!/bin/bash

RESTORE_UTILITY='/opt/mongodb/bin/mongorestore'
DB_NAME='my_db'

log() {
    echo $1
}


do_restore(){
    local fname=$1
    tar -jxf $1 && \
    ${RESTORE_UTILITY} -d ${DB_NAME} ${fname//.bz2}/${DB_NAME}
}

get_file_from_s3(){
    python aws_s3.py get $1
}

do_cleanup(){
    rm -rf db_backup_2010* 
    log 'cleaning up....'
}

if [ $# -lt 1 ]
then
    echo "Usage: $0 <backup_filename>"
    exit 1
fi

filename=$1

get_file_from_s3 ${filename} && do_restore ${filename} && do_cleanup
```

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
