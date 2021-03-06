# Citation for the following app:
# Date: 2020-02-07
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://github.com/gkochera/CS340-demo-flask-app

from flask import Flask, render_template, request, json, jsonify, abort, make_response
import database.db_connector as db
import os
from datetime import datetime, timedelta, date
from data import states
from helpers import *

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

# Displays an index page with links to all other pages in the site
@app.route('/')
def index():
    return render_template("main.html")

# Page to CREATE new Borrowers
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
            'zip': request.form.get('zipCode')
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

    # Will have the correct format for all scenarios
    return render_template(
        "borrowers/add_borrowers.html",
        success=add_success,
        borrower=fill_params,
        message=message_params,
        states=states
    ), status

# Page to UPDATE Borrowers (READs from Borrowers to populate form controls)
@app.route('/borrowers/update_borrowers', methods=['GET','PUT'])
def update_borrowers():
    # PUT request means we have been sent new data for a borrower
    db_connection = get_db()
    if request.method == 'PUT':
        query = "UPDATE Borrowers SET first_name = %(f_name)s, last_name = %(l_name)s, email = %(email)s, street_address = %(saddr)s, city_name = %(city)s, state = %(state)s, zip_code = %(zip)s WHERE borrower_id = %(b_id)s"
        request_data = request.json
        query_params = {
            'f_name': request_data['first_name'],
            'l_name': request_data['last_name'],
            'email': request_data['email'],
            'saddr': request_data['street_address'],
            'city': request_data['city_name'],
            'state': request_data['state'],
            'zip': request_data['zip_code'],
            'b_id': request_data['borrower_id']
        }
        try:
            # run the update
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            # Should not get here
            print('query fail')
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

        # send the updated borrower info back so the client can update display
        results = get_one_borrower(db_connection, query_params['b_id'])
        response = make_response(jsonify(results), 200)
        response.mimetype = 'application/json'
        return response

    # behavior for GET. This is initial access or switch of borrower
    # Retrieve info for the selected borrower
    try:
        current = get_one_borrower(db_connection, request.args.get('id'))
    except:
        abort(400)

    # populate a dropdown to select a different borrower
    borrowers = get_all_borrowers(db_connection)
    return render_template("borrowers/update_borrowers.html", states=states, current=current, borrowers=borrowers)

# Page to READ from Borrowers. Supports text-based search by user entry.
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
        # run the query we constructed
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
            # Grab the results
        results = cursor.fetchall()
    except:
        abort(400)

    return render_template("borrowers/view_borrowers.html", borrowers=results)

# Page to READ and UPDATE from Items table.
# Supports NULLing the relationship between Items and Borrowers
# Secondarily READs from Borrowers.
@app.route('/items/view_checkouts', methods=['GET','PUT'])
def view_checkouts():
    db_connection = get_db()
    # PUT means we are attempting a return
    if request.method == 'PUT':
        query = "UPDATE Items SET borrower_id = NULL, due_date = NULL WHERE item_id = %(i_id)s"
        request_data = request.json
        query_params = {
            'i_id': request_data['item_id']
        }
        try:
            # run the update
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            # Should not get here
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

        results = get_checkouts(db_connection, request_data['borrower_id'])
        for r in results:
            if r['due_date']:
                r['due_date'] = r['due_date'].strftime('%Y-%m-%d')
        response = make_response(jsonify(results), 200)
        response.mimetype = 'application/json'
        return response

    # routing for GET (initial access or switch of borrower)
    results = None
    status = 200
    try:
        # nonsense borrower_ids should generate an empty result
        results = get_checkouts(db_connection, request.args.get('id'))
        for r in results:
            if r['due_date']:
                r['due_date'] = r['due_date'].strftime('%Y-%m-%d')
    except:
        # Should not get here
        abort(400)

    # get info of current borrower
    current = get_one_borrower(db_connection, request.args.get('id'))

    # Get a list of all borrowers to populate dropdown
    borrowers = get_all_borrowers(db_connection)

    return render_template("items/view_checkouts.html", results=results, current=current, borrowers=borrowers), status

