/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT `name`, `membercost`
FROM `Facilities`
WHERE `membercost` > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) 
FROM `Facilities` 
WHERE `membercost` = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance 
FROM `Facilities` 
WHERE `membercost` < (0.2 * `monthlymaintenance`);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities` 
WHERE `facid` = 1
	AND `facid` = 5;



/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT `name`, `monthlymaintenance` 
FROM `Facilities` 
WHERE `monthlymaintenance` > 100;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT `firstname`, `surname` 
FROM `Members`;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(firstname, ' ', surname) AS member, f.name
FROM Members m
INNER JOIN Bookings b
ON m.memid = b.memid
INNER JOIN Facilities f 
ON b.facid = f.facid
WHERE f.name LIKE 'Tennis%'
ORDER BY member;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members  (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT name AS facility_name, CONCAT(firstname, ' ', surname) AS member, (membercost * slots) AS member_total_cost
FROM Members 
INNER JOIN Bookings
USING(memid)
INNER JOIN Facilities
USING(facid)
WHERE starttime LIKE '2012-09-14%' 
	AND NOT memid = 0 
    AND (membercost * slots) > 30
ORDER BY member_total_cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT name AS facility_name, CONCAT(firstname, ' ', surname) AS member, (membercost * slots) AS total_member_cost
FROM Members 
INNER JOIN Bookings
USING(memid)
INNER JOIN Facilities
USING(facid) 
WHERE starttime LIKE '2012-09-14%' 
	AND NOT memid = 0 
    AND (membercost * slots) IN
        (SELECT membercost * slots
        FROM Bookings
        INNER JOIN Facilities
        USING(facid)
        WHERE (membercost * slots) > 30)
ORDER BY total_member_cost DESC;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

query_ten = """
    SELECT subq.name, SUM( subq.revenue ) AS revenue
    FROM (
    SELECT b.facid, b.memid, f.name, f.guestcost, f.membercost, COUNT( b.facid ) AS facid_count,
    CASE
    WHEN b.memid =0
    THEN COUNT( b.facid ) * f.guestcost
    ELSE COUNT( b.facid ) * f.membercost
    END AS 'revenue'
    FROM Bookings AS b
    LEFT JOIN Facilities AS f ON b.facid = f.facid
    GROUP BY b.facid, b.memid
    ) AS subq
    GROUP BY subq.facid
    HAVING revenue <=1000
    ORDER BY revenue DESC;
"""
cursor.execute(query_ten)
total_revenue_data = cursor.fetchall()
total_revenue_data

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
query_eleven = """
    SELECT r.recommendedby AS recommender_ID, (r.surname || " " || r.firstname) AS recommender, m.memid AS recommended_ID, (m.surname || " " || m.firstname) AS recommended
    FROM MEMBERS AS m
    LEFT JOIN MEMBERS AS r
    ON m.recommendedby = r.memid
    WHERE m.recommendedby != 0
    ORDER BY recommender;
"""
cursor.execute(query_eleven)
cursor.fetchall()


/* Q12: Find the facilities with their usage by member, but not guests */

query_twelve = """
    SELECT b.facid, COUNT( b.memid ) AS mem_usage, f.name
    FROM (
    SELECT facid, memid
    FROM Bookings
    WHERE memid !=0
    ) AS b
    LEFT JOIN Facilities AS f ON b.facid = f.facid
    GROUP BY b.facid;
"""
cursor.execute(query_twelve)
cursor.fetchall()


/* Q13: Find the facilities usage by month, but not guests */
query_thirteen = """
    SELECT b.months, COUNT( b.memid ) AS mem_usage
    FROM (
    SELECT strftime('%m',starttime) AS months, memid
    FROM Bookings
    WHERE memid !=0
    ) AS b
    GROUP BY b.months;
"""
cursor.execute(query_thirteen)
cursor.fetchall()

