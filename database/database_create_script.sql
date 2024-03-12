-- Travel Agency Database Creation Script

-- Create TravelAgency Database 
SHOW DATABASES;
DROP DATABASE IF EXISTS TravelAgency;
CREATE DATABASE TravelAgency;
USE TravelAgency;

SHOW TABLES;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS ItineraryItem;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Itinerary;
DROP TABLE IF EXISTS Agents;

-- Table for storing Agent information
CREATE TABLE Agents(
    agent_id  INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    contact VARCHAR(20),
    email VARCHAR(50)
);

-- Table for storing Itinerary information which is developed by a particular Agent
CREATE TABLE Itinerary(
    itinerary_id  INT PRIMARY KEY AUTO_INCREMENT,
    destination VARCHAR(50) NOT NULL,
    estimated_budget DECIMAL(10, 2),
    itinerary_details TEXT,
    agent_id INT,
    FOREIGN KEY (agent_id) REFERENCES Agents(agent_id)
);

-- Table for storing Inventory information of flights, car, cruise, hotels, etc along with their prices and available quantity related to each Itinerary
CREATE TABLE Inventory(
    inventory_id  INT PRIMARY KEY AUTO_INCREMENT,
    inventory_type ENUM('flight', 'car', 'train', 'bus', 'cruise', 'helicopter', 'hotel') NOT NULL,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2),
    quantity INT
);

-- Table for storing Inventory and Itinerary Many-to-Many relationship
CREATE TABLE ItineraryItem(
    itinerary_id INT,
    inventory_id INT,
    PRIMARY KEY (itinerary_id, inventory_id),
    FOREIGN KEY (itinerary_id) REFERENCES Itinerary(itinerary_id),
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);

-- Table for storing Customer information along with their preferences
CREATE TABLE Customers(
    customer_id  INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    contact VARCHAR(20),
    email VARCHAR(50),
    preferences TEXT
);

-- Table for storing Booking information along with its details and current status 
CREATE TABLE Bookings(
    booking_id  INT PRIMARY KEY AUTO_INCREMENT,
    booking_type ENUM('transport', 'stay') NOT NULL,
    start_date DATE,
    end_date DATE,
    booking_details TEXT,
    confirmation_status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending' NOT NULL,
    customer_id INT,
    agent_id INT,
    inventory_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (agent_id) REFERENCES Agents(agent_id),
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);

-- Table for storing Transaction information with different modes for each booking
CREATE TABLE Transactions(
    transaction_id  INT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type ENUM('cash', 'card', 'check', 'refund') NOT NULL,
    booking_id INT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);