from flask import Blueprint, abort, redirect, render_template, request, session, url_for
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


# user's own profile
@bp.route('/me', methods=['GET'])
@login_required
def me():
    # look up user's prof_id
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
            # account_type = 'person'
            existing_prof_id = account['person_prof_id']
            # owner_id = account['person_id']
        else:
            # account_type = 'organization'
            existing_prof_id = account['org_prof_id']
            # owner_id = account['org_id']

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
    
    # we got the prof_id of self are are injecting that into the general profile view
    return redirect(url_for('profile.view', prof_id=existing_prof_id))


# others' profile
@bp.route('/<int:prof_id>', methods=['GET'])
@login_required
def view(prof_id):
    conn = get_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    # username = session['username']
    
    try:
        # header
        cursor.execute(
            '''
            SELECT profile.prof_id, profile.tagline,
            CASE WHEN person.id is not null then 'person'
                 ELSE 'organization' end as prof_type,
            COALESCE(person.fname || ' ' || person.lname, organization.title) as name,
            person.id as person_id,
            organization.org_id
            FROM profile
            LEFT JOIN person on person.prof_id = profile.prof_id
            LEFT JOIN organization on organization.prof_id = profile.prof_id
            WHERE profile.prof_id = %s
            ''', 
            (prof_id,)
        )

        profile = cursor.fetchone()
        if profile is None:
            abort(404)

        # tags
        cursor.execute(
            '''
            SELECT tag.tag_id, tag.content
            FROM profile_tag
            JOIN tag on tag.tag_id = profile_tag.tag_id
            WHERE profile_tag.prof_id = %s
            ORDER BY tag.content
            ''', 
            (prof_id,)
        )
        tags = cursor.fetchall()

        # contact info
        cursor.execute(
            '''
            -- emails
            SELECT person_email.email as contact, 'email' as contact_type
            FROM person
            JOIN person_email ON person_email.person_id = person.id
            WHERE person.prof_id = %s
            UNION ALL
            SELECT org_email.email as contact, 'email' as contact_type
            FROM organization
            JOIN org_email ON org_email.org_id = organization.org_id
            WHERE organization.prof_id = %s

            UNION ALL
            
            -- phones
            SELECT person_phone.phone as contact, 'phone' as contact_type
            FROM person
            JOIN person_phone ON person_phone.person_id = person.id
            WHERE person.prof_id = %s
            UNION ALL
            SELECT org_phone.phone as contact, 'phone' as contact_type
            FROM organization
            JOIN org_phone ON org_phone.org_id = organization.org_id
            WHERE organization.prof_id = %s
            ORDER BY contact_type, contact
            ''', 
            (prof_id, prof_id, prof_id, prof_id,)
        )
        contacts = cursor.fetchall()

        # addresses
        cursor.execute(
            '''
            SELECT a.street_num, a.street_name, a.city, a.country, a.postal
            FROM person
            JOIN person_address a on a.person_id = person.id
            WHERE person.prof_id = %s
            UNION ALL
            SELECT a.street_num, a.street_name, a.city, a.country, a.postal
            FROM organization
            JOIN org_address a on a.org_id = organization.org_id
            WHERE organization.prof_id = %s
            ORDER BY country, city, street_name, street_num
            ''', 
            (prof_id, prof_id)
        )
        addresses = cursor.fetchall()

        #projects
        cursor.execute(
            '''
            SELECT project.proj_id, project.title, project.descr
            FROM profile_project
            JOIN project ON project.proj_id = profile_project.proj_id
            WHERE profile_project.prof_id = %s
            ORDER BY project.title
            ''', 
            (prof_id,)
        )
        projects = cursor.fetchall()

        # membership / or member of 
        cursor.execute(
            '''
            SELECT organization.title as name, organization.prof_id,
                string_agg(membership.role, ', ' order by membership.role) as roles
            FROM person
            JOIN membership ON membership.person_id = person.id
            JOIN organization ON organization.org_id = membership.org_id
            WHERE person.prof_id = %s
            GROUP BY organization.org_id, organization.title, organization.prof_id

            UNION ALL

            SELECT person.fname || ' ' || person.lname as name, person.prof_id,
                string_agg(membership.role, ', ' order by membership.role) as roles
            FROM organization
            JOIN membership on membership.org_id = organization.org_id
            JOIN person on person.id = membership.person_id
            WHERE organization.prof_id = %s
            GROUP BY person.id, person.fname, person.lname, person.prof_id
            ORDER BY name
            ''', 
            (prof_id, prof_id,)
        )
        membership = cursor.fetchall()

        # to decide on following later

        return render_template('profile/view.html', 
            profile=profile, tags=tags, contacts=contacts, addresses=addresses, projects=projects, membership=membership)

    finally:
        cursor.close()
