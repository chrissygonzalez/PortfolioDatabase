from flask import Blueprint, redirect, render_template, session, url_for
from psycopg2.extras import RealDictCursor

from .auth import login_required
from .db import get_db

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return render_template('main/index.html')


@bp.route('/home')
@login_required
def home():
    username = session['username']

    conn = get_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute(
        '''
        SELECT account.account_id, person.id AS person_id, organization.org_id
        FROM account
        LEFT JOIN person ON person.account_id = account.account_id
        LEFT JOIN organization ON organization.account_id = account.account_id
        WHERE account.username = %s
        ''',
        (username,)
    )
    row = cursor.fetchone()

    if row is None:
        # Session refers to an account that no longer exists
        cursor.close()
        session.pop('username', None)
        return redirect(url_for('auth.login'))

    if row['person_id'] is not None:
        account_type = 'person'
        cursor.execute('SELECT * FROM person WHERE id = %s', (row['person_id'],))
    else:
        account_type = 'organization'
        cursor.execute('SELECT * FROM organization WHERE org_id = %s', (row['org_id'],))
    data = cursor.fetchone()

    if data['prof_id'] is not None:
        return redirect(url_for('profile.me'))

    cursor.close()

    return render_template('main/home.html', username=username, account_type=account_type, data=data)