# Page to READ and UPDATE from Items table.
# Supports creating the 1:m relation between Items/Borrowers.
# Secondarily READs from Borrowers.
@app.route('/items/add_checkouts', methods=['GET','PUT'])
def add_checkouts():
    #step 6 - Update
    db_connection = get_db()
    # PUT request used to send request for checkout
    if request.method == 'PUT':
        query = "UPDATE Items SET borrower_id = %(b_id)s, due_date = %(d_date)s WHERE item_id = %(i_id)s"
        request_data = request.json
        query_params = {
            'b_id': request_data['borrower_id'],
            'i_id': request_data['item_id'],
            'd_date': (date.today() + timedelta(days=14)).strftime('%Y-%m-%d')
        }
        try:
            # run the update
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            print('success')
        except:
            # Should not get here
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

        # get a list of items available for checkout
        available_items = get_available_items(db_connection)
        data = {
            'borrower_id': request_data['borrower_id'],
            'available_items': available_items
        }
        response = make_response(jsonify(data), 200)
        response.mimetype = 'application/json'
        return response

    # routing for GET (access page or switch borrower)
    # get info of current borrower
    current = get_one_borrower(db_connection, request.args.get('id'))

    # Get a list of all borrowers to populate dropdown
    borrowers = get_all_borrowers(db_connection)

    results = ""
    available_items={}
    if current is not None:
        # get a list of items available for checkout
        available_items = get_available_items(db_connection)

    return render_template("items/add_checkouts.html", current=current, borrowers=borrowers, available_items=available_items)

# Page to READ and DELETE from the Items table.
@app.route('/items/weed_items', methods=['GET','DELETE'])
def weed_items():
    # step 6 - Delete
    db_connection = get_db()
    if request.method == 'DELETE':
        # Deletion query
        query = "DELETE FROM Items WHERE item_id = %(i_id)s"
        request_data = request.json
        query_params = {
            'i_id': request_data['item_id']
        }
        try:
            # attempt the delete
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            # Send back the item that got deleted
            return jsonify(query_params), 200
        except:
            # Should not get here
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

    # route for 'GET'
    results = [];
    search = {
        'title_text': '',
        'last_name': '',
        'subject_heading': ''
    };
    # set up the correct search query
    if request.args.get('search'):
        if request.args.get('searchBy') == 'title':
            # LIKE match on title_text
            query = "SELECT DISTINCT i.item_id, i.cutter_number, t.title_text, t.call_number FROM Items AS i NATURAL JOIN Titles AS t WHERE t.title_text LIKE %(t_text)s ORDER BY t.title_text"
            search_string = '%' + request.args.get('title_text') + '%'
            query_params = {'t_text': search_string}
            search['title_text'] = request.args.get('title_text')
        elif request.args.get('searchBy') == 'creator':
            # LIKE match ofn creator last_name
            query = "SELECT DISTINCT i.item_id, i.cutter_number, t.title_text, t.call_number FROM Items AS i NATURAL JOIN Titles AS t NATURAL JOIN Title_Creators as tc NATURAL JOIN Creators as c WHERE c.last_name LIKE %(l_name)s ORDER BY t.title_text"
            search_string = '%' + request.args.get('last_name') + '%'
            query_params = {'l_name': search_string}
            search['last_name'] = request.args.get('last_name')
        elif request.args.get('searchBy') == 'subject':
            # LIKE match on subject_heading
            query = "SELECT DISTINCT i.item_id, i.cutter_number, t.title_text, t.call_number FROM Items AS i NATURAL JOIN Titles AS t NATURAL JOIN Title_Subjects as ts NATURAL JOIN Subjects as s WHERE s.subject_heading LIKE %(s_head)s ORDER BY t.title_text"
            search_string = '%' + request.args.get('subject_heading') + '%'
            query_params = {'s_head': search_string}
            search['subject_heading'] = request.args.get('subject_heading')
        else:
            abort(400)
        try:
            # run the search
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        results = cursor.fetchall()

    return render_template("items/weed_items.html", results=results, search=search)

# Page to support CREATE for Subjects table
@app.route('/subjects/add_subjects.html', methods=['GET', 'POST'])
def add_subjects():
    db_connection = get_db()
    fill_params = {
        'subject': ""
    }

    add_success = "none"
    message_params = None
    status = 200

    # INSERT the supplied data
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
    # GET routing will fall through to here
    return render_template(
        "subjects/add_subjects.html",
        success=add_success,
        subject=fill_params,
        message=message_params
    ), status

# Page to READ from Subjects table (linked to Titles table)
# uses populated dropdown to filter Titles
@app.route('/subjects/view_subjects', methods=["GET"])
def view_subjects():
    subjectId = request.args.get('subjectId', default=-1, type=int)
    db_connection_subjects = get_db()

    query = "SELECT * FROM Subjects"

    cursorSubjects = db.execute_query(
        db_connection=db_connection_subjects,
        query=query, query_params=None
    )
    subjectResults = cursorSubjects.fetchall()
    subjectTitlesResults = []

    selected = subjectResults[0]['subject_id']

    # get the Titles associated with the selected subject_heading
    if subjectId > 0:
        query = "SELECT * FROM Titles JOIN Title_Subjects ON Titles.title_id = Title_Subjects.title_id WHERE subject_id = %(s_id)s"
        query_params = {
            's_id': subjectId
        }

        db_connection_titles = get_db()

        cursorTitles = db.execute_query(
            db_connection=db_connection_titles,
            query=query, query_params=query_params)
        subjectTitlesResults = cursorTitles.fetchall()
        selected = subjectId

    return render_template("/subjects/view_subjects.html", subjects=subjectResults, titles=subjectTitlesResults, selected=selected)

