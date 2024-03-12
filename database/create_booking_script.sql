DROP PROCEDURE IF EXISTS CreateBooking;

DELIMITER //
CREATE PROCEDURE CreateBooking(
    IN customer INT,
    IN agent INT,
    IN inv_id INT,
    IN start DATE,
    IN end DATE,
    IN details TEXT
)
BEGIN
	DECLARE id INT;
	DECLARE inv_type ENUM('flight', 'car', 'train', 'bus', 'cruise', 'helicopter', 'hotel');
    DECLARE book_type ENUM('transport', 'stay');
    DECLARE inv_quantity INT;
    DECLARE inv_price DECIMAL(10, 2);
    DECLARE new_quantity INT;
    DECLARE new_price DECIMAL(10, 2);
    
    -- Get the inventory type and quantity
    SELECT inventory_type, quantity, price INTO inv_type, inv_quantity, inv_price
    FROM Inventory
    WHERE inventory_id = inv_id;
    
    -- Check if inventory quantity is greater than 0
    IF inv_quantity > 0 THEN
		START TRANSACTION;
        
        -- Get the booking_type based on the inventory_type
        IF inv_type = 'hotel' THEN
            SET book_type = 'stay';
        ELSE
            SET book_type = 'transport';
        END IF;
        
        -- Insert into Bookings table
        INSERT INTO Bookings (booking_type, start_date, end_date, booking_details, confirmation_status, customer_id, agent_id, inventory_id)
        VALUES (book_type, start, end, details, 'pending', customer, agent, inv_id);
        
        -- Decrease inventory quantity by 1
        UPDATE Inventory
        SET quantity = quantity - 1
        WHERE inventory_id = inv_id;
        
         -- Get the new quantity
		SELECT quantity INTO new_quantity
		FROM Inventory
		WHERE inventory_id = inv_id;
        
        -- Calculate the new price based on quantity
		IF new_quantity <= 10 THEN
			SET new_price = inv_price * 1.12; -- Increase price by 12%
		ELSEIF new_quantity <= 20 THEN
			SET new_price = inv_price * 1.07; -- Increase price by 7%
		ELSEIF new_quantity <= 30 THEN
			SET new_price = inv_price * 1.03; -- Increase price by 3%
		ELSE
			SET new_price = inv_price; -- No increase
		END IF;
        
        -- Update the price in the Inventory table
		UPDATE Inventory
		SET price = new_price
		WHERE inventory_id = inv_id;
        
        -- Get the last inserted booking ID
        SELECT LAST_INSERT_ID() INTO id;
        
        -- Commit the transaction
        COMMIT;
        
        -- Return the booking ID with message
		SELECT CONCAT('Booking successfully recorded for inventory id: ', inv_id, ' with booking id: ', id) AS message;
    ELSE
        -- Rollback the transaction if inventory quantity is 0
        ROLLBACK;
        
        -- Display message that bookings can't be made
        SELECT CONCAT('No more bookings can be recorded for inventory id: ', inv_id) AS message;
    END IF;
END//
DELIMITER ;