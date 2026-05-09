import psycopg2
import psycopg2.extras
import streamlit as st


def get_conn():
    """Open a connection using the secret stored in Streamlit."""
    return psycopg2.connect(
        st.secrets["DATABASE_URL"],
        cursor_factory=psycopg2.extras.RealDictCursor
    )


def fetch_all(query, params=None):
    """Run a SELECT and return all rows as a list of dicts."""
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())
            return cur.fetchall()


def fetch_one(query, params=None):
    """Run a SELECT and return a single row as a dict (or None)."""
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())
            return cur.fetchone()


def execute(query, params=None):
    """Run an INSERT / UPDATE / DELETE and commit."""
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())
        conn.commit()
