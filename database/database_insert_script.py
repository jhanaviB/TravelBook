from faker import Faker
import mysql.connector
from decimal import Decimal
from datetime import timedelta 
import time
import random
import gc

# Garbage collection
gc.enable()
gc.collect()

mydb = mysql.connector.connect(
    host="localhost",  # Provide your hostname
    user="root",       # Provide your username
    password="Chotumotu@21",  # Provide your password
    database="TravelAgency"  # This database has been created with the SQL file
)

# Function to insert multiple Agent records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_agents(n, names, contacts, emails):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Agents (name, contact, email) VALUES (%s, %s, %s);"
    val = [(names[i], contacts[i], emails[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Customer records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_customers(n, names, contacts, emails):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Customers (name, contact, email) VALUES (%s, %s, %s);"
    val = [(names[i], contacts[i], emails[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Itinerary records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_itineraries(n, destinations, budgets, details, agent_ids):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Itinerary (destination, estimated_budget, itinerary_details, agent_id) VALUES (%s, %s, %s, %s);"
    val = [(destinations[i], budgets[i], details[i], agent_ids[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Inventory records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_inventory(n, types, names, prices, quantities):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Inventory (inventory_type, name, price, quantity) VALUES (%s, %s, %s, %s);"
    val = [(types[i], names[i], prices[i], quantities[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Itinerary Items records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_itinerary_items(n, itinerary_ids, inventory_ids):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO ItineraryItem (itinerary_id, inventory_id) VALUES (%s, %s);"
    val = [(itinerary_ids[i], inventory_ids[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Bookings records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_bookings(n, booking_types, start_dates, end_dates, booking_details, confirmation_statuses, customer_ids, agent_ids, inventory_ids):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Bookings (booking_type, start_date, end_date, booking_details, confirmation_status, customer_id, agent_id, inventory_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s);"
    val = [(booking_types[i], start_dates[i], end_dates[i], booking_details[i], confirmation_statuses[i], customer_ids[i], agent_ids[i], inventory_ids[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Function to insert multiple Transactions records at once using Prepared Statement and Benchmark Average Insertion time per record
def insert_transactions(n, amounts, transaction_dates, transaction_types, booking_ids):
    start_time = time.time()
    mycursor = mydb.cursor(prepared=True)
    sql = "INSERT INTO Transactions (amount, transaction_date, transaction_type, booking_id) VALUES (%s, %s, %s, %s);"
    val = [(amounts[i], transaction_dates[i], transaction_types[i], booking_ids[i]) for i in range(n)]
    mycursor.executemany(sql, val)
    mydb.commit()
    elapsed_time = (time.time() - start_time) / n
    return elapsed_time

# Initialize the number of records to be entered for each table
num_agents_customers = 100
num_itinerary = 500
num_inventory = 2000

# Initialize these number of records on the basis of inventory records
num_booking = num_inventory - 300
num_transaction = 0

# Initialize the min and max number of inventory for each itinerary
min_inventory_per_itinerary = 5
max_inventory_per_itinerary = 10
num_itinerary_items = 0

# Initialize Faker library which is used to generate random records such as name, contact, email, text, dates etc.
fake = Faker()

# Agents & Customers
# Generate names, email and contact no. using Faker library
names = [fake.name() for _ in range(num_agents_customers * 2)]
emails = [fake.email() for _ in range(num_agents_customers * 2)]
contacts = [fake.msisdn()[3:] for _ in range(num_agents_customers * 2)]

# Itinerary
# Generate city, budget, text using Faker library
# Randomly assign agent_ids for each itinerary
itinerary_destinations = [fake.city() for _ in range(num_itinerary)]
itinerary_budgets = [fake.pydecimal(left_digits=random.randint(1, 8), right_digits=2, positive=True) for _ in range(num_itinerary)]
itinerary_details = [fake.text() for _ in range(num_itinerary)]
itinerary_agent_ids = [random.randint(1, num_agents_customers) for _ in range(num_itinerary)]

# Inventory
# Randomly assign inventory_type and quantities
# Generate company and prices using Faker library
inventory_type = ['flight', 'car', 'train', 'bus', 'cruise', 'helicopter', 'hotel']
inventory_types = [random.choice(inventory_type) for _ in range(num_inventory)]
inventory_names = [fake.company() for _ in range(num_inventory)]
inventory_prices = [fake.pydecimal(left_digits=random.randint(1, 5), right_digits=2, positive=True) for _ in range(num_inventory)]
inventory_quantities = [random.randint(1, 100) for _ in range(num_inventory)]

# Itinerary Items
# Assign inventory to each itinerary between the decided min and max range
itinerary_ids = []
inventory_ids = []
offset = 1

for id in range(1, num_itinerary + 1):
    num_items = random.randint(min_inventory_per_itinerary, max_inventory_per_itinerary)
    if offset + num_items > num_inventory:
        break
    itinerary_ids.extend([id] * num_items)
    inventory_ids.extend(range(offset, offset + num_items))
    offset += max(num_items - random.randint(0, 10), 1)
num_itinerary_items = len(itinerary_ids)

# Bookings
# Generate booking_details using Faker library 
# Randomly assign confirmation_status, customer_id, agent_id and inventory_id
booking_details = [fake.text() for _ in range(num_booking)]
confirmation_status_type = ['pending', 'confirmed', 'cancelled']
confirmation_statuses = [random.choice(confirmation_status_type) for _ in range(num_booking)]
customer_ids = [random.randint(1, num_agents_customers) for _ in range(num_booking)]
booking_agent_ids = [random.randint(1, num_agents_customers) for _ in range(num_booking)]
booking_inventory_ids = [random.randint(1, num_inventory) for _ in range(num_booking)]

# Assign booking_type based on the inventory_type
booking_types = []
for id in booking_inventory_ids:
    type = inventory_types[id - 1]
    if type == 'hotel':
        booking_types.append('stay')
    else:
        booking_types.append('transport')

# Randomly assign start_date
start_dates = [fake.date_between(start_date="-1y", end_date="+1y") for _ in range(num_booking)]

# Assign end_date based on the bookinh_type
end_dates = []
for booking_type, start_date in zip(booking_types, start_dates):
    if booking_type == 'transport':
        end_dates.append(start_date + timedelta(days=random.randint(0, 1)))
    else:
        end_dates.append(fake.date_between(start_date=start_date, end_date=start_date + timedelta(days=random.randint(1, 10))))
start_dates_formatted = [date.strftime('%Y-%m-%d') for date in start_dates]
end_dates_formatted = [date.strftime('%Y-%m-%d') for date in end_dates]

# Transactions
# Generate booking_id based on the confirmation_status = confirmed
trans_booking_ids_confirmed = [booking_id for booking_id, confirmation_status in zip(range(1, num_booking + 1), confirmation_statuses) if confirmation_status == 'confirmed']
num_transaction_confirmed = len(trans_booking_ids_confirmed)

# Generate booking_id based on the confirmation_status = cancelled
trans_booking_ids_cancelled = [booking_id for booking_id, confirmation_status in zip(range(1, num_booking + 1), confirmation_statuses) if confirmation_status == 'cancelled']
num_transaction_cancelled = len(trans_booking_ids_cancelled)

# Merge both confirmed and cancelled booking_ids
trans_booking_ids = trans_booking_ids_confirmed + trans_booking_ids_cancelled
num_transaction = num_transaction_confirmed + num_transaction_cancelled

# Randomly assign transaction_types
trans_types = ['cash', 'card', 'check']
transaction_types_confirmed = [random.choice(trans_types) for _ in range(num_transaction_confirmed)]
transaction_types_cancelled = ['refund' for _ in range(num_transaction_cancelled)]
transaction_types = transaction_types_confirmed + transaction_types_cancelled

# Assign transaction_date within 30 to 90 days before start_date for confirmed bookings
transaction_dates = []
for booking_id in trans_booking_ids_confirmed:
    start_date = start_dates[booking_id - 1]
    transaction_date = fake.date_between(start_date - timedelta(days=90), start_date - timedelta(days=30))
    transaction_dates.append(transaction_date)

# Assign transaction_date within 7 days after start_date for cancelled bookings
for booking_id in trans_booking_ids_cancelled:
    start_date = start_dates[booking_id - 1]
    transaction_date = fake.date_between(start_date, start_date + timedelta(days=7))
    transaction_dates.append(transaction_date)

# Garbage collection
trans_booking_ids_confirmed = []
trans_booking_ids_cancelled = []
transaction_types_confirmed = []
transaction_types_cancelled = []
gc.collect()

# Add addition transaction charges depening on the transaction_type
amounts = []
for i in range(num_transaction):
    inv_id = booking_inventory_ids[trans_booking_ids[i] - 1]
    amount = inventory_prices[inv_id - 1]
    if transaction_types[i] == 'cash' or transaction_types[i] == 'refund':
        amount_charged = amount
    elif transaction_types[i] == 'card':
        amount_charged = amount * Decimal('1.03')
    elif transaction_types[i] == 'check':
        amount_charged = amount * Decimal('1.01')
    amounts.append(amount_charged)

# Call insert functions to insert records into table and get the benchmarked insertion rate

avg_insert_time_agent = insert_agents(num_agents_customers, names[:num_agents_customers], contacts[:num_agents_customers], emails[:num_agents_customers])
print(f"Average insertion time per agent: {avg_insert_time_agent} seconds")

avg_insert_time_customer = insert_customers(num_agents_customers, names[num_agents_customers:], contacts[num_agents_customers:], emails[num_agents_customers:])
print(f"Average insertion time per customer: {avg_insert_time_customer} seconds")

avg_insert_time_itinerary = insert_itineraries(num_itinerary, itinerary_destinations, itinerary_budgets, itinerary_details, itinerary_agent_ids)
print(f"Average insertion time per itinerary: {avg_insert_time_itinerary} seconds")

avg_insert_time_inventory = insert_inventory(num_inventory, inventory_types, inventory_names, inventory_prices, inventory_quantities)
print(f"Average insertion time per inventory: {avg_insert_time_inventory} seconds")

avg_insert_time_itinerary_item = insert_itinerary_items(num_itinerary_items, itinerary_ids, inventory_ids)
print(f"Average insertion time per itinerary item: {avg_insert_time_itinerary_item} seconds")

avg_insert_time_booking = insert_bookings(num_booking, booking_types, start_dates_formatted, end_dates_formatted, booking_details, confirmation_statuses, customer_ids, booking_agent_ids, booking_inventory_ids)
print(f"Average insertion time per booking: {avg_insert_time_booking} seconds")

avg_insert_time_transaction = insert_transactions(num_transaction, amounts, transaction_dates, transaction_types, trans_booking_ids)
print(f"Average insertion time per transaction: {avg_insert_time_transaction} seconds")