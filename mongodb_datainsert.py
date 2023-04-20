"""
CSCI-620 : Introduction to Big Data : Project Phase 2
Authors:
Archit Joshi (aj6082)
Athina Stewart (as1896)
Parijat Kawale (pk7145)
Chengzi Cao (cc3773)

File Description : Clean the exported data from postgres and import into mongodb
"""

from pymongo import MongoClient
import json

def connect_to_db(list_of_animes, list_of_users):
    client = MongoClient()
    db = client["myanimelist"]
    # collection = db["users"]
    # collection.insert_many(list_of_users)
    collection1 = db["animes"]
    collection1.insert_many(list_of_animes)
    client.close()


def read_users_collection():
    """
    Read the json generated through users.json
    :return:
    """
    with open("E:\\users.json", encoding = "utf8") as users_json:
        list_of_users = []
        for i in users_json:
            print(i)
            i = i
            i = json.loads(i)
            cleaned_row = {}
            for key, value in i.items():
                if value is not None:
                    if type(value) == str:
                        cleaned_row[key] = value
                    else:
                        cleaned_row[key] = value
            list_of_users.append(cleaned_row)
    return list_of_users


def read_animes_collection():
    """
    Read the json generated through users.json
    :return:
    """
    with open("E:\\animes.json", encoding= 'utf8') as animes_json:
        list_of_animes = []
        for i in animes_json:
            print(i)
            i = json.loads(i)
            cleaned_row = {}
            for key, value in i.items():
                if value is not None:
                    cleaned_row[key] = value
            list_of_animes.append(cleaned_row)
    return list_of_animes


def main():
    list_of_users = read_users_collection()
    list_of_animes = read_animes_collection()
    connect_to_db(list_of_animes, list_of_users)


if __name__ == '__main__':
    main()
