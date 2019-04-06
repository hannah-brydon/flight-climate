'''    
Script to ingest data from Twitter

Author: Vivek Katial
'''

import tweepy
import yaml


'''
Get creds
'''
def read_credentials(file_name):
    with open(file_name, 'r') as stream:
        try:
            credentials = yaml.safe_load(stream)
            print("credentials loaded...")
        except yaml.YAMLError as exc:
            print(exc)
    return credentials


'''
connect to twitter
'''
def connect_to_twitter(creds):
        
    auth = tweepy.OAuthHandler(creds["consumer_key"], creds["consumer_secret"])
    auth.set_access_token(creds["access_token"], creds["access_token_secret"])

    api = tweepy.API(auth)

    return api


'''
main
'''
def main():
    creds = read_credentials(".credentials/twitter.yml")
    api = connect_to_twitter(creds)
