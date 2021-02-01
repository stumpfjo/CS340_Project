from flask import Flask, render_template, request, json
# import database.db_connector as db
import os

# Configuration

app = Flask(__name__)

# Routes

@app.route('/index.html')
def static_index():
    return render_template("index.html")

@app.route('/')
def index():
    return render_template("main.html")

@app.route('/books')
def books():
    return render_template("books.html")

@app.route('/borrowers')
def borrowers():
    return render_template("borrowers.html")

@app.route('/borrowers/add_borrowers')
def add_borrowers():
    return render_template("borrowers/add_borrowers.html")

@app.route('/borrowers/view_borrowers')
def view_borrowers():
    return render_template("borrowers/view_borrowers.html")

@app.route('/borrowers/view_checkouts')
def view_borrower_checkouts():
    return render_template("borrowers/view_checkouts.html")

@app.route('/subjects')
def subjects():
    return render_template("subjects.html")

@app.route('/titles')
def titles():
    return render_template("titles.html")

@app.route('/titles/add_titles')
def add_titles():
    return render_template("titles/add_titles.html")

@app.route('/titles/search_titles')
def search_titles():
    return render_template("titles/search_titles.html")

@app.route('/items')
def items():
    return render_template("items.html")

@app.route('/items/checkout')
def checkout_item():
    return render_template("items/checkout.html")

@app.route('/items/manage')
def manage_item():
    return render_template("items/collection.html")

@app.route('/creators')
def creators():
    return render_template("creators.html")    

@app.route('/creators/add_creators')
def add_creators():
    return render_template("creators/add_creators.html") 

@app.route('/creators/view_creators')
def view_creators():
    return render_template("creators/view_creators.html")

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

# Listener

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
