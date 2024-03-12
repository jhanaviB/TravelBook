DROP PROCEDURE IF EXISTS UpdateAgent;

DELIMITER //
CREATE PROCEDURE UpdateAgent(
	IN id INT,
	IN new_name VARCHAR(50),
	IN new_contact VARCHAR(50),
	IN new_email VARCHAR(50)
)
BEGIN
	DECLARE current_name VARCHAR(50);

	-- Update agent details for any new mentioned details
	UPDATE Agents
	SET name = COALESCE(new_name, name),
		contact = COALESCE(new_contact, contact),
		email = COALESCE(new_email, email)
	WHERE agent_id = id;

	SELECT name INTO current_name FROM Agents WHERE agent_id = id;

	SELECT CONCAT('Agent details were updated for ', current_name) AS message;
END //
DELIMITER ;

CALL UpdateAgent(1,null,null,'hb@gmail.com');
