import streamlit as st
from sqlalchemy import create_engine, text
import openai
import re

# Load sql secrets from secrets.toml
db_config = st.secrets["azure_sql"]

server = db_config["server"]
database = db_config["database"]
username = db_config["username"]
password = db_config["password"]

connection_string = (
    f"mssql+pyodbc://{username}:{password}@{server}/{database}"
    "?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=no"
)

# Create SQLAlchemy engine
engine = create_engine(connection_string)

# OpenAI client setup
client = openai.OpenAI(api_key=st.secrets["open_ai"]["api_key"])

def is_safe_sql(query: str) -> bool:
    """
    Check sql query is safe
    """

    forbidden_keywords = ["drop", "delete", "update", "insert", "alter", "truncate", "merge", "exec", "execute"]
    query_lower = query.lower()
    if not query_lower.strip().startswith("select"):
        return False
    pattern = r'\b(' + '|'.join(forbidden_keywords) + r')\b'
    if re.search(pattern, query_lower):
        return False
    return True

def run_sql_query(sql: str):
    """
    Execute SQL query safely and return rows or error.
    """
    if not is_safe_sql(sql):
        st.warning("Only safe SELECT queries are allowed.")
        return None

    try:
        with engine.connect() as conn:
            result = conn.execute(text(sql))
            if result.returns_rows:
                rows = result.fetchall()
                return rows
            else:
                st.success(f"Query executed successfully, {result.rowcount} row(s) affected.")
                return []
    except Exception as e:
        st.error(f"Error running query: {e}")
        return None


def generate_sql_from_prompt(user_input: str) -> str | None:
    """
    Call OpenAI to generate SQL query based on the user's input.
    This solution is gpt-3.5-turbo and 150 tokens limit to minimise costs
    """
    system_message = """
    You are an SQL assistant for a shipment tracking database.
    You are querying Azure SQL Server.
    Important:
    - For limiting rows, use SQL Server syntax: SELECT TOP N ...
    - Do not use LIMIT — it is not supported in SQL Server.

    The database schema is:

    Schema: track

    Tables:

        track.suppliers (supplier_id, supplier_name, contact_email, contact_phone, address, created_at, updated_at, record_status)

        track.materials (material_id, material_name, description, created_at, updated_at, record_status)

        track.shipments (shipment_id, supplier_id, shipment_number, shipment_date, expected_delivery_date, status, created_at, updated_at, record_status)

        track.shipment_items (shipment_item_id, shipment_id, material_id, quantity, unit_price, created_at, updated_at, record_status)

    Use only these tables.

    Your job is:

    - Generate only valid, safe SQL queries (no explanations, no comments, no drop/alter/delete).
    - Only generate SELECT queries. Do not write INSERT, UPDATE, or DELETE.
    - If the user asks something you cannot answer in SQL, politely return: -- Cannot generate query for that request.
    - Keep the SQL clear, readable, and properly joined when needed.
    - Include fully qualified table names, e.g., track.shipments.

    Example questions:

    - Show all shipments that are delayed.
    - List all materials supplied by supplier X.
    - Find total value (quantity × unit_price) for each shipment.

    Respond only with the SQL query.
    """

    messages = [
        {"role": "system", "content": system_message},
        {"role": "user", "content": user_input},
    ]

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=150,
        )
        generated_sql = response.choices[0].message.content.strip()
        return generated_sql
    except Exception as e:
        st.error(f"OpenAI error: {e}")
        return None


# -------------------
# Streamlit UI
# -------------------

st.title("Shipment Tracker")

# SQL Query Form with safety check

st.subheader("SQL Query Form")

sql_command = st.text_area("Enter your SQL command:")

if st.button("Run Query"):
    if not sql_command.strip():
        st.warning("Please enter a SQL command.")
    else:
        rows = run_sql_query(sql_command)
        if rows is not None:
            if rows:
                st.table([dict(row._mapping) for row in rows])
            else:
                st.info("Query executed successfully, but no rows returned.")


# Chat form with refactored prompt and function

st.subheader("Chat with SQL assistant")

if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat history
for msg in st.session_state.messages:
    st.write(f"**{msg['role']}**: {msg['content']}")

user_input = st.text_input("You:", key="input")

if user_input and st.button("Send"):
    st.session_state.messages.append({"role": "user", "content": user_input})

    with st.spinner("Generating SQL..."):
        generated_sql = generate_sql_from_prompt(user_input)

    if generated_sql:
        st.write(f"**Generated SQL:**\n{generated_sql}")

        rows = run_sql_query(generated_sql)
        if rows is not None:
            if rows:
                st.table([dict(row._mapping) for row in rows])
            else:
                st.info("No results found.")

        st.session_state.messages.append({"role": "bot", "content": generated_sql})
