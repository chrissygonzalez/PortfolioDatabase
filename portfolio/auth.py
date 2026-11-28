from functools import wraps

from flask import Blueprint, redirect, render_template, request, session, url_for
from psycopg2 import IntegrityError
from psycopg2.extras import RealDictCursor
from werkzeug.security import check_password_hash, generate_password_hash

from .db import get_db

bp = Blueprint('auth', __name__)


def login_required(view):
    """Redirect to the login page if no user is logged in."""
    @wraps(view)
    def wrapped(*args, **kwargs):
        if session.get('username') is None:
            return redirect(url_for('auth.login'))
        return view(*args, **kwargs)
    return wrapped


@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('auth/login.html')

    username = request.form['username']
    password = request.form['password']

    conn = get_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute('SELECT * FROM account WHERE username = %s', (username,))
    data = cursor.fetchone()
    cursor.close()

    if data and check_password_hash(data['password_hash'], password):
        session['username'] = username
        return redirect(url_for('profile.me'))

    return render_template('auth/login.html', error='Invalid login or username')


@bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return render_template('auth/register.html')

    username = request.form['username']
    password = request.form['password']
    account_type = request.form['account-type']

    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute('SELECT * FROM account WHERE username = %s', (username,))
        if cursor.fetchone():
            return render_template('auth/register.html', error='This user already exists')

        password_hash = generate_password_hash(password)
        cursor.execute(
            'INSERT INTO account (username, password_hash) VALUES (%s, %s) RETURNING account_id',
            (username, password_hash)
        )
        account_id = cursor.fetchone()[0]

        if account_type == 'person':
            cursor.execute(
                'INSERT INTO person (account_id, fname, lname) VALUES (%s, %s, %s)',
                (account_id, request.form['firstname'], request.form['lastname'])
            )
        elif account_type == 'org':
            cursor.execute(
                'INSERT INTO organization (account_id, title) VALUES (%s, %s)',
                (account_id, request.form['title'])
            )
        else:
            raise ValueError('unknown account type')

        conn.commit()
    except (IntegrityError, ValueError):
        conn.rollback()
        return render_template('auth/register.html', error='Registration failed, please try again')
    finally:
        cursor.close()

    session['username'] = username
    return redirect(url_for('main.home'))


@bp.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('main.index'))
