

from riotwatcher import LolWatcher, ApiError
import pandas as pd

# golbal variables
api_key = "" #API key removed for security purposes
watcher = LolWatcher(api_key)
my_region ='na1'

#Sets up Player name you're searching for. Can be used to search any games from a summonername
me = watcher.summoner.by_name(my_region, 'Solarbacca')
#print(me)

my_ranked_stats = watcher.league.by_summoner(my_region, me['id'])
#print(my_ranked_stats)

#print(me['puuid'])

#selecting the last 100m games of ranked solo queue
my_matches = watcher.match.matchlist_by_puuid('americas',me['puuid'],queue=420,count=100)

print(my_matches)
print(type(my_matches))

#For loop to get match data for every individual match and append a list
matchdata = []
for matches in my_matches:
    
    match_detail = watcher.match.by_id('americas',matches)

    match_info = match_detail["info"]

    participantdata = match_info["participants"]
    
    dafr = pd.DataFrame(participantdata)
    
    matchdata.append(dafr)

appended_data = pd.concat(matchdata)

#Save list as a dataframe and export to csv
df = pd.DataFrame(appended_data)

df.to_csv('SolarBaccaData100.csv')

