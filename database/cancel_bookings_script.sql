DROP PROCEDURE IF EXISTS CancelBookings;

DELIMITER //
CREATE PROCEDURE CancelBookingsForCustomerAndItinerary(
    IN customer INT,
    IN itinerary INT
)
BEGIN
    DECLARE customer_name VARCHAR(50);
    DECLARE itinerary_destination VARCHAR(50);
    DECLARE booking_count INT;
    DECLARE confirmed_booking_id INT;
	DECLARE booking_amount DECIMAL(10, 2);
    
	-- Retrieve cancelled booking IDs
	DECLARE confirmed_booking_ids CURSOR FOR
		SELECT booking_id
		FROM Bookings
		WHERE customer_id = customer
        AND confirmation_status = 'confirmed'
		AND inventory_id IN (
			SELECT inventory_id FROM ItineraryItem WHERE itinerary_id = itinerary
		);
        
	-- Declare continue handler for cursor
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET confirmed_booking_id = NULL;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get customer name
    SELECT name INTO customer_name FROM Customers WHERE customer_id = customer;
    
    -- Get itinerary destination
    SELECT destination INTO itinerary_destination FROM Itinerary WHERE itinerary_id = itinerary;
    
    -- Check if there are bookings for the customer and itinerary
    SELECT COUNT(*) INTO booking_count
    FROM Bookings
    WHERE customer_id = customer
    AND confirmation_status != 'cancelled'
    AND inventory_id IN (
        SELECT inventory_id FROM ItineraryItem WHERE itinerary_id = itinerary
    );
    
    -- Commit or rollback transaction based on booking count
    IF booking_count > 0 THEN
        -- Open cursor
        OPEN confirmed_booking_ids;
        
        -- Fetch cancelled booking IDs and insert refund transactions
		confirmed_booking_loop: LOOP
			FETCH confirmed_booking_ids INTO confirmed_booking_id;
			IF confirmed_booking_id IS NULL THEN
				LEAVE confirmed_booking_loop;
			END IF;

			-- Get booking amount
			SELECT price INTO booking_amount
			FROM Bookings
			JOIN Inventory ON Bookings.inventory_id = Inventory.inventory_id
			WHERE booking_id = confirmed_booking_id;

			-- Insert refund transaction
			INSERT INTO Transactions (amount, transaction_date, transaction_type, booking_id)
			VALUES (booking_amount, CURDATE(), 'refund', confirmed_booking_id);
			
		END LOOP;

        CLOSE confirmed_booking_ids;
        
		-- Update booking confirmation status to "cancelled" and get the cancelled booking IDs
        UPDATE Bookings
        SET confirmation_status = 'cancelled'
        WHERE customer_id = customer
        AND confirmation_status != 'cancelled'
        AND inventory_id IN (
            SELECT inventory_id FROM ItineraryItem WHERE itinerary_id = itinerary
        );
        
        COMMIT;
        SELECT CONCAT('Bookings for Customer ', customer_name, ' and itinerary ', itinerary_destination, ' successfully cancelled.') AS message;
    ELSE
        ROLLBACK;
        SELECT CONCAT('No bookings found for Customer ', customer_name, ' for itinerary ', itinerary_destination, '. No changes were made.') AS message;
    END IF;
END//
DELIMITER ;