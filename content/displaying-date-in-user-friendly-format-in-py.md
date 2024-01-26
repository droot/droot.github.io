---
layout: post
title: "Displaying date in user friendly format in Python"
date: 2010-04-25 21:20:23
hidePostInHomePage: true
---

In this post, I am going to share a quick piece of code for a functionality which I think is required in almost every web application these days i.e. displaying date format in more user friendly format. Every application has objects in the system which have time-stamps associated with them i.e. user objects will have creation time or last activity time or a content publishing system will have content publishing time.

Consider twitter for example, just note the time-stamps in the picture below. 40 minutes ago or 1 hour ago is way easier to understand than 26th Jan, 5:30 PM. Infact, if a user is presented with a date format like 26th Jan, 2009 5:23PM, he tries to compute an easier format like whether it means 2 hours ago, a week ago or 2 months in his mind. So if you really care for a good user experience, you would like to display the date in a more user friendly manner.![tw_timeline][1]

So, lets talk about the code which does that for you in Python. We need to have a function which accepts a Python datetime object and returns us a 'user friendly' version of that. We will be using [python-dateutil][2] module [ ][2]which provides some handy date manipulation functions. relativedelta module in the dateutil package does most of the magic for us.

relativedelta(date1, date2) function in dateutil.relativedelta returns a relativedelta objects which captures difference between the two dates. So for ex, if two dates differs by3 years, 2 months, 10 hours, 5 minutes, 30 seconds, the relativedelta objects is going to store these difference values in rdelta.year, rdelta.months, rdelta.hours, rdelta.minutes, rdelta.seconds respectively. I have written code that looks at this difference of current date with the passed date and compute the friently format version for given date. The function displays top unit only by default what that means is, if timestamp is 2 year, 6 months older, then default display will be "2 years" and full version will display two top units i.e. "2 years, 6 months".  If you want friendly format to display top two units of time instead of one unit, then you need to pass 'display_full_version = True'.

Now you can jump on to the code directly. If you have any questions, you can contact me at [@_sunil_][3]

The Code
```python
from datetime import datetime
from dateutil.relativedelta import relativedelta

def get_fancy_time(d, display_full_version = False):
    """Returns a user friendly date format
    d: some datetime instace in the past
    display_second_unit: True/False
    """
    #some helpers lambda's
    plural = lambda x: 's' if x > 1 else ''
    singular = lambda x: x[:-1]
    #convert pluran (years) --> to singular (year)
    display_unit = lambda unit, name: '%s %s%s'%(unit, name, plural(unit)) if unit > 0 else ''

    #time units we are interested in descending order of significance
    tm_units = ['years', 'months', 'days', 'hours', 'minutes', 'seconds']

    rdelta = relativedelta(datetime.utcnow(), d) #capture the date difference
    for idx, tm_unit in enumerate(tm_units):
        first_unit_val = getattr(rdelta, tm_unit)
        if first_unit_val > 0:
            primary_unit = display_unit(first_unit_val, singular(tm_unit))
            if display_full_version and idx < len(tm_units)-1:
                next_unit = tm_units[idx + 1]
                second_unit_val = getattr(rdelta, next_unit)
                if second_unit_val > 0:
                    secondary_unit = display_unit(second_unit_val, singular(next_unit))
                    return primary_unit + ', '  + secondary_unit
            return primary_unit
    return None

if __name__ == "__main__":
    data_sets = [datetime.utcnow() + relativedelta(seconds=-3),
                        datetime.utcnow() + relativedelta(minutes=-2, seconds=-6),
                        datetime.utcnow() + relativedelta(minutes=-65, seconds=-50),
                        datetime.utcnow() + relativedelta(days=-2, minutes=-2),
                        datetime.utcnow() + relativedelta(months=-2, days=-45),
                        datetime.utcnow() + relativedelta(months=-54)]

    for x in data_sets:
        print '%s' % (get_fancy_time(x, display_full_version = True))
```

[1]: http://farm5.static.flickr.com/4066/4550702755_af2fe77e0b_o.jpg
[2]: http://labix.org/python-dateutil "python-dateutil"
[3]: http://www.twitter.com/_sunil_ "Sunil Arora"
