import streamlit as st
from sqlalchemy import create_engine, text

# Credentials
server = "shipmentdata.database.windows.net"
database = "ShipmentData"
username = "shipmentdataadmin"
password = "Azure2025!1"

connection_string = (
    f"mssql+pyodbc://{username}:{password}@{server}/{database}"
    "?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=no"
)

# Create SQLAlchemy engine
engine = create_engine(connection_string)

st.title("Shipment Tracker SQL Query Form")

sql_command = st.text_area("Enter your SQL command:")

if st.button("Run Query"):
    if not sql_command.strip():
        st.warning("Please enter a SQL command.")
    else:
        try:
            with engine.connect() as conn:
                result = conn.execute(text(sql_command))

                # If the statement returns rows (e.g. SELECT)
                if result.returns_rows:
                    rows = result.fetchall()
                    if rows:
                        st.table([dict(row._mapping) for row in rows])
                    else:
                        st.info("Query executed successfully, but no rows returned.")
                else:
                    # For INSERT, UPDATE, DELETE
                    st.success(f"Query executed successfully, {result.rowcount} row(s) affected.")
        except Exception as e:
            st.error(f"Error running query: {e}")