# Page to CREATE new Titles
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

# Page to READ from Titles table
@app.route('/titles/search_titles', methods=['GET'])
def search_titles():
    # step 5
    db_connection = get_db()
    if request.args.get('search') != 'Search':
        return render_template("titles/search_titles.html", titles=None, search_string='')
    else:
        # query to generate desired results and calculate in collection/on-shelf
        query = "SELECT t.title_id, t.title_text, t.language, t.publication_year, t.edition, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf FROM Titles AS t LEFT OUTER JOIN (SELECT title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (SELECT title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id"

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
        return render_template("titles/search_titles.html", titles=results, search_string=request.args.get('title_text'))

# Page to support UPDATE for Titles table (READs from Titles table to populate)
# Also supports READ from Title_Creators and from Title_Subjects as well as
# READ from Subjects and Creators.
# Supports DELETE and CREATE for Title_Creators and Title_Subjects
# (controls m:m relationships between Titles and Creators and
# between Titles and Subjects)
@app.route('/titles/update_title', methods=['GET', 'PUT', 'DELETE', 'POST'])
def update_title():
    db_connection = get_db()
    if request.method == 'PUT':
        # PUT request sends us new info for a title
        query = "UPDATE Titles SET title_text = %(t_text)s, publication_year = %(p_year)s, edition = %(edition)s, language = %(lang)s, call_number = %(c_num)s WHERE title_id = %(t_id)s"
        request_data = request.json
        query_params = {
            't_text': request_data['title_text'],
            'p_year': request_data['publication_year'],
            'edition': request_data['edition'],
            'lang': request_data['language'],
            'c_num': request_data['call_number'],
            't_id': request_data['title_id']
        }
        try:
            # run the update
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            # Should not get here
            print('query fail')
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

        query = "SELECT * FROM Titles WHERE title_id = %(t_id)s"
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
        results = cursor.fetchone()
        print(results)
        response = make_response(jsonify(results), 200)
        response.mimetype = 'application/json'
        return response

    elif request.method =='DELETE':
        # DELETE request manipulates Title_Creators or Title_Subjects
        request_data = request.json
        # process disassociating a creator from a title
        if request_data['request_type'] == 'removeCreator':
            query = "DELETE FROM Title_Creators WHERE creator_catalog_id = %(creator_catalog_id)s"
            query_params = {
                'creator_catalog_id': request_data['creator_catalog_id']
            }
            try:
                # run the delete
                cursor = db.execute_query(
                    db_connection=db_connection,
                    query=query, query_params=query_params)
            except:
                # Should not get here
                print('query fail')
                response = make_response('Bad Request', 400)
                response.mimetype = "text/plain"
                return response
            #return the row that got deleted so the interface can update
            response = make_response(jsonify(query_params), 200)
            response.mimetype = "application/json"
            return response
        # process disassociating a subject from a title
        elif request_data['request_type'] == 'removeSubject':
            query = "DELETE FROM Title_Subjects WHERE subject_catalog_id = %(subject_catalog_id)s"
            query_params = {
                'subject_catalog_id': request_data['subject_catalog_id']
            }
            try:
                # run the delete
                cursor = db.execute_query(
                    db_connection=db_connection,
                    query=query, query_params=query_params)
            except:
                # Should not get here
                print('query fail')
                response = make_response('Bad Request', 400)
                response.mimetype = "text/plain"
                return response
            # return the deleted row so the interface can refresh
            response = make_response(jsonify(query_params), 200)
            response.mimetype = "application/json"
            return response
        else:
            # Should not get here
            print('query fail')
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response
    elif request.method == 'POST':
        # POST request manipulates Title_Creators or Title_Subjects
        request_data = request.json
        # determine which entity we are working with and proceed accordingly
        if request_data['request_type'] == 'linkCreator':
            # need to link a new creator to the title
            query = "INSERT INTO Title_Creators (title_id, creator_id) VALUES (%(title_id)s, %(creator_id)s)"
            query_params = {
                'title_id': request_data['title_id'],
                'creator_id': request_data['creator_id']
            }
            try:
                # run the delete
                cursor = db.execute_query(
                    db_connection=db_connection,
                    query=query, query_params=query_params)
            except:
                # Should not get here
                print('query fail')
                response = make_response('Bad Request', 400)
                response.mimetype = "text/plain"
                return response
            # return the new row so the interface can refresh
            query_params['creator_catalog_id'] = cursor.lastrowid
            query = "SELECT * FROM Creators WHERE creator_id = %(creator_id)s"
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            results = cursor.fetchone()
            query_params['last_name'] = results['last_name']
            query_params['first_name'] = results['first_name']
            query_params['action'] = '/titles/update_title'

            response = make_response(jsonify(query_params), 200)
            response.mimetype = "application/json"
            return response
        elif request_data['request_type'] == 'linkSubject':
            #need to link a new subject to the title
            query = "INSERT INTO Title_Subjects (title_id, subject_id) VALUES (%(title_id)s, %(subject_id)s)"
            query_params = {
                'title_id': request_data['title_id'],
                'subject_id': request_data['subject_id']
            }
            try:
                # run the delete
                cursor = db.execute_query(
                    db_connection=db_connection,
                    query=query, query_params=query_params)
            except:
                # Should not get here
                print('query fail')
                response = make_response('Bad Request', 400)
                response.mimetype = "text/plain"
                return response
            # return the new row so the interface can refresh
            query_params['subject_catalog_id'] = cursor.lastrowid
            query = "SELECT * FROM Subjects WHERE subject_id = %(subject_id)s"
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            results = cursor.fetchone()
            query_params['subject_heading'] = results['subject_heading']
            query_params['action'] = '/titles/update_title'

            response = make_response(jsonify(query_params), 200)
            response.mimetype = "application/json"
            return response
        else:
            # Should not get here
            print('query fail')
            response = make_response('Bad Request', 400)
            response.mimetype = "text/plain"
            return response

    else:
        # process the GET request
        # Extract the info for a given title_id to autopopulate the form
        # GET used to switch title or for initial page load
        query = 'SELECT * FROM Titles WHERE title_id = %(t_id)s'
        query_params = {'t_id': request.args.get('title_id')}
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        title_results = cursor.fetchone()

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

        # get the list of titles
        query = "SELECT title_text, title_id FROM Titles ORDER BY title_text"
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
        titles= cursor.fetchall()

        return render_template(
            "titles/update_title.html",
            title_info=title_results,
            title_creators=title_creator_results,
            title_subjects=title_subject_results,
            creators=creator_results,
            subjects=subject_results, titles=titles)

