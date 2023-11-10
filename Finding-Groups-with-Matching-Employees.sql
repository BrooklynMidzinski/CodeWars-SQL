-- Issue:
--     Write a parameterized PostgreSQL query to find groups with the exact same set of employees as a specified group.
    
--     Schema (groups table):
    
--     employee_id (integer): identifier for each employee.
--     group_name (varchar): The name of the group.
--     Task Instructions:
    
--     Create a prepared SQL statement named find_groups_with_matching_employees.
--     The statement should take a group name as its parameter (of type text). Use $1 as a placeholder for this parameter.
--     Return groups that have the same exact set of employees as the group specified in the parameter.
--     The result should contain the columns group_name and employees (which is an ordered array of employee IDs. IDs are sorted in ascending order).
--     The result should be ordered by group_name in ascending order.



-- My Resolution:

    PREPARE find_groups_with_matching_employees(text) as
    --'SPECIFIED GROUP' to retrieve the employee ID
    WITH specified_group AS (
        SELECT employee_id
        FROM groups
        WHERE group_name = $1
    ),
    --'MATCHING GROUPS' to find groups with the same set of employees.
    matching_groups AS (
        --'ARRAY_AGG' used to create arrays of employee ID's foreach group, then compare the arrays to the specified group's.
        SELECT group_name, ARRAY_AGG(employee_id ORDER BY employee_id) AS employees
        FROM groups
        WHERE group_name <> $1
        GROUP BY group_name
        HAVING ARRAY(SELECT employee_id FROM specified_group ORDER BY employee_id)
               = ARRAY_AGG(employee_id ORDER BY employee_id)
    )
    SELECT *
    FROM matching_groups
    ORDER BY group_name;



--Simpler Resolution:

    prepare find_groups_with_matching_employees(text) as
      with agg as (
        select group_name,
        --array_agg() an aggregate function that accepts a set of values and returns an array where each value in the input
        --set is assigned to an element of the array
        --ARRAY_AGG(expression[sort_expression{ASC|DESC}],[...]) the ORDER BY clause is a voluntary clause
        array_agg(employee_id order by employee_id) as employees 
        from groups 
        group by group_name
        )
      select agg.* 
      from agg
      --self join. Matching rows where the 'employees' arrays are equal and where the 'group_name' of the other row ('oth')
      --is equal to the specified parameter '$1'.
      join agg oth on agg.employees = oth.employees and oth.group_name = $1 and agg.group_name != oth.group_name
      order by 1;