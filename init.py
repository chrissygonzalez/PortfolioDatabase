#Import Flask Library
from flask import Flask, render_template, request, session, url_for, redirect
from werkzeug.security import generate_password_hash, check_password_hash
import psycopg2
from psycopg2.extras import RealDictCursor

#Initialize the app from Flask
app = Flask(__name__)

conn = psycopg2.connect(
    host="localhost",       # e.g., localhost or an AWS RDS endpoint
    port="5432",                    # Default Postgres port
    database="portfolio",
    user="postgres",
    password="postgres"
)

#Define a route to hello function
@app.route('/')
def hello():
	return render_template('index.html')

#Define route for login
@app.route('/login')
def login():
	return render_template('login.html')

#Define route for register
@app.route('/register')
def register():
	return render_template('register.html')

#Authenticates the login
@app.route('/loginAuth', methods=['GET', 'POST'])
def loginAuth():
	#grabs information from the forms
	username = request.form['username']
	password = request.form['password']

	#cursor used to send queries
	cursor = conn.cursor(cursor_factory=RealDictCursor)
	#executes query
	query = 'SELECT * FROM account WHERE username = %s'
	cursor.execute(query, (username,))
	#stores the results in a variable
	data = cursor.fetchone()
	#use fetchall() if you are expecting more than 1 data row
	cursor.close()
	error = None
	if(data and check_password_hash(data['password_hash'], password)):
		#creates a session for the the user
		#session is a built in
		session['username'] = username
		return redirect(url_for('home'))
	else:
		#returns an error message to the html page
		error = 'Invalid login or username'
		return render_template('login.html', error=error)

#Authenticates the register
@app.route('/registerAuth', methods=['GET', 'POST'])
def registerAuth():
	#grabs information from the forms
	username = request.form['username']
	password = request.form['password']

	#cursor used to send queries
	cursor = conn.cursor()
	#executes query
	query = 'SELECT * FROM account WHERE username = %s'
	cursor.execute(query, (username,))
	#stores the results in a variable
	data = cursor.fetchone()
	#use fetchall() if you are expecting more than 1 data row
	error = None
	if(data):
		#If the previous query returns data, then user exists
		error = "This user already exists"
		return render_template('register.html', error = error)
	else:
		password_hash = generate_password_hash(password)
		ins = 'INSERT INTO account (username, password_hash) VALUES (%s, %s) RETURNING account_id'
		cursor.execute(ins, (username, password_hash))
		conn.commit()
		cursor.close()
		return render_template('index.html')

@app.route('/home')
def home():
    username = session['username']
    cursor = conn.cursor(cursor_factory=RealDictCursor);
    query = 'select account.account_id, account.password_hash, person.id as person_id, organization.org_id from account left join person on person.account_id = account.account_id left join organization on organization.account_id = account.account_id where account.username = %s;'
    cursor.execute(query, (username,))
    row = cursor.fetchone()
    cursor.close()

    if row:
        if row['person_id'] is not None:
            account_type = 'person'
            person_id = row['person_id']
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            query = 'select * from person where id = %s;'
            cursor.execute(query, (person_id,))
            data = cursor.fetchone()
            cursor.close()
        else:
            account_type = 'organization'
            org_id = row['org_id']
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            query = 'select * from organization where id = %s;'
            cursor.execute(query, (org_id,))
            data = cursor.fetchone()
            cursor.close()
    
    return render_template('home.html', username=username, account_type=account_type, data=data)


@app.route('/logout')
def logout():
	session.pop('username')
	return redirect('/')
		
app.secret_key = 'some key that you will never guess'
#Run the app on localhost port 5000
#debug = True -> you don't have to restart flask
#for changes to go through, TURN OFF FOR PRODUCTION
if __name__ == "__main__":
	app.run('127.0.0.1', 5000, debug = True)
