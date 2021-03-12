import database.db_connector as db

# Query to SELECT checkouts for a certain borrower_id
def get_checkouts(db_connection, borrower_id):
    query = "SELECT b.borrower_id, t.title_text, i.item_id, i.due_date FROM Titles AS t NATURAL JOIN Items as i RIGHT OUTER JOIN Borrowers as b ON i.borrower_id = b.borrower_id WHERE b.borrower_id = %(b_id)s"
    query_params = {'b_id': borrower_id}
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params=query_params)
    return cursor.fetchall()
    
# Query to SELECT checkouts for a certain borrower_id
def get_one_borrower(db_connection, borrower_id):
    query = "SELECT * FROM Borrowers WHERE borrower_id = %(b_id)s"
    query_params = {'b_id': borrower_id}
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params=query_params)
    return cursor.fetchone()

# Get a list of all borrowers to populate dropdown
def get_all_borrowers(db_connection):
    query = "SELECT * FROM Borrowers"
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params={})
    return cursor.fetchall()

# get a list of items available for checkout
def get_available_items(db_connection):
    query = "SELECT i.item_id, t.title_text, t.call_number, i.cutter_number FROM Items AS i NATURAL JOIN Titles as t WHERE i.borrower_id IS NULL"
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params={})
    return cursor.fetchall()
