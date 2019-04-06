'''    
Script to ingest data from Twitter

Author: Antony
'''

import os
import sys

import json
import time

from csv import DictWriter
from datetime import datetime

import tweepy

from textblob import TextBlob
from ruamel.yaml import YAML

def log(item):
    print(datetime.now().strftime("[%Y-%m-%d][%H:%M:%S] :: ") + str(item))


def log_count(c, call=lambda x: None, base=10):
    from math import log, floor
    if c == 0:
        return call(c)
    if c < 0:
        return log_count(-c)
    else:
        p = int(floor(log(c, 10)))
        mod = int(10**p)
        if c % mod == 0:
            return call(c)


def mk_log_counter(s: str):

    def p(x):
        print(f"{x} {s}")

    class LogCounter(object):
        def __init__(self):
            self.count = 0

        def __call__(self, final=False):
            self.count += 1
            if not final:
                return log_count(self.count, call=p)
            else:
                return p(self.count)

    return LogCounter()


def print_json(dd):
    print(fmt_json(dd))


def fmt_json(dd):
    return json.dumps(dd, indent=4, default=str)


def read_credentials(file_name):
    log("reading creds")
    with open(file_name, 'r') as f:
        return YAML().load(f)


def connect_to_twitter(creds):
    log("setting up api access")
    auth = tweepy.OAuthHandler(creds["consumer_key"], creds["consumer_secret"])
    auth.set_access_token(creds["access_token"], creds["access_token_secret"])
    return tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)


def API():
    log("connecting to api")
    creds = read_credentials(".credentials/twitter.yml")
    return connect_to_twitter(creds)


def verbs(api, query, outfile):
    log(f"getting verbs for query {query}")
    lc = mk_log_counter("tweets")
    with open(outfile, 'w') as f:
        for item in tweepy.Cursor(api.search, query).items():
            dd = proc(item._json)
            dd['query'] = query
            f.write(json.dumps(dd) + "\n")
            lc()
    lc(True)


def map_queries(api, queries):
    log(f"mapping queries")
    for query in queries:
        verbs(api, query, f"data/twitter/{query}.jsonld")


QUERIES = [
    # 'sustainable flight',
    # 'sustainable airlines',
    # 'aircraft emissions',
    # 'airline emissions',
    # 'airplane emissions',
    # 'aeroplane emissions',
    # 'air new zealand',
    # 'quantas',
    'jetstar',
    'singapore airlines',
    'virgin airlines',
    'boeing',
    'airbus',
    'air emirates',
    'emirates emissions',
    'air new zealand emissions',
    'quantas emissions',
    'jetstar emissions'
]


def main():
    log("main enter")
    map_queries(API(), QUERIES)


def projld(filename):
    log(f"transforming raw ldjson in {filename}")
    with open(filename, 'r') as f:
        for line in f:
            item = json.loads(line)
            ex = extract(item)
            en = transform(item)
            yield { **ex, **en }


def extract(x):
    result = {}

    fields = [
        'created_at',
        'id_str',
        'text',
        'source',
        'retweet_count',
        'favorite_count',
        'geo',
        'coordinates',
        'place',
        'contributors',
        'source',
        'truncated'
    ]

    for field in fields:
        result[field] = x[field]

    user_fields = [
        'location',
        'followers_count',
        'friends_count'
    ]

    for field in user_fields:
        result[f'user.{field}'] = x['user'][field]

    return result


def transform(x):
    tb = TextBlob(x['text'])
    def label():
        if tb.sentiment.polarity > 0.3:
            return "Positive"
        elif tb.sentiment.polarity < -0.3:
            return "Negative"
        else:
            return "Neutral"

    parsed_date = datetime.strptime(x['created_at'], "%a %b %d %H:%M:%S %z %Y")

    enrichments = {
        'sentiment_label': label,
        'sentiment_score': lambda: tb.sentiment.polarity,
        'sentiment_subjt': lambda: tb.sentiment.subjectivity,
        'created_date': lambda: parsed_date.strftime("%Y-%m-%d"),
        'created_time': lambda: parsed_date.strftime("%H:%M:%S"),
        'created_dt': lambda: parsed_date.strftime("%Y-%m-%dT%H:%M:%S%z")
    }

    enrich = {}
    for key in enrichments:
        enrich[key] = enrichments[key]()

    return enrich


def ldjson2csv(infile, outfile):
    stream = projld(infile)
    first = next(stream)
    writer = DictWriter(open(outfile, 'w'), fieldnames=first.keys())
    writer.writeheader()
    writer.writerow(first)

    lc = mk_log_counter("to csv")
    for item in projld(infile):
        writer.writerow(item)
        lc()
    lc(True)


def cleanldjson():
    log("cleaning ldjson")
    for (d, dl, fs) in os.walk('data/twitter/'):
        for f in fs:
            if os.path.basename(f).split('.')[-1] != 'jsonld':
                continue

            log(f"cleaning file {f}")
            infile = d + f
            outfile = d + "".join(os.path.basename(f).split('.')[0:-1]) + '.csv'
            ldjson2csv(infile, outfile)

