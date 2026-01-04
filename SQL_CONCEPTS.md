# SQL Concepts Guide

A comprehensive guide to understanding SQL queries from basic to advanced, using examples from this application.

## Table of Contents

1. [SELECT with WHERE](#1-select-with-where)
2. [INNER JOIN](#2-inner-join)
3. [LEFT JOIN](#3-left-join)
4. [GROUP BY](#4-group-by)
5. [HAVING Clause](#5-having-clause)
6. [Aggregate Functions](#6-aggregate-functions)
7. [CASE Statements](#7-case-statements)
8. [Subqueries](#8-subqueries)
9. [Complex Aggregations](#9-complex-aggregations)
10. [Query Optimization Tips](#10-query-optimization-tips)

---

## 1. SELECT with WHERE

**Purpose**: Retrieve specific rows from a table based on conditions.

### Basic Syntax

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

### Example from Application

```sql
SELECT 
  student_id,
  first_name,
  last_name,
  email,
  grade
FROM students
WHERE grade = 10
ORDER BY last_name, first_name;
```

### Explanation

- `SELECT`: Specifies which columns to retrieve
- `FROM students`: Which table to query
- `WHERE grade = 10`: Only get students in grade 10
- `ORDER BY`: Sort results alphabetically by last name, then first name

### Common WHERE Operators

```sql
-- Equality
WHERE grade = 10

-- Comparison
WHERE grade >= 11

-- Multiple conditions (AND)
WHERE grade = 10 AND last_name = 'Smith'

-- Multiple conditions (OR)
WHERE grade = 10 OR grade = 11

-- Pattern matching
WHERE email LIKE '%@school.edu'

-- In a list
WHERE grade IN (10, 11, 12)

-- Range
WHERE grade BETWEEN 9 AND 12

-- NULL checks
WHERE email IS NOT NULL
```

### Try It

**Endpoint**: `GET /api/students/grade/10`

**Expected Result**: All students in grade 10, sorted alphabetically

---

## 2. INNER JOIN

**Purpose**: Combine rows from two or more tables based on a related column.

### Basic Syntax

```sql
SELECT columns
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Example from Application

```sql
SELECT 
  s.student_id,
  s.first_name,
  s.last_name,
  c.course_id,
  c.course_name,
  e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE s.student_id = 1;
```

### Explanation

**Visualization**:
```
students table    enrollments table    courses table
┌─────────────┐   ┌──────────────┐    ┌──────────────┐
│ student_id  │   │ student_id   │    │ course_id    │
│ first_name  │   │ course_id    │    │ course_name  │
│ last_name   │   │ grade        │    │ credits      │
└─────────────┘   └──────────────┘    └──────────────┘
       ↓                  ↓                   ↓
       └──────INNER JOIN──┴────INNER JOIN────┘
```

**Result**: Only rows where matches exist in ALL tables

### Key Points

- **INNER JOIN** only returns rows with matches in both tables
- Use table aliases (`s`, `e`, `c`) to make queries shorter
- Join multiple tables by chaining JOIN statements

### Try It

**Endpoint**: `GET /api/students/1/enrollments`

**Expected Result**: All courses student #1 is enrolled in

---

## 3. LEFT JOIN

**Purpose**: Get all rows from the left table, even if there's no match in the right table.

### Basic Syntax

```sql
SELECT columns
FROM table1
LEFT JOIN table2 ON table1.column = table2.column;
```

### Example from Application

```sql
SELECT 
  s.student_id,
  s.first_name,
  s.last_name,
  COUNT(e.enrollment_id) as total_enrollments
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id;
```

### Difference: INNER JOIN vs LEFT JOIN

**INNER JOIN**:
```
Students: [1, 2, 3, 4]
Enrollments: Student 1 has courses, Student 2 has courses

Result: Only students 1 and 2 (students WITH enrollments)
```

**LEFT JOIN**:
```
Students: [1, 2, 3, 4]
Enrollments: Student 1 has courses, Student 2 has courses

Result: ALL students (1, 2, 3, 4)
  - Students 1, 2: Show their enrollments
  - Students 3, 4: Show NULL for enrollments
```

### Use Cases

- Find students WITHOUT enrollments: `LEFT JOIN ... WHERE e.enrollment_id IS NULL`
- Show all records even if related data doesn't exist
- Calculate totals including zero counts

### Try It

**Endpoint**: `GET /api/students/all-with-enrollments`

**Expected Result**: All students, including those with 0 enrollments

---

## 4. GROUP BY

**Purpose**: Group rows that have the same values in specified columns and perform calculations on each group.

### Basic Syntax

```sql
SELECT column, AGGREGATE_FUNCTION(column)
FROM table
GROUP BY column;
```

### Example from Application

```sql
SELECT 
  grade,
  COUNT(*) as student_count
FROM students
GROUP BY grade
ORDER BY grade;
```

### Explanation

**Before GROUP BY**:
```
grade | first_name
------|------------
9     | John
9     | Emily
10    | David
10    | Jessica
10    | Daniel
```

**After GROUP BY**:
```
grade | student_count
------|---------------
9     | 2
10    | 3
```

### Rules

1. **SELECT clause** can only include:
   - Columns in GROUP BY
   - Aggregate functions (COUNT, SUM, AVG, etc.)

2. **Every non-aggregated column** in SELECT must be in GROUP BY

### Common Aggregate Functions

```sql
-- Count rows
COUNT(*) or COUNT(column)

-- Sum values
SUM(column)

-- Average
AVG(column)

-- Minimum/Maximum
MIN(column), MAX(column)

-- Concatenate strings
GROUP_CONCAT(column SEPARATOR ', ')
```

### Try It

**Endpoint**: `GET /api/analytics/students-per-grade`

**Expected Result**: Count of students in each grade

---

## 5. HAVING Clause

**Purpose**: Filter groups AFTER they've been created (like WHERE, but for groups).

### Basic Syntax

```sql
SELECT column, AGGREGATE_FUNCTION(column)
FROM table
GROUP BY column
HAVING condition_on_aggregate;
```

### WHERE vs HAVING

```sql
-- ❌ WRONG - Can't use aggregate in WHERE
SELECT course_id, COUNT(*) as enrollments
FROM enrollments
WHERE COUNT(*) >= 3  -- ERROR!
GROUP BY course_id;

-- ✅ CORRECT - Use HAVING for aggregate conditions
SELECT course_id, COUNT(*) as enrollments
FROM enrollments
GROUP BY course_id
HAVING COUNT(*) >= 3;  -- Filters groups
```

### Example from Application

```sql
SELECT 
  c.course_id,
  c.course_name,
  COUNT(e.enrollment_id) as enrollment_count
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
HAVING COUNT(e.enrollment_id) >= 3
ORDER BY enrollment_count DESC;
```

### Execution Order

```
1. FROM & JOIN    - Get all data
2. WHERE          - Filter individual rows
3. GROUP BY       - Create groups
4. HAVING         - Filter groups
5. SELECT         - Choose columns
6. ORDER BY       - Sort results
```

### Try It

**Endpoint**: `GET /api/courses/popular/3`

**Expected Result**: Only courses with 3 or more enrollments

---

## 6. Aggregate Functions

### COUNT

```sql
-- Count all rows
COUNT(*)

-- Count non-NULL values
COUNT(column)

-- Count distinct values
COUNT(DISTINCT column)
```

### SUM and AVG

```sql
-- Total credits
SUM(credits)

-- Average GPA
AVG(gpa)

-- With rounding
ROUND(AVG(gpa), 2)
```

### MIN and MAX

```sql
-- Earliest enrollment
MIN(enrollment_date)

-- Latest enrollment
MAX(enrollment_date)
```

### GROUP_CONCAT

```sql
-- Concatenate course names
GROUP_CONCAT(course_name SEPARATOR ', ')

-- With ordering
GROUP_CONCAT(
  CONCAT(course_name, ' (', grade, ')')
  ORDER BY enrollment_date DESC
  SEPARATOR ' | '
)
```

---

## 7. CASE Statements

**Purpose**: Conditional logic within SQL (like if-else statements).

### Basic Syntax

```sql
CASE
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ELSE default_result
END
```

### Example: Convert Letter Grades to GPA

```sql
SELECT 
  student_id,
  grade,
  CASE 
    WHEN grade = 'A' THEN 4.0
    WHEN grade = 'B' THEN 3.0
    WHEN grade = 'C' THEN 2.0
    WHEN grade = 'D' THEN 1.0
    WHEN grade = 'F' THEN 0.0
    ELSE 0.0
  END as gpa_points
FROM enrollments;
```

### Example: Categorize Performance

```sql
SELECT 
  student_id,
  AVG(gpa) as avg_gpa,
  CASE 
    WHEN AVG(gpa) >= 3.8 THEN 'Outstanding'
    WHEN AVG(gpa) >= 3.5 THEN 'Excellent'
    WHEN AVG(gpa) >= 3.0 THEN 'Good'
    ELSE 'Satisfactory'
  END as performance_rating
FROM enrollments
GROUP BY student_id;
```

### Example: Conditional Counting

```sql
-- Count grades in one query
SELECT 
  course_id,
  SUM(CASE WHEN grade = 'A' THEN 1 ELSE 0 END) as count_A,
  SUM(CASE WHEN grade = 'B' THEN 1 ELSE 0 END) as count_B,
  SUM(CASE WHEN grade = 'C' THEN 1 ELSE 0 END) as count_C
FROM enrollments
GROUP BY course_id;
```

### Try It

**Endpoint**: `GET /api/analytics/course-details/1`

**Expected Result**: Grade distribution with percentages using CASE

---

## 8. Subqueries

**Purpose**: Use the result of one query inside another query.

### Types of Subqueries

#### 1. Scalar Subquery (returns single value)

```sql
SELECT first_name, last_name
FROM students
WHERE grade = (SELECT MAX(grade) FROM students);
```

#### 2. Row Subquery (returns multiple values)

```sql
SELECT student_id, first_name
FROM students
WHERE student_id IN (
  SELECT student_id
  FROM enrollments
  WHERE course_id = 1
);
```

#### 3. Table Subquery (in FROM clause)

```sql
SELECT avg_gpa, COUNT(*) as student_count
FROM (
  SELECT student_id, AVG(gpa) as avg_gpa
  FROM enrollments
  GROUP BY student_id
) as student_gpas
GROUP BY avg_gpa;
```

### Example from Application

```sql
SELECT DISTINCT s.student_id, s.first_name, s.last_name
FROM students s
WHERE s.student_id IN (
  SELECT student_id
  FROM enrollments
  WHERE course_id IN (1, 2, 3)
);
```

### Correlated Subquery

```sql
SELECT 
  s.student_id,
  s.first_name,
  (
    SELECT COUNT(*)
    FROM enrollments e
    WHERE e.student_id = s.student_id
  ) as course_count
FROM students s;
```

### Try It

**Endpoint**: `GET /api/students/in-courses?courseIds=1,2,3`

**Expected Result**: Students enrolled in any of the specified courses

---

## 9. Complex Aggregations

### Weighted Average (GPA Calculation)

```sql
SELECT 
  student_id,
  SUM(grade_points * credits) / SUM(credits) as weighted_gpa
FROM (
  SELECT 
    student_id,
    CASE 
      WHEN grade = 'A' THEN 4.0
      WHEN grade = 'B' THEN 3.0
      WHEN grade = 'C' THEN 2.0
      ELSE 0.0
    END as grade_points,
    credits
  FROM enrollments e
  JOIN courses c ON e.course_id = c.course_id
) as grades_with_credits
GROUP BY student_id;
```

### Multiple Aggregations with HAVING

```sql
SELECT 
  s.student_id,
  COUNT(DISTINCT e.course_id) as courses_taken,
  SUM(c.credits) as total_credits,
  AVG(grade_points) as gpa
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id
HAVING 
  COUNT(DISTINCT e.course_id) >= 3
  AND AVG(grade_points) >= 3.5
ORDER BY gpa DESC;
```

### Try It

**Endpoint**: `GET /api/analytics/top-performers?minCourses=3&minGPA=3.5`

**Expected Result**: High-performing students with weighted GPA

---

## 10. Query Optimization Tips

### 1. Use Indexes

```sql
-- Index on frequently queried columns
CREATE INDEX idx_grade ON students(grade);
CREATE INDEX idx_student_course ON enrollments(student_id, course_id);
```

### 2. SELECT Only Needed Columns

```sql
-- ❌ Bad - retrieves all columns
SELECT * FROM students;

-- ✅ Good - specific columns
SELECT student_id, first_name, last_name FROM students;
```

### 3. Use WHERE Before JOIN When Possible

```sql
-- Filter early to reduce join size
SELECT s.*, c.course_name
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE s.grade = 12;  -- Filter reduces join size
```

### 4. Avoid Subqueries in SELECT

```sql
-- ❌ Slower - correlated subquery runs for each row
SELECT 
  s.*,
  (SELECT COUNT(*) FROM enrollments e WHERE e.student_id = s.student_id)
FROM students s;

-- ✅ Faster - single JOIN with GROUP BY
SELECT s.*, COUNT(e.enrollment_id) as enrollments
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id;
```

### 5. Use LIMIT for Large Results

```sql
-- Limit results for pagination
SELECT * FROM students
ORDER BY last_name
LIMIT 10 OFFSET 0;  -- First page

LIMIT 10 OFFSET 10;  -- Second page
```

### 6. EXPLAIN Your Queries

```sql
EXPLAIN SELECT * FROM students WHERE grade = 10;
```

This shows how MySQL executes the query and helps identify bottlenecks.

---

## SQL Best Practices

### 1. Use Meaningful Aliases

```sql
-- ❌ Unclear
SELECT s.a, s.b FROM students s;

-- ✅ Clear
SELECT s.first_name, s.last_name FROM students s;
```

### 2. Format for Readability

```sql
-- ✅ Well formatted
SELECT 
  s.student_id,
  s.first_name,
  COUNT(e.enrollment_id) as enrollments
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name
HAVING COUNT(e.enrollment_id) > 0
ORDER BY enrollments DESC;
```

### 3. Use Parameterized Queries

```javascript
// ❌ SQL Injection risk
const query = `SELECT * FROM students WHERE grade = ${userInput}`;

// ✅ Safe - parameterized
const query = 'SELECT * FROM students WHERE grade = ?';
pool.query(query, [userInput]);
```

### 4. Handle NULL Values

```sql
-- Check for NULL
WHERE email IS NULL
WHERE email IS NOT NULL

-- Replace NULL with default
COALESCE(phone_number, 'No phone') as phone

-- Count excluding NULL
COUNT(column_name)  -- Excludes NULLs
COUNT(*)            -- Includes NULLs
```

---

## Practice Exercises

Try modifying the existing queries:

1. **Find students with GPA > 3.8 in grade 11**
2. **List courses with average GPA < 2.5**
3. **Find students taking exactly 5 courses**
4. **Calculate average credits per department**
5. **Find the most popular course in each department**

---

**Continue exploring the API endpoints to see these concepts in action!** 🎓
