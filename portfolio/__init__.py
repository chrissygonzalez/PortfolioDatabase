import os

from flask import Flask


def create_app():
    """Application factory: builds and configures the Flask app."""
    app = Flask(__name__)
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('SECRET_KEY', 'dev'),
        DB_HOST=os.environ.get('DB_HOST', 'localhost'),
        DB_PORT=os.environ.get('DB_PORT', '5432'),
        DB_NAME=os.environ.get('DB_NAME', 'portfolio'),
        DB_USER=os.environ.get('DB_USER', 'postgres'),
        DB_PASSWORD=os.environ.get('DB_PASSWORD', 'postgres'),
    )

    from . import auth, db, main, profile

    db.init_app(app)
    app.register_blueprint(auth.bp)
    app.register_blueprint(main.bp)
    app.register_blueprint(profile.bp, url_prefix='/profile')

    return app
