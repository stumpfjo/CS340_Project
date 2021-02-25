# Citation for the following app:
# Date: 2020-02-07
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://github.com/gkochera/CS340-demo-flask-app

from flask import Flask, render_template, request, json, jsonify, abort
import database.db_connector as db
import os

# db_connection = db.connect_to_database()

# Configuration

app = Flask(__name__)


# Citation for the following function:
# Date: 2021-02-23
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://stackoverflow.com/questions/47711689/error-while-using-pymysql-in-flask
def get_db():
    # Opens a new database connection per app.
    if not hasattr(app, 'db'):
        app.db = db.connect_to_database()
    return app.db.connection()

# Routes

'''
@app.route('/index.html')
def static_index():
    return render_template("index.html")
'''

@app.route('/')
def index():
    return render_template("main.html")
'''
@app.route('/books')
def books():
    return render_template("books.html")
'''
@app.route('/borrowers/add_borrowers', methods=['GET', 'POST'])
def add_borrowers():
    db_connection = get_db()
    # Default values to pass for a GET.
    fill_params = {
        'fname': "",
        'lname': "",
        'email': "",
        'saddr': "",
        'city': "",
        'state': "OR",
        'zip': "",
    }
    # Used to populate select box in template
    states = {
        "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
        "CA": "California", "CO": "Colorado", "CT": "Connecticut",
        "DE": "Delaware", "DC": "District Of Columbia", "FL": "Florida",
        "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho", "IL": "Illinois",
        "IN": "Indiana", "IA": "Iowa", "KS": "Kansas", "KY": "Kentucky",
        "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
        "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota",
        "MS": "Mississippi", "MO": "Missouri", "MT": "Montana",
        "NE": "Nebraska", "NV": "Nevada", "NH": "New Hampshire",
        "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
        "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio",
        "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania",
        "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota",
        "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VT": "Vermont",
        "VA": "Virginia", "WA": "Washington", "WV": "West Virginia",
        "WI": "Wisconsin", "WY": "Wyoming"
    }
    # Default values
    add_success = "none"
    message_params = None
    status = 200

    # Attempt to process a new Borrower
    if request.method == 'POST':
        query = "INSERT INTO Borrowers (first_name, last_name, email, street_address, city_name, state, zip_code) VALUES (%(fname)s, %(lname)s, %(email)s, %(saddr)s, %(city)s, %(state)s, %(zip)s)"
        query_params = {
            'fname': request.form.get('fname'),
            'lname': request.form.get('lname'),
            'email': request.form.get('emailAddr'),
            'saddr': request.form.get('streetAddr'),
            'city': request.form.get('cityName'),
            'state': request.form.get('stateAbbrev'),
            'zip': request.form.get('zipCode'),
        }
        for key in query_params.keys():
            if query_params[key] == "":
                query_params[key] = None
        # If we succeed, fill out the response accordingly
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            add_success = "added"
            message_params = {
                'fname': request.form.get('fname'),
                'lname': request.form.get('lname'),
                'id': cursor.lastrowid
            }
            status = 201
        except:
            # On a failure, preserve the inputs so the Template can fill them back in.
            status = 400
            add_success = "error"
            fill_params = query_params

    # Will have the coreect format for all scenarios
    return render_template(
        "borrowers/add_borrowers.html",
        success=add_success,
        borrower=fill_params,
        message=message_params,
        states=states
    ), status


@app.route('/borrowers/delete_borrower')
def delete_borrower():
    # step 6 - Delete
    return render_template("borrowers/delete_borrower.html")

@app.route('/borrowers/update_borrowers')
def update_borrowers():
    # step 6 - Update
    return render_template("borrowers/update_borrowers.html")

@app.route('/borrowers/view_borrowers', methods=['GET'])
def view_borrowers():
    db_connection = get_db()
    # Default Query to get all Borrowers
    query = "SELECT * FROM Borrowers"
    query_params = None

    #Modify the query string to do searches
    view_type = request.args.get("view")

    if view_type == "filter":
        if request.args.get("searchBy") == "idNum" and request.args.get('idNum') is not None:
            # SELECT based on borrower_id
            query_params = {'id': request.args.get('idNum')}
            query = query + " WHERE borrower_id = %(id)s"
        elif request.args.get("searchBy") == "lname" and request.args.get('lname') is not None:
            # Default to exact match
            if request.args.get('lNameMatchType') == "exact":
                query_params = {'lname': request.args.get('lname')}
                query = query + " WHERE last_name = %(lname)s"
            else:
                # Use LIKE to do partial matches on last name
                search_string = '%' + request.args.get('lname') + '%'
                query_params = {'lname': search_string}
                query = query + " WHERE last_name LIKE %(lname)s"
    try:
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
            # Grab the results
        results = cursor.fetchall()
    except:
        abort(400)

    return render_template("borrowers/view_borrowers.html", borrowers=results)

