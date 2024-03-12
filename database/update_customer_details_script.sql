DROP PROCEDURE IF EXISTS UpdateCustomer;

DELIMITER //
CREATE PROCEDURE UpdateCustomer(
	IN id INT,
	IN new_name VARCHAR(50),
	IN new_contact VARCHAR(50),
	IN new_email VARCHAR(50),
	IN new_preferences TEXT
)
BEGIN
	DECLARE current_name VARCHAR(50);

	-- Update customer details for any new mentioned details
	UPDATE Customers
	SET name = COALESCE(new_name, name),
		contact = COALESCE(new_contact, contact),
		email = COALESCE(new_email, email),
		preferences = COALESCE(new_preferences, preferences)
	WHERE customer_id = id;

	SELECT name INTO current_name FROM Customers WHERE customer_id = id;

	SELECT CONCAT('Customer details were updated for ', current_name) AS message;
END //
DELIMITER ;

CALL UpdateCustomer(1,'Jhanavi Behl','7325226768','jhanavibehl@gmail.com','Hotel');
