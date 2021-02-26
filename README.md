# CS340_Project
CS340 Project

Code is structured based on the sample code repository provided at https://github.com/gkochera/CS340-demo-flask-app.
Flask code to handle incoming requests is in app.py in the base directory.
The database directory contains modified gkochera code for db_connector.py for connecting to MySQL/MariaDB as well as DDL/DML files.
Database connection uses environment variables as described in gkochera documentation.
The requirements.txt contains the dependencies added to the venv.
The static directory contains javascript sources used to generate http requests for various pages and a css file.
The templates directory and its subdirectories contain jinja templates used to render pages. Some of these are no longer in use and need to be cleaned up (TODO).
