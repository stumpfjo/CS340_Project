# Citation for the following file:
# Date: 2021-02-23
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://github.com/gkochera/CS340-demo-flask-app

# use pymysql per piazza post https://piazza.com/class/kirqdpeo2581v2?cid=251
import pymysql
import os
from dotenv import load_dotenv, find_dotenv
# Adaptation from
# https://stackoverflow.com/questions/47711689/error-while-using-pymysql-in-flask
# to use fix issue with mysql connection timing out on flip
from dbutils.persistent_db import PersistentDB

# Load our environment variables from the .env file in the root of our project.
load_dotenv(find_dotenv())

# Set the variables in our application with those environment variables
host = os.environ.get("340DBHOST")
user = os.environ.get("340DBUSER")
passwd = os.environ.get("340DBPW")
db = os.environ.get("340DB")

# Citation for the following function:
# Date: 2021-02-23
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://stackoverflow.com/questions/47711689/error-while-using-pymysql-in-flask
def connect_to_database(this_host = host, this_user = user, this_passwd = passwd, this_db = db):
    '''
    connects to a database and returns a database objects
    '''
    '''
    db_connection = pymysql.connect(
        host = this_host,
        user = this_user,
        passwd = this_passwd,
        db = this_db)
    return db_connection
    '''
    return PersistentDB(
        creator = pymysql, # the rest keyword arguments belong to pymysql
        host = this_host, user = this_user, password = this_passwd, database = this_db, charset = 'utf8mb4' , cursorclass = pymysql.cursors.DictCursor)


def execute_query(db_connection = None, query = None, query_params = ()):
    '''
    executes a given SQL query on the given db connection and returns a Cursor object
    db_connection: a MySQLdb connection object created by connect_to_database()
    query: string containing SQL query
    returns: A Cursor object as specified at https://www.python.org/dev/peps/pep-0249/#cursor-objects.
    You need to run .fetchall() or .fetchone() on that object to actually acccess the results.
    '''

    if db_connection is None:
        print("No connection to the database found! Have you called connect_to_database() first?")
        return None

    if query is None or len(query.strip()) == 0:
        print("query is empty! Please pass a SQL query in query")
        return None

    print("Executing %s with %s" % (query, query_params));
    # Create a cursor to execute query. Why? Because apparently they optimize execution by retaining a reference according to PEP0249
    cursor = db_connection.cursor(pymysql.cursors.DictCursor)

    '''
    params = tuple()
    #create a tuple of paramters to send with the query
    for q in query_params:
        params = params + (q)
    '''
    #TODO: Sanitize the query before executing it!!!
    cursor.execute(query, query_params)
    # this will actually commit any changes to the database. without this no
    # changes will be committed!
    db_connection.commit();
    return cursor

if __name__ == '__main__':
    print("Executing a sample query on the database using the credentials from db_credentials.py")
    db = connect_to_database()
    query = "SELECT * from bsg_people;"
    results = execute_query(db, query);
    print("Printing results of %s" % query)

    for r in results.fetchall():
        print(r)
