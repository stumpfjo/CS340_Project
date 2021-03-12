import database.db_connector as db

def get_checkouts(db_connection, borrower_id):
    # Query to SELECT checkouts for a certain borrower_id
    query = "SELECT b.borrower_id, t.title_text, i.item_id, i.due_date FROM Titles AS t NATURAL JOIN Items as i RIGHT OUTER JOIN Borrowers as b ON i.borrower_id = b.borrower_id WHERE b.borrower_id = %(b_id)s"
    query_params = {'b_id': borrower_id}
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params=query_params)
    results = cursor.fetchall()
    print(results)
    return results

def get_one_borrower(db_connection, borrower_id):
    query = "SELECT * FROM Borrowers WHERE borrower_id = %(b_id)s"
    query_params = {'b_id': borrower_id}
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params=query_params)
    return cursor.fetchone()

def get_all_borrowers(db_connection):
    # Get a list of all borrowers to populate dropdown
    query = "SELECT * FROM Borrowers"
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params={})
    return cursor.fetchall()

def get_available_items(db_connection):
    # get a list of items available for checkout
    query = "SELECT i.item_id, t.title_text, t.call_number, i.cutter_number FROM Items AS i NATURAL JOIN Titles as t WHERE i.borrower_id IS NULL"
    cursor = db.execute_query(
        db_connection=db_connection,
        query=query, query_params={})
    return cursor.fetchall()
