"""
CSCI-620 : Introduction to Big Data : Project Phase 2
Authors:
Archit Joshi (aj6082)
Athina Stewart (as1896)
Parijat Kawale (pk7145)
Chengzi Cao (cc3773)
File Description : Perform itemset mining to get most common genres combinations to be made in Relational model.
"""

import time
import psycopg2
from prettytable import PrettyTable as p
from sys import argv


def connectDB(arg):
    try:
        return psycopg2.connect(
            database=arg[1],
            host=arg[2],
            user=arg[3],
            password=arg[4],
            port=arg[5]
        )
    except:
        return "Connection Failed"


def apriori(dbconnect):
    minimum_support = 100
    cursor = dbconnect.cursor()

    # Create L1 manually as initialization
    level = 1
    query = f'create table public.l{level} as select genre_id,count(*) ' \
            'from public.has_genre hg ' \
            'group by genre_id ' \
            'order by genre_id '
    cursor.execute(query)
    dbconnect.commit()
    query = f'select count(*) from l{level}'
    cursor.execute(query)
    count = int(cursor.fetchone()[0])
    print(f"LEVEL {level} COUNT : {count}")
    if count is None:
        return 'L0'   # No item set above given minimum_support

    # Create L2 manually as initialization
    level += 1
    query = f'create table public.l{level} as\n' \
            'select distinct g1.genre_id as genre_id1, g2.genre_id as genre_id2, count(*) as anime_count\n' \
            'from public.L1 g1 inner join public.has_genre hg1 on g1.genre_id = hg1.genre_id\n' \
            'inner join public.has_genre hg2 on hg1.anime_id = hg2.anime_id\n' \
            'and hg2.genre_id > hg1.genre_id inner join L1 g2 on hg2.genre_id = g2.genre_id\n' \
            'group by g1.genre_id, g2.genre_id\n' \
            f'having count(*) >= {minimum_support}\n' \
            'order by g1.genre_id;'
    cursor.execute(query)
    dbconnect.commit()

    query = f'select count(*) from l{level}'
    cursor.execute(query)
    count = int(cursor.fetchone()[0])
    print(f'LEVEL {level} COUNT : {count}')
    if count == 0:
        return f'l{level - 1}'

    # Loop to create lattices until a lattice with 0 item sets is formed
    while True:
        level += 1
        create = f'create table l{level} as\n'

        genre_id = 'g1.genre_id1 as genre_id1,'
        for i in range(2, level + 1):
            genre_id += f' g{i}.genre_id{i - 1} as genre_id{i},'

        select = f'select {genre_id} count(*) as anime_count \nfrom l{level - 1} g1 \n'

        joins1 = ''
        for i in range(2, level + 1):
            joins1 += f'inner join l{level - 1} g{i} on g{i}.genre_id1 = g{i - 1}.genre_id2\n'

        joins2 = 'inner join has_genre hg1 on g1.genre_id1 = hg1.genre_id\n'
        for i in range(2, level + 1):
            joins2 += f'inner join has_genre hg{i} on g{i}.genre_id{i - 1} = hg{i}.genre_id\n'

        andCondition = ''
        for i in range(1, level):
            andCondition += f'and hg{i}.anime_id = hg{i + 1}.anime_id '

        groupBy = '\ngroup by g1.genre_id1'
        for i in range(2, level + 1):
            groupBy += f',g{i}.genre_id{i - 1}'

        having = f'\nhaving count(*) >= {minimum_support}'

        orderBy = f'\norder by {groupBy[10:]};'

        query = create + select + joins1 + joins2 + andCondition + groupBy + having + orderBy
        cursor.execute(query)
        dbconnect.commit()

        currentLevel = f'L{level}'
        prevLevel = f'L{level - 1}'

        query = f'Select count(*) from {currentLevel}'
        cursor.execute(query)
        count = int(cursor.fetchone()[0])
        dbconnect.commit()
        print(f'LEVEL {level} COUNT : {count}')
        if count == 0:
            return prevLevel    # Return the last valid lattice level


def getResult(dbconnect, lastLevel):
    level = int(lastLevel[1:])
    cursor = dbconnect.cursor()

    select = 'select '
    temp = ''
    for i in range(1, level + 1):
        temp += f'm{i}.genre as genre_id_{i}, '
    select += temp + 'anime_count\n'

    table = f'from l{level}\n'

    joins = ''
    for i in range(1, level + 1):
        joins += f'inner join genre m{i} on m{i}.genre_id = l{level}.genre_id{i}\n'

    query = select + table + joins

    cursor.execute(query)
    headers = [i[0] for i in cursor.description]
    data = cursor.fetchall()

    # Print data in table format using prettyTable library
    x = p()
    x.field_names = headers
    for item in data:
        x.add_row(item)
    print(f"Lattice L{level} result joined with Genres table")
    print(x)


def main():
    start = time.time()
    dbconnect = connectDB(argv)
    lastLattice = apriori(dbconnect)
    if lastLattice == 'L0':
        return "No item set above given minimum_support"
    print(f"Last valid lattice : {lastLattice}")
    print()
    getResult(dbconnect, lastLattice)
    end = time.time()
    print()
    print(f'Total execution time : {end - start}')

if __name__ == "__main__":
    main()