@app.route('/borrowers/view_checkouts', methods=['GET'])
def view_checkouts():
    db_connection = get_db()
    results = None
    # Query to SELECT checkouts for a certain borrower_id
    query = "SELECT b.borrower_id, b.first_name, b.last_name, t.title_text, i.item_id, i.due_date FROM Titles AS t NATURAL JOIN Items as i RIGHT OUTER JOIN Borrowers as b ON i.borrower_id = b.borrower_id WHERE b.borrower_id = %(b_id)s"
    query_params = {'b_id': request.args.get('id')}
    status = 200
    try:
        # nonsense borrower_ids should generate an empty result
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
        results = cursor.fetchall()
    except:
        # Should not get here
        abort(400)

    return render_template("borrowers/view_checkouts.html", results=results), status

@app.route('/items/add_checkouts')
def add_checkouts():
    #step 6 - Update
    return render_template("items/add_checkouts.html")

@app.route('/subjects')
def subjects():
    return render_template("subjects.html")

@app.route('/subjects/add_subjects.html', methods=['GET', 'POST'])
def add_subjects():
    db_connection = get_db()
    fill_params = {
        'subject': ""
    }

    add_success = "none"
    message_params = None
    status = 200

    if request.method == 'POST':
        query = "INSERT INTO Subjects (subject_heading) VALUES (%(subject)s)"
        query_params = {
            'subject': request.form.get('subject')
        }

        try: 
            cursor = db.execute_query(
                db_connection=db_connection, 
                query=query, query_params=query_params
            )
            add_success = "added"
            message_params = {
                'subject': request.form.get('subject'), 
                'id': cursor.lastrowid
            }
            status = 201
        except: 
            status = 400
            add_success = "error"
            fill_params = query_params
        
    return render_template(
        "subjects/add_subjects.html", 
        success=add_success, 
        subject=fill_params, 
        message=message_params
    ), status

@app.route('/subjects/view_subjects', methods=["GET"])
def view_subjects():
    return render_template("subjects/view_subjects.html")
'''
@app.route('/titles')
def titles():
    return render_template("titles.html")
'''
@app.route('/titles/add_titles', methods=['GET', 'POST'])
def add_titles():
    # step 5
    db_connection = get_db()
    if request.method == 'POST':
        # Query to INSERT a new instance of Titles
        query = "INSERT INTO Titles (title_text, publication_year, edition, language, call_number) VALUES (%(t_text)s, %(p_year)s, %(ed)s, %(lang)s, %(c_num)s)"
        request_data = request.json
        query_params = {
            't_text': request_data['new_title'],
            'p_year': request_data['new_pub_year'],
            'ed': request_data['new_edition'],
            'lang': request_data['new_language'],
            'c_num': request_data['new_call_num']
        }
        # Replace empty strings with NULL
        for key in query_params.keys():
            if query_params[key] == "":
                query_params[key] = None
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            # Tell the user we succeeded
            results = {
                'new_title_id': cursor.lastrowid,
                'title_added': request_data['new_title']
            }
            return jsonify(results), 201
        except:
            # On a failure, preserve the inputs so the Template can fill them back in.
            return jsonify(request_data), 400
    else:
        # When we reach this page via get, send the form
        return render_template("titles/add_titles.html"), 200

@app.route('/titles/search_titles', methods=['GET'])
def search_titles():
    # step 5
    db_connection = get_db()
    if request.args.get('search') != 'Search':
        return render_template("titles/search_titles.html", titles=None)
    else:
        query = "SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id"

        # Select the correct search type for WHERE clause
        search_string = request.args.get('title_text')
        if request.args.get('t_match_type') == 'partial':
            search_string = '%' + search_string + '%'
            query = query + " WHERE title_text LIKE %(t_text)s"
        else:
            query = query + " WHERE title_text = %(t_text)s"
        query_params = {'t_text': search_string}

        # Add additional limits if required
        if request.args.get('t_collection_type') == 'in_collection':
            query = query + " AND IFNULL(co.checked_out,0) + IFNULL(os.on_shelf,0) > 0"
        elif request.args.get('t_collection_type') == 'on_shelf':
            query = query + " AND IFNULL(os.on_shelf,0) > 0"

        # run the query
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            results = cursor.fetchall()
        except:
            abort(400)
        return render_template("titles/search_titles.html", titles=results)

@app.route('/titles/update_title', methods=['GET', 'PUT', 'DELETE', 'POST'])
def update_title():
    db_connection = get_db()
    if request.method == 'PUT':
        # step 6 - Update, probably should be js-based like add_titles
        return render_template("titles/update_title.html")
    elif request.method =='DELETE':
        #step 6 - Delete, probably should be js-based like add_titles
        return render_template("titles/update_title.html")
    elif request.method == 'POST':
        # step 5 - insert, probably should be js-based like add_titles
        # TO-DO for STEP 5
        return render_template("titles/update_title.html")
    elif request.args.get('title_id') is None:
        abort(400)
    else:
        # process the GET request
        # Extract the info for a given title_id to autopopulate the form
        query = 'SELECT * FROM Titles WHERE title_id = %(t_id)s'
        query_params = {'t_id': request.args.get('title_id')}
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        title_results = cursor.fetchone()
        if title_results == None:
            abort(400)

        # get creators associated with title
        query = 'SELECT tc.creator_catalog_id, t.title_id ,c.first_name, c.last_name FROM Titles as t NATURAL JOIN Title_Creators AS tc NATURAL JOIN Creators AS c WHERE title_id = %(t_id)s'
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        title_creator_results = cursor.fetchall()

        #get subject associated with title
        query = 'SELECT ts.subject_catalog_id, t.title_id, s.subject_heading FROM Titles as t NATURAL JOIN Title_Subjects AS ts NATURAL JOIN Subjects AS s WHERE title_id = %(t_id)s'
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        title_subject_results = cursor.fetchall()

        # get all creators
        query = 'SELECT * FROM Creators'
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query)
        creator_results = cursor.fetchall()
        # get all subjects
        query = 'SELECT * FROM Subjects'
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query)
        subject_results = cursor.fetchall()
        return render_template(
            "titles/update_title.html",
            title_info=title_results,
            title_creators=title_creator_results,
            title_subjects=title_subject_results,
            creators=creator_results,
            subjects=subject_results)

