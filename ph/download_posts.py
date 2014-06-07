import requests
import json
import sys

reload(sys)
sys.setdefaultencoding("utf8")

url = 'http://fuckyeahmarkdown.com/go/'

def _save_content(resp, out_file):
    with open(out_file, "w") as f:
        f.write("""---
layout: post
title: "%s"
date: 2014-08-07 21:20:23
---

"""%(resp.get('title')))
        f.write(resp.get('markdown'))

def download_markdown(u, out_file):
    r = requests.post(url, data={'u': u, 'md': 1, 'output': 'json'})
    resp = r.json()
    _save_content(resp, out_file)

def process_posts(base_domain, permalinks):
    for permalink in permalinks:
        print "processing %s" % (permalink)
        try:
            download_markdown("%s/%s"%(base_domain, permalink), "%s.markdown"%(permalink))
        except Exception, e:
            print "error in processing post %s %s" % (permalink, e)


if __name__ == "__main__":
    base_domain='http://sunilarora.org'
    permalinks=[
            'learning-scala-my-experience-and-advice',
            'drake-make-for-data',
            'wiggle-effect-a-simple-use-case-of-css3-anima',
            'jquery-deferred-objects-an-example-usecase',
            'pycon-india-presentation-on-redis-and-python',
            'another-redis-use-case-centralized-logging',
            'redis-lua-scripting',
            'coffeescript-with-backbonejs-example',
            'facebook-python-library-documentation',
            '33543961',
            'parsing-signedrequest-parameter-in-python-bas',
            'pankho-ko-hawa-zara-see-lagne-do',
            'why-stackoverflow-hates-ruby-and-loves-c',
            '7-things-one-can-do-to-scale-up-a-web-applica',
            'database-backup-from-mongodb-to-amazon-s3-and',
            'displaying-date-in-user-friendly-format-in-py',
            'serializable-decorator-for-python-class',
            'url-shortener-service-using-redis',
            'page-web-vs-people-web',
            'deserialize-a-binary-search-tree-from-an-inor'
            ]

    process_posts(base_domain, permalinks)