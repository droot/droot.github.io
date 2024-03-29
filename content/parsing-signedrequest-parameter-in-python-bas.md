---
layout: post
title: "Parsing signed_request parameter in Python based Facebook Canvas application"
date: 2010-07-28 21:20:23
hidePostInHomePage: true
---

Recently Facebook announced a new way to passing user information who is viewing your Facebook canvas application using "signed_request" parameter which is implemented on top of new signature scheme based on [OAuth2.0 proposal][1]. [Facebook documentation][2] describes "signed_request" as

> The `signed_request` parameter is a simple way to make sure that the data you're receiving is the actual data sent by Facebook. It is signed using your application secret which is only known by you and Facebook. If someone were to make a change to the data, the signature would no longer validate as they wouldn't know your application secret to also update the signature.

Facebook's python-sdk does not support parsing request parameter. Today at work, I had to write this piece of code snippet for parsing "signed_request", so thought of sharing it here.

```python
import base64
import hashlib
import hmac
import simplejson as json

def base64_url_decode(inp):
    padding_factor = (4 - len(inp) % 4) % 4
    inp += "="*padding_factor 
    return base64.b64decode(unicode(inp).translate(dict(zip(map(ord, u'-_'), u'+/'))))

def parse_signed_request(signed_request, secret):

    l = signed_request.split('.', 2)
    encoded_sig = l[0]
    payload = l[1]

    sig = base64_url_decode(encoded_sig)
    data = json.loads(base64_url_decode(payload))

    if data.get('algorithm').upper() != 'HMAC-SHA256':
        log.error('Unknown algorithm')
        return None
    else:
        expected_sig = hmac.new(secret, msg=payload, digestmod=hashlib.sha256).digest()

    if sig != expected_sig:
        return None
    else:
        log.debug('valid signed request received..')
        return data
```

I know there is some cryptic code in base64_url_decode because translate, maketrans does not work that well with unicode strings. Anyways, if you have any questions, just drop a line in the commments below or message me [@_sunil_][3].

[1]: http://docs.google.com/document/pub?id=1kv6Oz_HRnWa0DaJx_SQ5Qlk_yqs_7zNAm75-FmKwNo4 "OAuth2.0 proposal"
[2]: http://developers.facebook.com/docs/authentication/canvas
[3]: http://www.twitter.com/_sunil_
