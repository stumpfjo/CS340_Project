# Citation for the following function:
# Date: 2020-02-07
# Copied from /OR/ Adapted from /OR/ Based on:
# Source URL: https://github.com/gkochera/CS340-demo-flask-app

from flask import Flask, render_template, request, json
import database.db_connector as db
import os

db_connection = db.connect_to_database()

# Configuration

app = Flask(__name__)

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
@app.route('/borrowers/add_borrowers')
def add_borrowers():
    return render_template("borrowers/add_borrowers.html")

@app.route('/borrowers/delete_borrower')
def delete_borrower():
    return render_template("borrowers/delete_borrower.html")

@app.route('/borrowers/update_borrowers')
def update_borrowers():
    return render_template("borrowers/update_borrowers.html")

@app.route('/borrowers/view_borrowers')
def view_borrowers():
    return render_template("borrowers/view_borrowers.html")

@app.route('/borrowers/view_checkouts')
def view_checkouts():
    return render_template("borrowers/view_checkouts.html")

@app.route('/items/add_checkouts')
def add_checkouts():
    return render_template("items/add_checkouts.html")

@app.route('/subjects')
def subjects():
    return render_template("subjects.html")

@app.route('/subjects/add_subjects.html')
def add_subjects():
    return render_template("subjects/add_subjects.html")

@app.route('/subjects/view_subjects')
def view_subjects():
    return render_template("subjects/view_subjects.html")
'''
@app.route('/titles')
def titles():
    return render_template("titles.html")
'''
@app.route('/titles/add_titles')
def add_titles():
    return render_template("titles/add_titles.html")

@app.route('/titles/search_titles')
def search_titles():
    return render_template("titles/search_titles.html")

@app.route('/titles/update_title', methods=['GET', 'POST'])
def update_title():
    return render_template("titles/update_title.html")

@app.route('/items/add_item')
def add_item():
    return render_template("/items/add_item.html")
'''
@app.route('/items')
def items():
    return render_template("items.html")

@app.route('/items/checkout')
def checkout_item():
    return render_template("items/checkout.html")
'''
@app.route('/items/return_item.html')
def return_item():
    return render_template("items/return_item.html")
'''
@app.route('/items/manage')
def manage_item():
    return render_template("items/collection.html")
'''
@app.route('/creators')
def creators():
    return render_template("creators.html")

@app.route('/creators/add_creators')
def add_creators():
    return render_template("creators/add_creators.html")

@app.route('/creators/view_creators')
def view_creators():
    return render_template("creators/view_creators.html")
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
# Listener

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
