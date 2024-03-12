import os
import openai
import mysql.connector
import argparse
from tabulate import tabulate
import datetime

# OpenAI API Key
openai.api_key = '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'

def parse_sql_files(database_dir):
    # Check if the directory exists
    if os.path.exists(database_dir):
        # List all SQL files in the database folder
        sql_files = [file for file in os.listdir(database_dir) if file.endswith('.sql')]
    else:
        print("Error: Database directory not found.")

    # Parse all sql files under /database folder
    document_text = ""
    for sql_file in sql_files:
        with open(os.path.join(database_dir, sql_file), 'r') as file:
            document_text += file.read() + "\n"
    return document_text

# Send parsed sql scripts and english query to ChatCompletion API for an SQL Query response
def complete_message(document_text, query):
    response = openai.ChatCompletion.create(
        model="gpt-4-turbo",
        messages=[
            {"role": "system", "content": f"Text:\n{document_text}\n\n"},
            {"role": "user", "content": f"Convert the instruction into SQL by writing queries (first try this) or using stored procedures (use only if really needed, try using SELECT statements first) from the given Text (Note: Do not create random stored procedures, only specifcally use the available ones). Instruction: {query}\n Then execute a select statement to display the respective results. Only generate results in MySQL and no other words (like sql) or sentences. Don't write SQL inside these(```sql ```)"}
        ],
        temperature=0,
        max_tokens=500
    )
    return response.choices[0].message['content'].strip()

# Connect to SQL server and execute SQL Query
def execute_query(mysql_queries):
    mydb = mysql.connector.connect(
        host="localhost",  # Provide your hostname
        user="root",       # Provide your username
        password="Chotumotu@21",  # Provide your password
        database="TravelAgency"  # This database has been created with the SQL file
    )
    cursor = mydb.cursor()
    
    headers_proc = []
    results_proc = []
    headers_query = []
    results_query = []

    for query in mysql_queries:
        if query.startswith('CALL'):
            proc_name, proc_params = query.split('(')
            proc_name = proc_name.strip()[5:]
            proc_params = proc_params.rstrip(';)').split(',')
            cursor.callproc(proc_name, proc_params)
            headers_proc = [desc[0] for desc in cursor.description]
            results_proc.extend([r.fetchall() for r in cursor.stored_results()])
        else:
            cursor.execute(query)
            headers_query = [desc[0] for desc in cursor.description]
            results_query.append(cursor.fetchall())

    mydb.commit()

    return headers_proc, results_proc, headers_query, results_query

# Print formatted results for query outputs
def print_formatted_results(headers, results):
    max_col_widths = [min(30, max(len(str(header)), *[len(str(row[i])) for row in results])) for i, header in enumerate(headers)]
    formatted_headers = [truncate_string(header, width) for header, width in zip(headers, max_col_widths)]
    rows = [list(map(lambda x, width: truncate_string(x, width), row, max_col_widths)) for row in results]
    print(tabulate(rows, headers=formatted_headers, tablefmt="asciidoc"))

# Truncate string if it exceeds the max_length
def truncate_string(string, max_length):
    if isinstance(string, datetime.date):
        return string.strftime("%Y-%m-%d").ljust(max_length)
    elif len(str(string)) > max_length:
        return str(string)[:max_length - 3] + "..."
    return str(string).ljust(max_length)

def main(user_query, mysql_query, execution_type, database_dir):
    if execution_type == 'generate':
        document_text = parse_sql_files(database_dir)
        mysql_query = complete_message(document_text, user_query)
        print(mysql_query)
    elif execution_type == 'execute':
        mysql_queries = mysql_query.split(';')
        mysql_queries = [query.strip() + ';' for query in mysql_queries if query.strip()]
        headers_proc, results_proc, headers_query, results_query = execute_query(mysql_queries)

        if len(results_proc) != 0:
            print(tabulate(results_proc[0], headers=headers_proc, tablefmt="asciidoc"))
        print()

        if len(results_query) != 0:
            print_formatted_results(headers_query, results_query[0])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SQL Generator Script")
    parser.add_argument('input', type=str, help='English Input')
    parser.add_argument('sqlQuery', type=str, help='SQL Query')
    parser.add_argument('type', type=str, help='Execution Type')
    parser.add_argument('database', type=str, help='Database Path')
    args = parser.parse_args()
    main(args.input, args.sqlQuery, args.type, args.database)