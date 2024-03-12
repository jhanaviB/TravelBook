DROP PROCEDURE IF EXISTS MakePayment;

DELIMITER //
CREATE PROCEDURE MakePayment(
    IN book_id INT,
    IN trans_type ENUM('cash', 'card', 'check', 'refund'),
    IN trans_date DATE
)
BEGIN
	DECLARE id INT;
    DECLARE inv_id INT;
    DECLARE inv_price DECIMAL(10, 2);
    DECLARE trans_amount DECIMAL(10, 2);
    DECLARE status ENUM('pending', 'confirmed', 'cancelled');
    
    -- Get the confirmation status for the given booking ID
    SELECT confirmation_status INTO status
    FROM Bookings
    WHERE booking_id = book_id;
    
    -- Check the confirmation status
    IF status = 'pending' THEN
		-- Start transaction
        START TRANSACTION;
        
        -- Get inventory_id and price based on booking_id
        SELECT i.inventory_id, i.price INTO inv_id, inv_price
        FROM Bookings b
        JOIN Inventory i ON b.inventory_id = i.inventory_id
        WHERE b.booking_id = book_id;

        -- Calculate amount based on transaction type
        IF trans_type = 'cash' THEN
            SET trans_amount = inv_price;    -- No increase
        ELSEIF trans_type = 'card' THEN
            SET trans_amount = inv_price * 1.03; -- Increase by 3%
        ELSEIF trans_type = 'check' THEN
            SET trans_amount = inv_price * 1.01; -- Increase by 1%
        END IF;
        
        -- Insert transaction into Transactions table
        INSERT INTO Transactions (amount, transaction_date, transaction_type, booking_id)
        VALUES (trans_amount, trans_date, trans_type, book_id);
        
        -- Update booking status to 'confirmed'
        UPDATE Bookings
        SET confirmation_status = 'confirmed'
        WHERE booking_id = book_id;
        
        -- Get the last inserted transaction ID
        SELECT LAST_INSERT_ID() INTO id;
        
        -- Commit the transaction
        COMMIT;
        
		-- Return the transaction ID with message
        SELECT CONCAT('Transaction recorded for booking id: ', book_id, ' with transaction id: ', id, ' using ', trans_type) AS message;
        
    ELSEIF status = 'confirmed' THEN
        -- Display message if booking is confirmed
        SELECT 'Payment already made!' AS message;
        
    ELSEIF status = 'cancelled' THEN
        -- Display message if booking is cancelled
        SELECT 'Booking was cancelled!' AS message;
    END IF;
END//
DELIMITER ;