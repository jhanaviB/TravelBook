DROP PROCEDURE IF EXISTS GetBookings;

-- Stored Procedure to get only booking details for a particular customerID and itineraryID 
DELIMITER //
CREATE PROCEDURE GetBookingsForCustomerAndItinerary(
    IN customer INT,
    IN itinerary INT
)
BEGIN
    DECLARE customer_name VARCHAR(50);
    DECLARE itinerary_destination VARCHAR(50);
    DECLARE booking_count INT;
    
    -- Get customer name
    SELECT name INTO customer_name FROM Customers WHERE customer_id = customer;
    
    -- Get itinerary destination
    SELECT destination INTO itinerary_destination FROM Itinerary WHERE itinerary_id = itinerary;
    
    -- Check if there are bookings for the customer and itinerary
    SELECT COUNT(*) INTO booking_count
    FROM Bookings
    WHERE customer_id = customer
    AND inventory_id IN (
        SELECT inventory_id FROM ItineraryItem WHERE itinerary_id = itinerary
    );
    
    -- Display message based on booking count
    IF booking_count = 0 THEN
        SELECT CONCAT('No bookings for Customer ', customer_name, ' for itinerary ', itinerary_destination) AS message;
    ELSE
        -- SELECT CONCAT('Bookings for Customer ', customer_name, ' and itinerary ', itinerary_destination) AS message;
    
		-- Get bookings
		SELECT *
		FROM Bookings
		WHERE customer_id = customer
		AND inventory_id IN (
			SELECT inventory_id FROM ItineraryItem WHERE itinerary_id = itinerary
		);
	END IF;
END//
DELIMITER ;