# Page to CREATE new Items (and link them in the 1:m relationship to Titles)
@app.route('/items/add_item', methods=['GET', 'POST'])
def add_item():
    db_connection = get_db()
    if request.method == 'POST':
        # POST used to send new item info
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
        except:
            # On a failure, preserve the inputs so the Template can fill them back in.
            return jsonify(request_data), 400

        # Send back the new item info to indicate success
        query_params = {'i_id': cursor.lastrowid}
        query = "SELECT i.cutter_number, t.title_text, t.call_number FROM Items AS i NATURAL JOIN Titles AS t WHERE i.item_id = %(i_id)s"
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
        results = cursor.fetchone()
        return jsonify(results), 201

    else: # method is GET (Intitial access or title is switched)
        query = "SELECT title_text, title_id FROM Titles WHERE title_id=%(t_id)s"
        query_params = {'t_id': request.args.get('title_id')}
        # get the current title
        try:
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
        except:
            abort(400)
        current = cursor.fetchone()

        # get the list of titles
        query = "SELECT title_text, title_id FROM Titles ORDER BY title_text"
        cursor = db.execute_query(
            db_connection=db_connection,
            query=query, query_params=query_params)
        titles= cursor.fetchall()

        # get the existing copies of this title
        items = None
        if current is not None:
            query = "SELECT i.cutter_number, t.title_text, t.call_number FROM Items AS i NATURAL JOIN Titles AS t WHERE t.title_id = %(t_id)s"
            cursor = db.execute_query(
                db_connection=db_connection,
                query=query, query_params=query_params)
            items = cursor.fetchall()

        return render_template("/items/add_item.html", current=current, titles=titles, items=items), 200

# Page to CREATE new Creators
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

    # POST used to supply new data
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

    # GET falls through to here; used for initial page load
    return render_template(
        "creators/add_creators.html",
        success=add_success,
        creator=fill_params,
        message = message_params
    ), status

# Page to READ from Creators table
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


@app.errorhandler(400)
def page_not_found(e):
    # note that we set the 404 status explicitly
    return render_template('400.html'), 400

# Listener

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