@app.route('/items/add_item', methods=['GET', 'POST'])
def add_item():
    # step 5
    db_connection = get_db()
    if request.method == 'POST':
        query = "INSERT INTO Items (title_id, cutter_number) VALUES (%(t_id)s, %(c_num)s)"
        request_data = request.json
        query_params = {
            't_id': request_data['add_title_id'],
            'c_num': request_data['add_cutter_num']
        }
        for key in query_params.keys():
            if query_params[key] == "":
                query_params[key] = None
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            # Tell the user we succeeded
            results = {
                'new_item_id': cursor.lastrowid,
                'add_title_id': query_params['t_id'],
                'add_cutter_num': query_params['c_num']
            }
            return jsonify(results), 201
        except:
            # On a failure, preserve the inputs so the Template can fill them back in.
            return jsonify(request_data), 400
    else:
        query = "SELECT title_text, title_id FROM Titles WHERE title_id=%(t_id)s"
        query_params = {'t_id': request.args.get('title_id')}
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        titles = cursor.fetchone()
        return render_template("/items/add_item.html", title=titles), 200

'''
@app.route('/items')
def items():
    return render_template("items.html")

@app.route('/items/checkout')
def checkout_item():
    return render_template("items/checkout.html")
'''
@app.route('/items/return_item.html', methods=['POST'])
def return_item():
    # step 6 - Update
    return render_template("items/return_item.html")
'''
@app.route('/items/manage')
def manage_item():
    return render_template("items/collection.html")
'''
@app.route('/creators')
def creators():
    return render_template("creators.html")

@app.route('/creators/add_creators', methods=['GET', 'POST'])
def add_creators():
    db_connection = get_db()

    fill_params = {
        'fname': "", 
        'lname': ""
    }

    add_success = "none"
    message_params = None
    status = 200

    if request.method == 'POST':
        query = "INSERT INTO Creators (first_name, last_name) VALUES (%(fname)s, %(lname)s)"
        request_data = request.json
        query_params = {
            'fname': request.form.get('fname'), 
            'lname': request.form.get('lname')
        }
        for key in query_params.keys():
            if query_params[key] == "":
                query_params[key] = None
    # try: 
        cursor = db.execute_query(
            db_connection=db_connection, 
            query=query, query_params=query_params
        )
        add_success = "added"
        message_params = {
            'fname': request.form.get('fname'), 
            'lname': request.form.get('lname'), 
            'id': cursor.lastrowid
        }
        status = 201
        # except: 
        #     status = 400
        #     add_sucess = "error"
        #     fill_params = query_params
    
    return render_template(
        "creators/add_creators.html", 
        success=add_success, 
        creator=fill_params,
        message = message_params
    ), status

@app.route('/creators/view_creators')
def view_creators():
    db_connection = get_db()

    query = "SELECT * FROM Creators"
    query_params = None

    if request.args.get('lname') is not None:
        if request.args.get("lNameMatchType") == 'exact':
            query_params = {'lname': request.args.get('lname')}
            query = query + " WHERE last_name = %(lname)s"
        else:
            search_string = '%' + request.args.get('lname') + '%'
            query_params = {'lname': search_string}
            query = query + " WHERE last_name LIKE %(lname)s"
    
    try: 
        cursor = db.execute_query(
            db_connection=db_connection, 
            query=query, query_params=query_params
        )
        results = cursor.fetchall()
    except: 
        abort(400)

    return render_template("creators/view_creators.html", creators=results)
'''
@app.route('/relationships')
def relationships():
    return render_template("relationships.html")

@app.route('/relationships/add_title_creators')
def add_title_creators():
    return render_template("relationships/add_title_creators.html")

@app.route('/relationships/add_title_subjects')
def add_title_subjects():
    return render_template("relationships/add_title_subjects.html")

@app.route('/relationships/view_title_creators')
def view_title_creators():
    return render_template("relationships/view_title_creators.html")


@app.route('/relationships/view_title_subjects')
def view_title_subjects():
    return render_template("relationships/view_title_subjects.html")
'''

@app.errorhandler(400)
def page_not_found(e):
    # note that we set the 404 status explicitly
    return render_template('400.html'), 400

# Listener

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
