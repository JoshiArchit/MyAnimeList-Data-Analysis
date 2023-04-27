"""
Filename : stats.py
Author : Archit Joshi
Description : CSCI620 - Project Phase 3. Data integration / statistics
Language : python3
"""

import psycopg2
import matplotlib.pyplot as plt


def connectDB():
    """
        Function to initiate DB connection using psycopg2 library.

        :return: dbconnect object
        """
    try:
        return psycopg2.connect(
            database='anime2',
            host='localhost',
            user='postgres',
            password='Archit@2904',
            port='5432'
        )
    except:
        return "Connection Failed"


def makePieChart(db):
    """

    :param db:
    :return:
    """
    print("Pie Chart")
    cursor = db.cursor()

    query = "select distinct count(anime.anime_id), genre " \
            "from anime " \
            "inner join has_genre hg on anime.anime_id = hg.anime_id " \
            "inner join genre g on hg.genre_id = g.genre_id " \
            "inner join watches w on anime.anime_id = w.anime_id " \
            "where " \
            "genre not like '%Hentai%' and " \
            "genre not like '%Ecchi%' and " \
            "genre not like '%Yaoi%' and " \
            "genre not like '%Yuri%' group by genre " \
            "order by count(anime.anime_id) " \
            "DESC"

    cursor.execute(query)
    result = cursor.fetchall()

    temp_labels = list(x[1] for x in result)
    temp_values = list(float(x[0]) for x in result)

    labels = []
    values = []
    for i in range(20):
        labels.append(temp_labels[i])
        values.append(temp_values[i])

    other_values = 0
    for i in range(20, len(temp_values)):
        other_values += temp_values[i]

    labels.append('Others')
    values.append(other_values)

    # Group last 20 into 'Others' category
    print(labels)
    print(values)

    fig, ax = plt.subplots()
    ax.pie(values, labels=labels, autopct='%1.1f%%',
           textprops={'fontsize': 10}, rotatelabels=True, pctdistance=1.15,
           labeldistance=1.25)
    fig = plt.gcf()
    fig.set_size_inches(8, 8)
    plt.show()


def makeTimeSeriesPlot(db):
    print("Time Series.")

    cursor = db.cursor()
    query = "select " \
            "(string_to_array(premiered, ' '))[2] as year, " \
            "count((string_to_array(premiered, ' '))[2]) as count " \
            "from anime " \
            "where (string_to_array(premiered, ' '))[2] is not null " \
            "group by (string_to_array(premiered, ' '))[2] " \
            "order by (string_to_array(premiered, ' '))[2]"

    cursor.execute(query)

    result = cursor.fetchall()

    year = [x[0] for x in result]
    count = [int(x[1]) for x in result]
    year.pop()
    count.pop()
    print(year)
    print(count)

    plt.rcParams['figure.figsize'] = [8, 6]
    plt.plot(year, count)

    plt.title("Number of animes premiered by year")
    plt.xlabel('Year')

    plt.ylabel('Number of animes premiered')
    plt.tick_params(axis='x', which='major', labelsize=8)
    plt.xticks(rotation=90)

    plt.show()


def makeBarGraph(db):
    cursor = db.cursor()
    query = "select studio.studio , avg(a.score) as average_rating " \
            "from studio " \
            "inner join created_by cb on studio.studio_id = cb.studio_id " \
            "inner join anime a on cb.anime_id = a.anime_id " \
            "group by studio.studio order by average_rating DESC limit 20"

    cursor.execute(query)

    result = cursor.fetchall()
    xvalues = [x[0] for x in result]
    yvalues = [x[1] for x in result]

    plt.rcParams["figure.figsize"] = (6, 6)
    plt.bar(xvalues, yvalues)
    plt.xlabel("Anime Production Studios")
    plt.ylabel("Average Rating across all anime produced")
    plt.title("Average Rating across all anime produced by top 20 studios")
    plt.xticks(rotation=90)
    plt.show()


def main():
    """

    :return: None
    """
    dbConnect = connectDB()
    # makePieChart(dbConnect)
    # makeTimeSeriesPlot(dbConnect)
    makeBarGraph(dbConnect)


if __name__ == "__main__":
    main()
