--Issue:
      --You work with a database to track intricate drug dosages administered during clinical trials, often referencing varied units, including secondary measures like body weight.

      --Table Schemas:
      ---drugs:
      --drug_id (integer) - Primary Key
      --drug_name (varchar) - The name of the drug.
      
      --units:
      --unit_id (integer) - Primary Key
      --unit_name (varchar) - The name of the unit (e.g., mg, kg, mL).
      --dose_records:

      --record_id (integer) - Primary Key
      --drug_id (integer) - Foreign Key: Refers to the drug_id in the drugs table.
      --drug_amount (float) - The amount of the drug administered.
      --drug_unit_id (integer) - Foreign Key: Refers to the unit_id in the units table representing the unit of the drug amount.
      --check_unit_id (integer, nullable) - Foreign Key: Refers to the unit_id in the units table representing the secondary unit, if any.
      --Your task as to write SQL query that pulls relevant dosage information. The management wants to view the record_id, name of the drug, the drug_amount, and its associated dose_units for each record.

      --Here's the twist: the dose_units are sometimes a combination of two units. If a secondary unit exists (check_unit_id), the team wants to see it in the format primary_unit/secondary_unit (e.g., mg/kg). If there's no secondary unit, only the primary unit (drug_unit_id) should be displayed.

      --Resultant Dataset Columns:

      --record_id: A unique identifier for each dosage record.
      --drug_name: The name of the specific drug administered.
      --drug_amount: The quantity of the drug given during the dosage.
      --dose_units: The units in which the drug was administered. If there's a secondary unit of measurement, it's combined with the primary unit (e.g., "mg/kg"). If no secondary unit exists, only the primary unit is displayed.
      --The dataset should be ordered first by drug_name in ascending order and then by record_id in ascending order for records with the same drug name.



--My Resolution:
--'dr' 'd' are identifying what information is coming from what table
SELECT 
    dr.record_id,
    d.drug_name,
    dr.drug_amount,
--here we are concatinating the units and combining them if there are two. Seperating by '/'
    CASE
        WHEN u2.unit_name IS NOT NULL THEN CONCAT(u1.unit_name, '/', u2.unit_name)
        ELSE u1.unit_name
    END AS dose_units
FROM 
    dose_records dr
--joining all the datasets so we can call all of our information.
JOIN 
    drugs d ON dr.drug_id = d.drug_id
JOIN 
    units u1 ON dr.drug_unit_id = u1.unit_id
LEFT JOIN 
    units u2 ON dr.check_unit_id = u2.unit_id
ORDER BY 
    d.drug_name ASC, dr.record_id ASC;



--Most other posted resolutions look similar enough to mine that I didn't add a second resolution
