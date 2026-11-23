from flask import Blueprint, redirect, render_template, request, session, url_for
from psycopg2.extras import RealDictCursor

from .auth import login_required
from .db import get_db

bp = Blueprint('profile', __name__)


@bp.route('/create', methods=['GET', 'POST'])
@login_required
def create():
    username = session['username']
    conn = get_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    try:
        # Find out whether this account belongs to a person or organization
        cursor.execute(
            '''
            SELECT
                person.id AS person_id,
                person.prof_id AS person_prof_id,
                organization.org_id,
                organization.prof_id AS org_prof_id
            FROM account
            LEFT JOIN person
                ON person.account_id = account.account_id
            LEFT JOIN organization
                ON organization.account_id = account.account_id
            WHERE account.username = %s
            ''',
            (username,)
        )
        account = cursor.fetchone()

        if account is None:
            return redirect(url_for('auth.login'))

        # Identify the account type and check for an existing profile
        if account['person_id'] is not None:
            account_type = 'person'
            existing_prof_id = account['person_prof_id']
            owner_id = account['person_id']
        else:
            account_type = 'organization'
            existing_prof_id = account['org_prof_id']
            owner_id = account['org_id']

        # Don't create a second profile
        if existing_prof_id is not None:
            return redirect(url_for('main.home'))

        if request.method == 'POST':
            tagline = request.form.get('tagline', '').strip()

            if len(tagline) > 100:
                return render_template(
                    'profile/create.html',
                    error='Tagline must be 100 characters or fewer'
                )

            # Create the profile and get its generated ID
            cursor.execute(
                'INSERT INTO profile (tagline) VALUES (%s) RETURNING prof_id',
                (tagline,)
            )
            prof_id = cursor.fetchone()['prof_id']

            # Connect the new profile to its owner
            if account_type == 'person':
                cursor.execute(
                    'UPDATE person SET prof_id = %s WHERE id = %s',
                    (prof_id, owner_id)
                )
            else:
                cursor.execute(
                    'UPDATE organization SET prof_id = %s WHERE org_id = %s',
                    (prof_id, owner_id)
                )

            conn.commit()
            return redirect(url_for('main.home'))

        return render_template('profile/create.html')

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
