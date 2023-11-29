use `lab-mysql-select`;

/* Step 1: Calculate the royalties of each sales for each author 
Write a SELECT query to obtain the following output:

Title ID
Author ID
Royalty of each sale for each author */
drop temporary table if exists temp_royalty;
create temporary table temp_royalty (
     Title_ID varchar(255),
     Author_ID varchar(11),
     sales_royalty decimal(12,4)
);
insert into temp_royalty( Title_ID, Author_ID, sales_royalty)
select 
     titles.title_id as Title_ID , 
     titleauthor.au_id as Author_ID,
     titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 as sales_royalty
from 
     titles
join
     titleauthor using (title_id)
join     
     sales on titles.title_id = sales.title_id 
order by
     sales_royalty;  

select * from temp_royalty;
  
/*Step 2: Aggregate the total royalties for each title for each author
Using the output from Step 1, write a query to obtain the following output:

Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.
 */
create temporary table temp_total_royalties (
     Title_ID varchar(255),
     Author_ID varchar(11),
     total_sales_royalties decimal(12,4)
); 
insert into temp_total_royalties( Title_ID, Author_ID, total_sales_royalties)
select 
     titles.title_id as Title_ID , 
     titleauthor.au_id as Author_ID,
     sum(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as total_sales_royalties
from 
     titles
join
     titleauthor using (title_id)
join     
     sales on titles.title_id = sales.title_id 
group by
     Author_ID, Title_ID   
order by
     total_sales_royalties;     

select * from temp_total_royalties;
     
/* Step 3: Calculate the total profits of each author    
Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain the eventual output. Using the output from Step 2, write a query to obtain the following output:

Author ID
Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.*/
drop temporary table if exists temp_total_profits;
create temporary table temp_total_profits (
     Title_ID varchar(255),
     Author_ID varchar(11),
     total_profits decimal(12,4)
); 
insert into temp_total_profits(Title_ID, Author_ID, total_profits)
select 
     titles.title_id as Title_ID ,
     titleauthor.au_id as Author_ID,
     sum(titles.advance + titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as total_profits
from 
     titles
join
     titleauthor using (title_id)
join     
     sales on titles.title_id = sales.title_id 
group by
     Author_ID, Title_ID 
order by
     total_profits desc
limit 3;     
select * from temp_total_profits;

/* Challenge 2 - Alternative Solution
In the previous challenge, you may have developed your solution in either of the following ways:

Derived tables (see reference)
Creating MySQL temporary tables in the initial steps, and query the temporary tables in the subsequent steps.
Either way you have used, we'd like you to try the other way. Include your alternative solution in solutions.sql*/
create temporary table DerivedRoyalties as
select 
     titles.title_id as Title_ID , 
     titleauthor.au_id as Author_ID,
     titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 as sales_royalty
from 
     titles
join
     titleauthor using (title_id)
join     
     sales on titles.title_id = sales.title_id 
order by
     sales_royalty;  

select * from DerivedRoyalties;

/* step 2*/
create temporary table DerivedTotalRoyalties as
select 
     dr. Title_ID , 
     dr. Author_ID,
     sum(dr.sales_royalty) as total_sales_royalties
from 
     DerivedRoyalties dr
group by
     dr.Author_ID, dr.Title_ID   
order by
     total_sales_royalties; 
select * from  DerivedTotalRoyalties;    

/* step 3*/
create temporary table DerivedTotalprofits as
select 
     dtr.Title_ID , 
     dtr.Author_ID,
     sum(t.advance + dtr.total_sales_royalties) as total_profits
from 
     DerivedTotalRoyalties dtr
join
     titles t on dtr.Title_ID   = t.title_id  
group by
     dtr.Author_ID, dtr.Title_ID   
order by
     total_profits; 
     
select * from  DerivedTotalprofits;  

/* Challenge 3
Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. The table should have 2 columns:

au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
Include your solution in solutions.sql.*/
create table most_profiting_authors(
     Author_ID varchar(11),
     profits decimal(19,4)
);
insert into most_profiting_authors( Author_ID, profits)
select
     titleauthor.au_id as Author_ID,
     sum(titles.advance + titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as profits
from 
     titles
join
     titleauthor using (title_id)
join     
     sales on titles.title_id = sales.title_id 
group by
     Author_ID
order by
    profits desc;
select * from most_profiting_authors;       