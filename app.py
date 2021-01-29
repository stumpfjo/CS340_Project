from flask import Flask, render_template, request, json
# import database.db_connector as db
import os

# Configuration

app = Flask(__name__)

# Routes

@app.route('/')
def index(): 
    return render_template("index.html")

@app.route('/books')
def books():
    return render_template("books.html")

@app.route('/borrowers')
def borrowers():
    return render_template("borrowers.html")

@app.route('/subjects')
def subjects():
    return render_template("subjects.html")

@app.route('/titles')
def titles():
    return render_template("titles.html")

@app.route('/items')
def items():
    return render_template("items.html")
    
@app.route('/checkout')
def checkout():
    return render_template("checkout.html")

# Listener

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9112))
    app.run(port=port, debug=True)
