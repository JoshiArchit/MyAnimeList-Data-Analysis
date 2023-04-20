"""
CSCI-620 : Introduction to Big Data : Project Phase 2
Authors:
Archit Joshi (aj6082)
Athina Stewart (as1896)
Parijat Kawale (pk7145)
Chengzi Cao (cc3773)

File Description : Perform itemset mining to get most common genres combinations to be made.
"""

from pymongo import MongoClient


def perform_itemset_mining():
    client = MongoClient()
    db = client["myanimelist"]
    collection = db["animes"]
    results = collection.find({})
    genres = set()
    for res in results:
        list_of_genres = res["genre"].split(',')
        for genre in list_of_genres:
            if genre not in genres:
                genres.add(genre)

    collection1 = db["level1"]
    for genre in genres:
        count = 0
        results = collection.find({"genre": {"$regex": genre, "$options": "i"}})
        for _ in results:
            count += 1
        collection1.insert_one({"genre": genre, "count": count})

    minimum_support = 100
    for i in range(2,6):
        collection3 = db["level" + str(i)]
        list_of_genres = []
        for genre in db["level" + str(i - 1)].find({}):
            list_of_genres.append(genre["genre"])
        for genre_1 in list_of_genres:
            set_of_genres = set()
            for genre_2 in genres:
                if genre_1 != genre_2:
                    c_genre = genre_1 + ',' + genre_2
                    current_genre = genre_1.split(',')
                    for g in current_genre:
                        set_of_genres.add(g)
                    count = 0
                    if genre_2 not in set_of_genres:
                        results = collection.find({"$and": [
                                                        {"genre": {"$regex": genre_1, "$options": "i"}},
                                                        {"genre": {"$regex": genre_2, "$options": "i"}}]})
                        for _ in results:
                            count += 1
                        if count >= minimum_support:
                            collection3.insert_one({"genre": c_genre, "count": count})

    client.close()


def main():
    # performing itemset mining to get meaningful relations
    perform_itemset_mining()


if __name__ == '__main__':
    main()
