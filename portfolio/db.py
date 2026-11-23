import psycopg2
from flask import current_app, g


def get_db():
    """Return this request's database connection, opening it if needed."""
    if 'db' not in g:
        config = current_app.config
        g.db = psycopg2.connect(
            host=config['DB_HOST'],
            port=config['DB_PORT'],
            dbname=config['DB_NAME'],
            user=config['DB_USER'],
            password=config['DB_PASSWORD'],
        )
    return g.db


def close_db(e=None):
    """Close the connection at the end of the request."""
    db = g.pop('db', None)
    if db is not None:
        db.close()


def init_app(app):
    app.teardown_appcontext(close_db)
