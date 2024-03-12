DROP PROCEDURE IF EXISTS UpdateSingleBooking;

DELIMITER //
CREATE PROCEDURE UpdateSingleBooking(
    IN start_date DATE,
    IN end_date DATE,
    IN details TEXT,
    IN booking_id INT
)
BEGIN
	-- CAN UPDATE START DATE, END DATE, INVENTORY QUANTITY
	-- Price will be changed
	DECLARE update_query VARCHAR(1000);    
	IF booking_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'booking_id cannot be NULL';
	END IF;

	IF start_date is null and end_date is null and details is null THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'start_date, end_date and details cannot be NULL together';
	END IF;

	START TRANSACTION;

	SET @update_query = CONCAT(
		'UPDATE Bookings SET ',
		IF(start_date IS NOT NULL, CONCAT('start_date = "', start_date, '", '), ''),
		IF(end_date IS NOT NULL, CONCAT('end_date = "', end_date, '", '), ''),
		IF(details IS NOT NULL, CONCAT('booking_details = "', details,'" '), ''),
		' WHERE booking_id = ', booking_id,
		' AND (confirmation_status = "confirmed" OR confirmation_status = "pending")'
		);

	SELECT @update_query;
	PREPARE stmt FROM @update_query;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	-- Commit the transaction
	COMMIT;
END//
DELIMITER ;
