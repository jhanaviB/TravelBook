DROP PROCEDURE IF EXISTS CancelSingleBooking;

DELIMITER //
CREATE PROCEDURE CancelSingleBooking(
    IN bookingId INT
)
BEGIN
    DECLARE booking_count INT;
	DECLARE booking_amount DECIMAL(10, 2);
    DECLARE inventory INT;
	DECLARE inv_price DECIMAL(10, 2);
	DECLARE new_quantity INT;
    DECLARE new_price DECIMAL(10, 2);
    DECLARE booking_confirmation VARCHAR(30);
    
    -- Start transaction
    START TRANSACTION;

    -- Check if there is the booking for the booking id
    SELECT COUNT(*) INTO booking_count
    FROM Bookings
     WHERE confirmation_status != 'cancelled'
    AND booking_id = bookingId;
    
    -- Commit or rollback transaction based on booking count
    IF booking_count = 1  THEN
		-- Get booking amount
		SELECT price,confirmation_status INTO booking_amount, booking_confirmation
		FROM Bookings
		JOIN Inventory ON Bookings.inventory_id = Inventory.inventory_id
		WHERE booking_id = bookingId;

		IF booking_confirmation = 'confirmed' THEN
		-- Insert refund transaction
		INSERT INTO Transactions (amount, transaction_date, transaction_type, booking_id)
		VALUES (booking_amount, CURDATE(), 'refund', bookingId);
		END IF;
				
		-- Update booking confirmation status to "cancelled" and get the cancelled booking IDs
        UPDATE Bookings
        SET confirmation_status = 'cancelled'
        WHERE booking_id = bookingId;
	
		SELECT inventory_id INTO inventory FROM bookings where booking_id = bookingId;

		SELECT price INTO inv_price
		FROM Inventory
		WHERE inventory_id = inventory;
		
		-- Increase  inventory quantity by 1
        UPDATE Inventory
        SET quantity = quantity + 1
        WHERE inventory_id = inventory;
    
		-- Get the new quantity
		SELECT quantity INTO new_quantity
		FROM Inventory
		WHERE inventory_id = inventory;
        
        -- Calculate the new price based on quantity
		IF new_quantity > 10 THEN
			SET new_price = inv_price / 1.12; -- Decrease price by 12%
		ELSEIF new_quantity >= 20 THEN
			SET new_price = inv_price / 1.07; -- Decrease price by 7%
		ELSEIF new_quantity >= 30 THEN
			SET new_price = inv_price / 1.03; -- Decrease price by 3%
		ELSE
			SET new_price = inv_price; -- No increase
		END IF;
        
        -- Update the price in the Inventory table
		UPDATE Inventory
		SET price = new_price
		WHERE inventory_id = inventory;
        
        COMMIT;
        SELECT CONCAT('Booking with booking id ',bookingId, ' successfully cancelled.') AS message;
    ELSE
        ROLLBACK;
        SELECT CONCAT('Booking already cancelled for booking id ',bookingId) AS message;
    END IF;
END//
DELIMITER ;
